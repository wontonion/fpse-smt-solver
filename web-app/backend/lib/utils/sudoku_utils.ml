open Core
open Utils_types
open Cdcl
open Cdcl.Variable

type int_grid = int list list

let sudoku_block_sizes = [ 2; 3 ]

(* create empty grid *)
let create_empty_grid ~block_size : int_grid =
  let size = block_size * block_size in
  List.init size ~f:(fun _ -> List.init size ~f:(fun _ -> 0))

(* Helper functions for list operations *)
let get_row (grid : int_grid) (row : int) : int list = List.nth_exn grid row

let get_col (grid : int_grid) (col : int) : int list =
  List.map ~f:(fun row -> List.nth_exn row col) grid
(* if col < 0 || List.is_empty grid then []
  else
    let first_row = List.hd_exn grid in
    if col >= List.length first_row then []
    else
      List.fold_right
        ~f:(fun row acc -> List.nth_exn row col :: acc)
        ~init:[] grid *)

let get_block (grid : int_grid) (row : int) (col : int) ~block_size : int list =
  let size = block_size * block_size in
  let start_row = row / block_size * block_size in
  let start_col = col / block_size * block_size in
  List.init size ~f:(fun i ->
      let r = start_row + (i / block_size) in
      let c = start_col + (i mod block_size) in
      List.nth_exn (List.nth_exn grid r) c)

(* Update a value in a list at given index *)
let list_update (ls : 'a list) (index : int) (value : 'a) : 'a list =
  List.mapi ~f:(fun i x -> if i = index then value else x) ls
(* if index < 0 then ls
  else
    let rec update_aux acc rest i =
      match rest with
      | [] -> List.rev acc
      | x :: xs ->
          if i = 0 then List.rev_append acc (value :: xs)
          else update_aux (x :: acc) xs (i - 1)
    in
    update_aux [] ls 0 *)

(* Update grid at position *)
let update_grid (grid : int_grid) (row : int) (col : int) (value : int) : int_grid =
  list_update grid row (list_update (List.nth_exn grid row) col value)

(* Validation functions *)
let is_valid_in_list nums value =
  value = 0 || not (List.mem nums value ~equal:Int.equal)

let is_valid (grid : int_grid) (row : int) (col : int) (num : int) ~block_size :
    bool =
  let row_valid = is_valid_in_list (get_row grid row) num in
  let col_valid = is_valid_in_list (get_col grid col) num in
  let block_valid = is_valid_in_list (get_block grid row col ~block_size) num in
  row_valid && col_valid && block_valid

(* Find first empty position *)
let find_empty (grid : int_grid) ~block_size : (int * int) option =
  let size = block_size * block_size in
  let rec find_in_row row col =
    if row >= size then None
    else if col >= size then find_in_row (row + 1) 0
    else if List.nth_exn (List.nth_exn grid row) col = 0 then Some (row, col)
    else find_in_row row (col + 1)
  in
  find_in_row 0 0



(* find the initial solved grid *)
let rec create_complete_grid (grid : int_grid) ~block_size : int_grid option =
  match find_empty grid ~block_size with
  | None -> Some grid
  | Some (row, col) ->
      let size = block_size * block_size in
      let numbers = List.init size ~f:(fun i -> i + 1) in
      let shuffled = List.sort ~compare:(fun _ _ -> (Random.int 3) - 1) numbers in
      let rec try_numbers = function
        | [] -> None
        | num :: rest ->
            if is_valid grid row col num ~block_size then
              match create_complete_grid (update_grid grid row col num) ~block_size with
              | Some solution -> Some solution
              | None -> try_numbers rest
            else try_numbers rest
    in
    try_numbers shuffled

(* Solve sudoku recursively and return the number of solutions found *)
(* this is for guaranteeing the uniqueness of the solution *)
let rec count_solution (grid : int_grid) (max_solutions : int) ~block_size : int =
  if max_solutions = 0 then 0
  else
    match find_empty grid ~block_size with
    | None -> 1
    | Some (row, col) ->
        let size = block_size * block_size in
        let rec try_numbers num acc =
          if num > size || acc >= max_solutions then 
            acc
          else if is_valid grid row col num ~block_size then
            let new_grid = update_grid grid row col num in
            let solutions = count_solution new_grid (max_solutions - acc) ~block_size
            in
            try_numbers (num + 1) (acc + solutions)
          else 
            try_numbers (num + 1) acc
        in
        try_numbers 1 0



(* Improved generation algorithm *)
let generate_puzzle ~block_size : int_grid =
  if not (List.mem sudoku_block_sizes block_size ~equal:Int.equal) then
    failwith "Block size must be either 2 or 3";

  Random.self_init ();

  let solved_grid =
    match create_complete_grid (create_empty_grid ~block_size) ~block_size with
    | Some grid -> grid
    | None -> failwith "Failed to generate a complete grid"
  in
  (* generate the positions and shuffle them 
  this is potential position of removed numbers *)
  let size = block_size * block_size in
  let total_cells = size * size in
  let positions = List.init total_cells ~f:(fun i -> (i / size, i mod size)) in
  let shuffled_positions =
    List.sort ~compare:(fun _ _ -> Random.int 3 - 1) positions
  in

  (* remove about half of the numbers *)
  let target_removed = (total_cells / 2) + (total_cells / 20) in

  let rec remove_numbers grid positions removed =
    match positions with
    | [] -> grid
    | (row, col) :: rest ->
        if removed >= target_removed then 
          grid
        else
          let new_grid = update_grid grid row col 0 in
          let solutions = count_solution new_grid 2 ~block_size in
          if solutions = 1 then 
            remove_numbers new_grid rest (removed + 1)
          else 
            remove_numbers grid rest removed
  in
  remove_numbers solved_grid shuffled_positions 0

let to_int_grid (grid : sudoku_cell list list) : int list list =
  List.map grid ~f:(fun row ->
      List.map row ~f:(fun cell ->
          if cell.Utils_types.is_initial then
            match cell.Utils_types.value with
            | "" -> 0
            | s -> ( try int_of_string s with _ -> 0)
          else 0))

let merge_grid_with_initial (grid : int_grid) (initial_grid : sudoku_cell list list)
    : sudoku_cell list list =
  List.zip_exn grid initial_grid
  |> List.map ~f:(fun (solved_row, orig_row) ->
         List.zip_exn solved_row orig_row
         |> List.map ~f:(fun (solved_val, orig_cell) ->
                {
                  Utils_types.value = string_of_int solved_val;
                  Utils_types.is_initial = orig_cell.Utils_types.is_initial;
                  Utils_types.is_valid = true;
                }))

(* convert the grid to the sudoku data *)
let to_frontend_sudoku_data (grid) =
  let convert_cell value =
    {
      value = (if value = 0 then "" else string_of_int value);
      is_initial = value <> 0;
      is_valid = true;
    }
  in
  {
    size = List.length grid;
    grid = List.map ~f:(fun row -> List.map ~f:convert_cell row) grid;
  }

let to_backend_sudoku_cell json =
  let open Yojson.Safe.Util in
  {
    Utils_types.value = member "value" json |> to_string;
    Utils_types.is_initial = member "isInitial" json |> to_bool;
    Utils_types.is_valid = member "isValid" json |> to_bool;
  }

let to_backend_sudoku_data json =
  let open Yojson.Safe.Util in
  let size = member "size" json |> to_int in
  let grid =
    member "grid" json 
    |> to_list
    |> List.map ~f:(fun row -> to_list row |> List.map ~f:to_backend_sudoku_cell)
  in
  { Utils_types.size; 
    Utils_types.grid }

[@@@coverage off]
let get_sudoku_formula size =
  let open Core.In_channel in
  match size with
  | 9 ->
      Dimacs.Parser.parse @@ read_all "data/sudoku.3x3.cnf"
      |> Result.ok_or_failwith
  | 4 ->
      Dimacs.Parser.parse @@ read_all "data/sudoku.2x2.cnf"
      |> Result.ok_or_failwith
  | _ -> failwith "Invalid grid size"
[@@@coverage on]

let rec bool_ls_to_int_ls (size : int) (ls : bool list) : int list =
  match ls with
  | [] -> []
  | _ ->
      let open Core in
      let vs, ls = List.split_n ls size in
      let value, _ =
        List.fold_left 
          vs 
          ~init:(0, 1) 
          ~f:(fun (res, num) x ->
              if x then (num, num + 1) else (res, num + 1))
      in
      value :: bool_ls_to_int_ls size ls

[@@@coverage off]
module RandomSolver = Solver.Make (Heuristic.Randomized)

let solve_sudoku (int_grid : int list list) (size : int) :
    (int list list, string) Result.t =
  let grids = List.concat int_grid in
  let formula =
    match size with
    | 4 when List.length grids = 16 -> Ok (get_sudoku_formula 4)
    | 9 when List.length grids = 81 -> Ok (get_sudoku_formula 9)
    | _ -> Error "Invalid grid size"
  in
  formula
  |> Result.bind ~f:(fun initial_formula ->
         let formula, _ =
           List.fold_left ~init:(initial_formula, 0)
             ~f:(fun (f, idx) x ->
               match x with
               | 0 -> (f, idx + 1)
               | _ ->
                   let lit = Literal.create (Var ((idx * size) + x)) Positive in
                   ( Cdcl.Formula.add_clause f @@ Cdcl.Clause.create [ lit ],
                     idx + 1 ))
             grids
         in
         match RandomSolver.cdcl_solve formula with
         | `SAT assignment ->
             Ok
               (assignment 
               |> Assignment.to_list 
               |> bool_ls_to_int_ls size
               |> List.chunks_of ~length:size)
         | `UNSAT -> Error "Unsatisfiable")
[@@@coverage on]
