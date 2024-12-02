type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : d Map.Make(Int).t }

module IntMap = Map.Make (Int)

let empty = { dl = 0; values = IntMap.empty }

let value (a : t) (l : Literal.t) : bool =
  let v = l.variable in
  match IntMap.find v a.values with
  | { value; _ } -> if l.negation then not value else value

let assign (a : t) (v : int) (b : bool) (c : Clause.t option) : t =
  { a with values = IntMap.add v { value = b; antecedent = c; dl = a.dl } a.values }

let unassign (a : t) (v : int) : t =
  { a with values = IntMap.remove v a.values }

let satisfy (a : t) (f : Formula.t) : bool =
  Formula.clauses f |> List.for_all (fun c -> Clause.literals c |> List.exists (fun l -> value a l))
