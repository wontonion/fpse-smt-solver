open Core

type t = Clause.t list * Int.Set.t

let create (ls : Clause.t list) : t =
  let variables =
    List.fold_left ls ~init:Int.Set.empty ~f:(fun acc l ->
        Set.union acc (Clause.variables l))
  in
  (ls, variables)

let string_of_t ((ls, _) : t) : string =
  List.map ls ~f:(fun c -> "(" ^ Clause.string_of_t c ^ ")")
  |> String.concat ~sep:" ∧ "

let clauses ((ls, _) : t) : Clause.t list = ls
let variables ((_, vs) : t) : Int.Set.t = vs
