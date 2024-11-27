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

(* Solve sudoku recursively *)
let rec solve_and_count (grid: grid) (count: int ref) (max_solutions: int) : unit =
  if !count >= max_solutions then ()
  else match find_empty grid with
    | None -> incr count
    | Some (row, col) ->
        List.iter (fun num ->
          if is_valid grid row col num then begin
            let new_grid = update_grid grid row col num in
            solve_and_count new_grid count max_solutions;
            if !count < max_solutions then
              solve_and_count (update_grid grid row col 0) count max_solutions
          end
        ) (List.init 9 (fun i -> i + 1))

(* Generate puzzle *)
let generate_puzzle () : grid =
  let initial_grid = create_empty_grid () in
  
  (* Fill random cells *)
  let rec fill_random_cells grid count =
    if count = 0 then grid
    else 
      let row = Random.int 9 in
      let col = Random.int 9 in
      let num = Random.int 9 + 1 in
      if List.nth (List.nth grid row) col = 0 && is_valid grid row col num then
        fill_random_cells (update_grid grid row col num) (count - 1)
      else
        fill_random_cells grid count
  in
  
  (* Check for unique solution *)
  let has_unique_solution grid =
    let count = ref 0 in
    solve_and_count grid count 2;
    !count = 1
  in
  
  let filled_grid = fill_random_cells initial_grid 17 in
  
  (* Remove numbers while maintaining unique solution *)
  let positions = List.init 81 (fun i -> (i / 9, i mod 9)) in
  let shuffled_positions = 
    List.sort (fun _ _ -> Random.int 3 - 1) positions in
  
  List.fold_left (fun grid (row, col) ->
    let current = List.nth (List.nth grid row) col in
    if current = 0 then grid
    else 
      let new_grid = update_grid grid row col 0 in
      if has_unique_solution new_grid then new_grid
      else update_grid grid row col current
  ) filled_grid shuffled_positions

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