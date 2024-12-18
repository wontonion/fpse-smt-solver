type problem_type =
  | Sudoku
  | SAT
  | SMT

let problem_type_to_yojson = function
  | SAT -> `String "SAT"
  | SMT -> `String "SMT"
  | Sudoku -> `String "Sudoku"

let problem_type_of_yojson = function
  | `String "SAT" -> Ok SAT
  | `String "SMT" -> Ok SMT
  | `String "Sudoku" -> Ok Sudoku
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

type 'a json_body = {
  message: string;
  problem_type: problem_type;
  data: 'a option;
} [@@deriving yojson]

(* sat/smt problem data just string *)
type sat_smt_data = string [@@deriving yojson]