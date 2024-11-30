type problem_type =
  | Sudoku
  | SAT
  | SMT

let problem_type_to_yojson = function
  | SAT -> `String "SAT"
  | SMT -> `String "SMT"
  | Sudoku -> `String "sudoku"

let problem_type_of_yojson = function
  | `String "SAT" -> Ok SAT
  | `String "SMT" -> Ok SMT
  | `String "sudoku" -> Ok Sudoku
  | _ -> Error "Invalid problem_type"

type sudoku_cell = {
  value: string;
  is_initial: bool;
  is_valid: bool;
} [@@deriving yojson]

type sudoku_data = {
  size: int;
  grid: sudoku_cell list list;
} [@@deriving yojson]

type problem = {
  problem_type: problem_type;
  constraints: string list;
  variables: string list;
} [@@deriving yojson]

type solution = {
  problem_type: problem_type;
  assignments: (string * string) list option;
  time_taken: float;
} [@@deriving yojson]

type 'a response = {
  status: string;
  message: string;
  data: 'a option;
} [@@deriving yojson]
