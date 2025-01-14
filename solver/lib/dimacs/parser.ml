open Core
open Core.Result.Let_syntax
open Cdcl
open Variable

let parse_formula (words : string list) (n_vars : int) (n_clauses : int) :
    (Formula.t, string) Result.t =
  let rec parse_single_clause (ls : Literal.t list) (words : string list)
      (n_vars : int) : (Clause.t * string list, string) Result.t =
    match words with
    | "0" :: ws -> Ok (Clause.create ls, ws)
    | w :: ws ->
        let%bind v =
          Result.of_option (int_of_string_opt w)
            ~error:"Invalid variable in clause"
        in
        let%bind literal =
          match v with
          | v when v > 0 && v <= n_vars -> Ok (Literal.create (Var v) Positive)
          | v when v < 0 && -v <= n_vars ->
              Ok (Literal.create (Var (-v)) Negative)
          | _ -> Error "Invalid variable in clause"
        in
        parse_single_clause (literal :: ls) ws n_vars
    | [] -> Result.fail "Invalid clause: missing terminating zero"
  in
  let rec parse_clauses (ls : Clause.t list) (words : string list)
      (n_vars : int) (n_clauses : int) : (Clause.t list, string) Result.t =
    match words with
    | [] when n_clauses = 0 -> Ok ls
    | [] when n_clauses > 0 -> Error "Too few clauses"
    | _ when n_clauses = 0 -> Error "Too many clauses"
    | _ -> (
        match parse_single_clause [] words n_vars with
        | Ok (c, ws) -> parse_clauses (c :: ls) ws n_vars (n_clauses - 1)
        | Error msg -> Result.fail msg)
  in
  match parse_clauses [] words n_vars n_clauses with
  | Ok clauses -> Result.return (Formula.create @@ List.rev clauses)
  | Error msg -> Result.fail msg

let parse (s : string) : (Formula.t, string) Result.t =
  let positive_int_of_string_opt (s : string) : int option =
    match int_of_string_opt s with Some n when n > 0 -> Some n | _ -> None
  in
  match Utils.list_words s with
  | "p" :: "cnf" :: n_vars :: n_clauses :: exp ->
      let%bind n_vars =
        Result.of_option
          (positive_int_of_string_opt n_vars)
          ~error:"Invalid number of variables"
      in
      let%bind n_clauses =
        Result.of_option
          (positive_int_of_string_opt n_clauses)
          ~error:"Invalid number of clauses"
      in
      parse_formula exp n_vars n_clauses
  | _ -> Error "Invalid DIMACS header"
