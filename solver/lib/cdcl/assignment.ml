open Core

type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : (d Core.Map.M(Core.Int).t);}

let empty = { dl = 0; values = Map.empty (module Int) }

let value (a : t) (l : Literal.t) : bool option =
  let v = l.variable in
  match Map.find a.values v with
  | None -> None
  | Some { value; _ } -> if l.negation then Some (not value) else Some value

let antecedent (a : t) (v : int) : Clause.t option =
  match Map.find a.values v with
  | None -> None
  | Some { antecedent; _ } -> antecedent

let dl (a : t) (v : int) : int option =
  match Map.find a.values v with
  | None -> None
  | Some { dl; _ } -> Some dl

let assign (a : t) (v : int) (b : bool) (c : Clause.t option) : t =
  { a with values = Map.set a.values ~key:v ~data:{ value = b; antecedent = c; dl = a.dl }}

let unassign (a : t) (v : int) : t =
  { a with values = Map.remove a.values v}

let satisfy (a : t) (f : Formula.t) : bool =
  Formula.clauses f |> List.for_all ~f:(fun c ->
      List.exists (Clause.literals c) ~f:(fun l ->
          match value a l with
          | Some b -> b
          | None -> false))

let string_of_t (a : t) : string =
  Map.to_alist a.values
  |> List.map ~f:(fun (v, { value; antecedent; dl }) ->
      Printf.sprintf "v%d: %b, antecedent: %s, dl: %d" v value
        (match antecedent with
         | None -> "None"
         | Some c -> Clause.string_of_t c)
        dl)
  |> String.concat ~sep:"\n"