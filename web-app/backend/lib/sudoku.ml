open Types

type grid = int list list

(* create empty grid *)
let create_empty_grid () : grid = 
  List.init 9 (fun _ -> List.init 9 (fun _ -> 0))

(* Helper functions for list operations *)
let get_row (grid: grid) (row: int) : int list =
  List.nth grid row

let get_col (grid: grid) (col: int) : int list =
  List.map (fun row -> List.nth row col) grid

let get_block (grid: grid) (row: int) (col: int) : int list =
  let start_row = (row / 3) * 3 in
  let start_col = (col / 3) * 3 in
  List.init 9 (fun i ->
    let r = start_row + (i / 3) in
    let c = start_col + (i mod 3) in
    List.nth (List.nth grid r) c
  )

(* Update a value in a list at given index *)
let list_update (lst: 'a list) (index: int) (value: 'a) : 'a list =
  List.mapi (fun i x -> if i = index then value else x) lst

(* Update grid at position *)
let update_grid (grid: grid) (row: int) (col: int) (value: int) : grid =
  list_update grid row (list_update (List.nth grid row) col value)

(* Validation functions *)
let is_valid_in_list nums value =
  not (List.exists ((=) value) nums) || value = 0

let is_valid (grid: grid) (row: int) (col: int) (num: int) : bool =
  let row_valid = is_valid_in_list (get_row grid row) num in
  let col_valid = is_valid_in_list (get_col grid col) num in
  let block_valid = is_valid_in_list (get_block grid row col) num in
  row_valid && col_valid && block_valid

(* Find first empty position *)
let find_empty (grid: grid) : (int * int) option =
  let rec find_in_row row col =
    if row >= 9 then None
    else if col >= 9 then find_in_row (row + 1) 0
    else if List.nth (List.nth grid row) col = 0 then Some (row, col)
    else find_in_row row (col + 1)
  in
  find_in_row 0 0

(* Solve sudoku recursively and return the number of solutions found *)
let rec solve_and_count (grid: grid) (max_solutions: int) : int =
  if max_solutions = 0 then 0
  else match find_empty grid with
    | None -> 
        Printf.printf "Found solution\n";
        1
    | Some (row, col) ->
        let rec try_numbers num acc =
          if num > 9 || acc >= max_solutions then acc
          else if is_valid grid row col num then
            let new_grid = update_grid grid row col num in
            let solutions = solve_and_count new_grid (max_solutions - acc) in
            try_numbers (num + 1) (acc + solutions)
          else
            try_numbers (num + 1) acc
        in
        try_numbers 1 0

(* 添加一个辅助函数来填充完整的数独 *)
let rec solve_grid (grid: grid) : grid option =
  match find_empty grid with
  | None -> Some grid  (* 找到解决方案 *)
  | Some (row, col) ->
      let numbers = List.init 9 (fun i -> i + 1) in
      (* 随机打乱1-9的顺序，增加随机性 *)
      let shuffled = List.sort (fun _ _ -> Random.int 3 - 1) numbers in
      let rec try_numbers = function
        | [] -> None
        | num :: rest ->
            if is_valid grid row col num then
              match solve_grid (update_grid grid row col num) with
              | Some solution -> Some solution
              | None -> try_numbers rest
            else try_numbers rest
      in
      try_numbers shuffled

(* 改进的生成算法 *)
let generate_puzzle () : grid =
  Random.self_init ();
  
  let solved_grid = 
    match solve_grid (create_empty_grid ()) with
    | Some grid -> grid
    | None -> failwith "Failed to generate a complete grid"
  in
  
  let positions = List.init 81 (fun i -> (i / 9, i mod 9)) in
  let shuffled_positions = 
    List.sort (fun _ _ -> Random.int 3 - 1) positions in
  
  let rec remove_numbers grid positions removed =
    match positions with
    | [] -> 
        Printf.printf "No more positions to try, removed %d numbers\n" removed;
        grid
    | (row, col) :: rest ->
        if removed >= 50 then 
          (Printf.printf "Target reached: removed %d numbers\n" removed;
           grid)
        else begin
          Printf.printf "Trying to remove at (%d,%d)\n" row col;
          let new_grid = update_grid grid row col 0 in
          let solutions = solve_and_count new_grid 2 in
          Printf.printf "Position (%d,%d) has %d solutions\n" row col solutions;
          if solutions = 1 then
            remove_numbers new_grid rest (removed + 1)
          else
            remove_numbers grid rest removed
        end
  in
  
  remove_numbers solved_grid shuffled_positions 0

(* Print board *)
let print_board (grid: grid) : unit =
  List.iteri (fun i row ->
    if i mod 3 = 0 && i <> 0 then
      print_endline "---------------------";
    List.iteri (fun j num ->
      if j mod 3 = 0 && j <> 0 then
        print_string "| ";
      if num = 0 then
        print_string ". "
      else
        Printf.printf "%d " num
    ) row;
    print_newline ()
  ) grid


let convert_to_sudoku_data (grid: grid) : sudoku_data =
  let convert_cell value =
    { value = if value = 0 then "" else string_of_int value;
      is_initial = value <> 0;
      is_valid = true;
    }
  in
  {
    size = 9;
    grid = List.map (fun row ->
      List.map convert_cell row
    ) grid
  }

let generate_puzzle_with_timeout ?(timeout=2.0) () : grid =
  let start_time = Unix.gettimeofday () in
  
  let rec try_generate () =
    if Unix.gettimeofday () -. start_time > timeout then
      raise (Failure "Timeout while generating puzzle")
    else
      try 
        generate_puzzle ()
      with _ -> try_generate ()
  in
  try_generate ()