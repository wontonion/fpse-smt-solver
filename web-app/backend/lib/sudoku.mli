open Types

type grid = int list list

val create_empty_grid : unit -> grid
(** create an empty grid *)
(** TODO accept different size(int) of grid *)

val get_row : grid -> int -> int list
(** get a row from the grid *)

val get_col : grid -> int -> int list
(** get a column from the grid *)

val get_block : grid -> int -> int -> int list
(** get a 3x3 block from the grid *)

val update_grid : grid -> int -> int -> int -> grid
(** update a value in the grid *)

val is_valid : grid -> int -> int -> int -> bool
(** check if the number is valid in the grid *)

val generate_puzzle : unit -> grid
(** generate a puzzle *)

val print_board : grid -> unit 
(** print the grid *)

val convert_to_sudoku_data : grid -> sudoku_data
(** convert the grid to sudoku_data *)

val generate_puzzle_with_timeout : ?timeout:float -> unit -> grid
(** generate a puzzle with a timeout *)
