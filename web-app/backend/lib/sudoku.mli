open Types

type grid = int list list

val create_empty_grid : block_size:int -> unit -> grid
val get_row : grid -> int -> int list
val get_col : grid -> int -> int list
val get_block : grid -> int -> int -> block_size:int -> int list
val update_grid : grid -> int -> int -> int -> grid
val is_valid : grid -> int -> int -> int -> block_size:int -> bool
val find_empty : grid -> block_size:int -> (int * int) option
val solve_and_count : grid -> int -> block_size:int -> int
val solve_grid : grid -> block_size:int -> grid option
val generate_puzzle : block_size:int -> unit -> grid
val print_board : grid -> unit
val convert_to_sudoku_data : grid -> sudoku_data
val convert_frontend_grid : Yojson.Safe.t -> sudoku_data
val solve_sudoku : grid -> int -> (int list list, string) Result.t

