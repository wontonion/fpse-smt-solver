open Cdcl
open Variable

let parse_formula (words : string list) (n_vars : int) (n_clauses : int) :
    (Formula.t, string) Result.t =
  let rec parse_single_clause (ls : Literal.t list) (words : string list)
      (n_vars : int) : (Clause.t * string list, string) Result.t =
    match words with
    | "0" :: ws -> Result.ok (Clause.create ls, ws)
    | w :: ws -> (
        let lit =
          match int_of_string_opt w with
          | Some v when v > 0 && v <= n_vars -> Ok (Literal.create (Var v) Positive)
          | Some v when v < 0 && -v <= n_vars ->
              Ok (Literal.create (Var (-v)) Negative)
          | _ -> Error "Invalid variable in clause"
        in
        match lit with
        | Ok l -> parse_single_clause (l :: ls) ws n_vars
        | Error msg -> Result.error msg)
    | [] -> Result.error "Invalid clause: missing terminating zero"
  in
  let rec parse_clauses (ls : Clause.t list) (words : string list)
      (n_vars : int) (n_clauses : int) : (Clause.t list, string) Result.t =
    match words with
    | [] when n_clauses = 0 -> Result.ok ls
    | [] when n_clauses > 0 -> Result.error "Too few clauses"
    | _ when n_clauses = 0 -> Result.error "Too many clauses"
    | _ -> (
        match parse_single_clause [] words n_vars with
        | Ok (c, ws) -> parse_clauses (c :: ls) ws n_vars (n_clauses - 1)
        | Error msg -> Result.error msg)
  in
  match parse_clauses [] words n_vars n_clauses with
  | Ok clauses -> Result.ok (Formula.create @@ List.rev clauses)
  | Error msg -> Result.error msg

let parse (s : string) : (Formula.t, string) Result.t =
  match Utils.list_words s with
  | p :: cnf :: n_vars :: n_clauses :: exp -> (
      if (not @@ String.equal p "p") || (not @@ String.equal cnf "cnf") then
        Result.error "Invalid DIMACS header"
      else
        let n_vars =
          match int_of_string_opt n_vars with
          | Some v when v > 0 -> Ok v
          | _ -> Error "Invalid number of variables"
        in
        let n_clauses =
          match int_of_string_opt n_clauses with
          | Some c when c > 0 -> Ok c
          | _ -> Error "Invalid number of clauses"
        in
        match (n_vars, n_clauses) with
        | Ok v, Ok c -> parse_formula exp v c
        | Error msg, _ -> Result.error msg
        | _, Error msg -> Result.error msg)
  | _ -> Result.error "Invalid DIMACS header"
