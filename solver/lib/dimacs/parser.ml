open Cdcl
open Variable

let parse_formula (words : string list) (n_vars : int) (n_clauses : int) :
    Formula.t =
  let rec parse_single_clause (ls : Literal.t list) (words : string list)
      (n_vars : int) : Clause.t * string list =
    match words with
    | "0" :: ws -> (Clause.create ls, ws)
    | w :: ws ->
        let lit =
          match int_of_string w with
          | v when v > 0 && v <= n_vars -> Literal.create (Var v) Positive
          | v when v < 0 && -v <= n_vars -> Literal.create (Var (-v)) Negative
          | _ -> failwith "Invalid variable in clause"
        in
        parse_single_clause (lit :: ls) ws n_vars
    | [] -> failwith "Invalid clause: missing terminating zero"
  in
  let rec parse_clauses (ls : Clause.t list) (words : string list)
      (n_vars : int) (n_clauses : int) : Clause.t list =
    match words with
    | [] when n_clauses = 0 -> ls
    | [] when n_clauses > 0 -> failwith "Too few clauses"
    | _ when n_clauses = 0 -> failwith "Too many clauses"
    | _ ->
        let c, ws = parse_single_clause [] words n_vars in
        parse_clauses (c :: ls) ws n_vars (n_clauses - 1)
  in
  let clauses = parse_clauses [] words n_vars n_clauses in
  Formula.create @@ List.rev clauses

let parse (s : string) : Formula.t =
  match Utils.list_words s with
  | p :: cnf :: n_vars :: n_clauses :: exp ->
      if (not @@ String.equal p "p") || (not @@ String.equal cnf "cnf") then
        failwith "Invalid DIMACS header"
      else
        let n_vars =
          match int_of_string n_vars with
          | v when v > 0 -> v
          | _ -> failwith "Invalid number of variables"
        in
        let n_clauses =
          match int_of_string n_clauses with
          | c when c > 0 -> c
          | _ -> failwith "Invalid number of clauses"
        in
        parse_formula exp n_vars n_clauses
  | _ -> failwith "Invalid DIMACS header"
