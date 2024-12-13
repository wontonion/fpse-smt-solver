open Core

type t = Clause.t list * Set.M(Variable).t

let create (ls : Clause.t list) : t =
  let variables =
    List.fold_left ls
      ~init:(Core.Set.empty (module Variable))
      ~f:(fun acc l -> Set.union acc (Clause.variables l))
  in
  (ls, variables)

let string_of_t ((ls, _) : t) : string =
  List.map ls ~f:(fun c -> "(" ^ Clause.string_of_t c ^ ")")
  |> String.concat ~sep:" & "

let clauses ((ls, _) : t) : Clause.t list = ls
let variables ((_, vs) : t) : Set.M(Variable).t = vs

let add_clause ((ls, vs) : t) (c : Clause.t) : t =
  (c :: ls, Set.union vs (Clause.variables c))
