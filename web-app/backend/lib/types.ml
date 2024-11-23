(* type grid = int array array [@@deriving yojson] *)

type problem_type =
  | Boolean (** indicates SAT problem*)
  | Integer (** indicates SMT problem*)

let problem_type_to_yojson = function
  | Boolean -> `String "Boolean"
  | Integer -> `String "Integer"

let problem_type_of_yojson = function
  | `String "Boolean" -> Ok Boolean
  | `String "Integer" -> Ok Integer
  | _ -> Error "Invalid problem_type"

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

(* 通用响应类型 *)
type 'a response = {
  status: string;
  message: string;
  data: 'a option;
} [@@deriving yojson]
