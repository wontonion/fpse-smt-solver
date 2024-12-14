open Types
open Cdcl
open Cdcl.Variable

type grid = int list list

(* create empty grid *)
let create_empty_grid ~block_size () : grid =
  let size = block_size * block_size in
  List.init size (fun _ -> List.init size (fun _ -> 0))

(* Helper functions for list operations *)
let get_row (grid : grid) (row : int) : int list = List.nth grid row

let get_col (grid : grid) (col : int) : int list =
  List.map (fun row -> List.nth row col) grid

let get_block (grid : grid) (row : int) (col : int) ~block_size : int list =
  let size = block_size * block_size in
  let start_row = row / block_size * block_size in
  let start_col = col / block_size * block_size in
  List.init size (fun i ->
      let r = start_row + (i / block_size) in
      let c = start_col + (i mod block_size) in
      List.nth (List.nth grid r) c)

(* Update a value in a list at given index *)
let list_update (lst : 'a list) (index : int) (value : 'a) : 'a list =
  List.mapi (fun i x -> if i = index then value else x) lst

(* Update grid at position *)
let update_grid (grid : grid) (row : int) (col : int) (value : int) : grid =
  list_update grid row (list_update (List.nth grid row) col value)

(* Validation functions *)
let is_valid_in_list nums value =
  (not (List.exists (( = ) value) nums)) || value = 0

let is_valid (grid : grid) (row : int) (col : int) (num : int) ~block_size :
    bool =
  let row_valid = is_valid_in_list (get_row grid row) num in
  let col_valid = is_valid_in_list (get_col grid col) num in
  let block_valid = is_valid_in_list (get_block grid row col ~block_size) num in
  row_valid && col_valid && block_valid

(* Find first empty position *)
let find_empty (grid : grid) ~block_size : (int * int) option =
  let size = block_size * block_size in
  let rec find_in_row row col =
    if row >= size then None
    else if col >= size then find_in_row (row + 1) 0
    else if List.nth (List.nth grid row) col = 0 then Some (row, col)
    else find_in_row row (col + 1)
  in
  find_in_row 0 0

(* Solve sudoku recursively and return the number of solutions found *)
let rec solve_and_count (grid : grid) (max_solutions : int) ~block_size : int =
  if max_solutions = 0 then 0
  else
    match find_empty grid ~block_size with
    | None -> 1
    | Some (row, col) ->
        let size = block_size * block_size in
        let rec try_numbers num acc =
          if num > size || acc >= max_solutions then acc
          else if is_valid grid row col num ~block_size then
            let new_grid = update_grid grid row col num in
            let solutions =
              solve_and_count new_grid (max_solutions - acc) ~block_size
            in
            try_numbers (num + 1) (acc + solutions)
          else try_numbers (num + 1) acc
        in
        try_numbers 1 0

(* Helper function to solve the grid *)
let rec solve_grid (grid : grid) ~block_size : grid option =
  match find_empty grid ~block_size with
  | None -> Some grid
  | Some (row, col) ->
      let size = block_size * block_size in
      let numbers = List.init size (fun i -> i + 1) in
      let shuffled = List.sort (fun _ _ -> Random.int 3 - 1) numbers in
      let rec try_numbers = function
        | [] -> None
        | num :: rest ->
            if is_valid grid row col num ~block_size then
              match solve_grid (update_grid grid row col num) ~block_size with
              | Some solution -> Some solution
              | None -> try_numbers rest
            else try_numbers rest
      in
      try_numbers shuffled

(* Improved generation algorithm *)
let generate_puzzle ~block_size () : grid =
  if not (List.mem block_size [ 2; 3 ]) then
    failwith "Block size must be either 2 or 3";

  Random.self_init ();

  let solved_grid =
    match solve_grid (create_empty_grid ~block_size ()) ~block_size with
    | Some grid -> grid
    | None -> failwith "Failed to generate a complete grid"
  in

  let size = block_size * block_size in
  let total_cells = size * size in
  let positions = List.init total_cells (fun i -> (i / size, i mod size)) in
  let shuffled_positions = List.sort (fun _ _ -> Random.int 3 - 1) positions in

  (* remove about half of the numbers *)
  let target_removed = total_cells / 2 in

  let rec remove_numbers grid positions removed =
    match positions with
    | [] -> grid
    | (row, col) :: rest ->
        if removed >= target_removed then grid
        else
          let new_grid = update_grid grid row col 0 in
          let solutions = solve_and_count new_grid 2 ~block_size in
          if solutions = 1 then remove_numbers new_grid rest (removed + 1)
          else remove_numbers grid rest removed
  in

  remove_numbers solved_grid shuffled_positions 0

(* Print board *)
let print_board (grid : grid) : unit =
  List.iteri
    (fun i row ->
      if i mod 3 = 0 && i <> 0 then print_endline "---------------------";
      List.iteri
        (fun j num ->
          if j mod 3 = 0 && j <> 0 then print_string "| ";
          if num = 0 then print_string ". " else Printf.printf "%d " num)
        row;
      print_newline ())
    grid

let convert_to_sudoku_data (grid : grid) : sudoku_data =
  let size = List.length grid in
  let convert_cell value =
    {
      value = (if value = 0 then "" else string_of_int value);
      is_initial = value <> 0;
      is_valid = true;
    }
  in
  { size; grid = List.map (fun row -> List.map convert_cell row) grid }

let convert_frontend_cell json =
  let open Yojson.Safe.Util in
  {
    Types.value = member "value" json |> to_string;
    Types.is_initial = member "isInitial" json |> to_bool;
    Types.is_valid = member "isValid" json |> to_bool;
  }

let convert_frontend_grid json =
  let open Yojson.Safe.Util in
  let size = member "size" json |> to_int in
  let grid =
    member "grid" json |> to_list
    |> List.map (fun row -> to_list row |> List.map convert_frontend_cell)
  in
  { Types.size; Types.grid }

let sudoku_formula_3x3 =
  let open Core.In_channel in
  Dimacs.Parser.parse @@ read_all "data/sudoku.3x3.cnf" |> Result.get_ok

let sudoku_formula_2x2 =
  let open Core.In_channel in
  Dimacs.Parser.parse @@ read_all "data/sudoku.2x2.cnf" |> Result.get_ok

module RandomSolver = Solver.Make (Heuristic.Randomized)

(* Split a list into sublists of given size *)
let split_into_sublists size lst =
  let rec aux acc current_sublist remaining count =
    match remaining with
    | [] -> 
        if current_sublist <> [] then List.rev current_sublist :: acc
        else acc
        |> List.rev
    | x :: rest ->
        if count = size then
          aux (List.rev current_sublist :: acc) [x] rest 1
        else
          aux acc (x :: current_sublist) rest (count + 1)
  in
  aux [] [] lst 0

(* Convert boolean assignments to sudoku values *)
let bool_to_value size assignments =
  let grid_size = size * size in
  let values = Array.make (grid_size * grid_size) 0 in
  List.iteri
    (fun i b ->
      if b then
        let row = (i / (grid_size * size)) in
        let col = ((i / size) mod grid_size) in
        let value = (i mod size) + 1 in
        if row < grid_size && col < grid_size then
          values.((row * grid_size) + col) <- value)
    assignments;
  Array.to_list values 
  |> split_into_sublists grid_size

let solve_sudoku (int_grid : int list list) (size : int) :
    (int list list, string) Result.t Lwt.t =
  let cancelled = ref false in
  let pid = Unix.getpid () in
  
  Printf.printf "[PID:%d] Starting computation\n%!" pid;
  
  let task = 
    Lwt.catch
      (fun () ->
        let%lwt result = Lwt_preemptive.detach
          (fun () ->
            Printf.printf "[PID:%d] Worker thread started\n%!" pid;
            let formula =
              match size with
              | 4 when List.length (List.flatten int_grid) = 16 -> Ok sudoku_formula_2x2
              | 9 when List.length (List.flatten int_grid) = 81 -> Ok sudoku_formula_3x3
              | _ -> Error "Invalid grid size"
            in
            if !cancelled then (
              Printf.printf "[PID:%d] Task cancelled early\n%!" pid;
              Error "Cancelled"
            )
            else if Result.is_error formula then Error (Result.get_error formula)
            else
              let formula, _ =
                List.fold_left
                  (fun (f, idx) x ->
                    if !cancelled then (
                      Printf.printf "[PID:%d] Task cancelled during computation\n%!" pid;
                      raise Lwt.Canceled
                    );
                    if x = 0 then (f, idx + 1)
                    else
                      let lit = Literal.create (Var ((idx * size) + x)) Positive in
                      (Cdcl.Formula.add_clause f @@ Cdcl.Clause.create [ lit ], idx + 1))
                  (Result.get_ok formula, 0)
                  (List.flatten int_grid)
              in
              if !cancelled then Error "Cancelled"
              else
                match RandomSolver.cdcl_solve formula with
                | `SAT assignment -> 
                    Printf.printf "[PID:%d] Solution found\n%!" pid;
                    Ok (bool_to_value size (Assignment.to_list assignment))
                | `UNSAT -> Error "Unsatisfiable")
          ()
        in
        Lwt.return result)
      (function
        | Lwt.Canceled ->
            Printf.printf "[PID:%d] Task cancelled\n%!" pid;
            cancelled := true;
            Lwt.return (Error "Cancelled")
        | e -> 
            Printf.printf "[PID:%d] Error: %s\n%!" pid (Printexc.to_string e);
            Lwt.fail e)
  in
  task

