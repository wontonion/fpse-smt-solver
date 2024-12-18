open Utils_types

type grid = int list list

val sudoku_block_sizes : int list

val create_empty_grid : block_size:int -> grid

(* get the row of the grid *)
val get_row : grid -> int -> int list
(* get the column of the grid *)
val get_col : grid -> int -> int list
(* get the block of the grid *)
val get_block : grid -> int -> int -> block_size:int -> int list
(* update the grid *)
val update_grid : grid -> int -> int -> int -> grid
(* check if the number is valid in col/row/block *)
val is_valid : grid -> int -> int -> int -> block_size:int -> bool
(* find the empty cell *)
val find_empty : grid -> block_size:int -> (int * int) option
(* solve the sudoku and count the number of solutions *)
val count_solution : grid -> int -> block_size:int -> int
(* solve the sudoku *)
val solve_grid : grid -> block_size:int -> grid option
(* generate the sudoku puzzle *)
val generate_puzzle : block_size:int -> grid
(* convert the sudoku data to the frontend data *)
val convert_to_sudoku_data : grid -> sudoku_data
(* convert the frontend data to the sudoku data *)
val convert_frontend_grid : Yojson.Safe.t -> sudoku_data
(* convert the frontend grid to the int grid *)
val convert_frontend_grid_to_int_grid : sudoku_cell list list -> grid

(* merge the grid with the initial grid *)
val merge_grid_with_initial: grid -> sudoku_cell list list -> sudoku_cell list list

(* convert the bool to the value *)
val bool_to_value : int -> bool list -> int list
(* split the list into sublists *)
val split_into_sublists : int -> int list -> int list list

(* solve the sudoku *)
val solve_sudoku : grid -> int -> (int list list, string) Result.t

