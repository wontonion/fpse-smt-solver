open Utils_types

type int_grid = int list list

val sudoku_block_sizes : int list

val create_empty_grid : block_size:int -> int_grid

(* get the row of the grid *)
val get_row : int_grid -> int -> int list
(* get the column of the grid *)
val get_col : int_grid -> int -> int list
(* get the block of the grid *)
val get_block : int_grid -> int -> int -> block_size:int -> int list
(* update the grid *)
val update_grid : int_grid -> int -> int -> int -> int_grid
(* check if the number is valid in col/row/block *)
val is_valid : int_grid -> int -> int -> int -> block_size:int -> bool
(* find the empty cell *)
val find_empty : int_grid -> block_size:int -> (int * int) option
(* solve the sudoku and count the number of solutions *)
val count_solution : int_grid -> int -> block_size:int -> int
(* solve the sudoku *)
val create_complete_grid : int_grid -> block_size:int -> int_grid option
(* generate the sudoku puzzle *)
val generate_puzzle : block_size:int -> int_grid
(* convert the sudoku data to the frontend data *)
val to_frontend_sudoku_data : int_grid -> sudoku_data
(* convert the frontend data to the sudoku data *)
val to_backend_sudoku_data : Yojson.Safe.t -> sudoku_data
(* convert the frontend grid to the int grid *)
val to_int_grid : sudoku_cell list list -> int_grid

(* merge the grid with the initial grid *)
val merge_grid_with_initial: int_grid -> sudoku_cell list list -> sudoku_cell list list

(* convert the bool to the value *)
val bool_ls_to_int_ls : int -> bool list -> int list


(* solve the sudoku *)
val solve_sudoku : int_grid -> int -> (int list list, string) Result.t

