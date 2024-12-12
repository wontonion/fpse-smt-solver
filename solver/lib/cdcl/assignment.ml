open Core

type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : d Core.Map.M(Variable).t }

let empty = { dl = 0; values = Map.empty (module Variable) }

let value_of_literal (a : t) (l : Literal.t) : bool option =
  let v = l.variable in
  match Map.find a.values v with
  | None -> None
  | Some { value; _ } -> (
      match l.polarity with
      | Positive -> Some value
      | Negative -> Some (not value))

let value_of_variable (a : t) (v : Variable.t) : bool option =
  match Map.find a.values v with
  | None -> None
  | Some { value; _ } -> Some value

let is_assigned (a : t) (v : Variable.t) : bool =
  match Map.find a.values v with None -> false | Some _ -> true

let antecedent (a : t) (v : Variable.t) : Clause.t option =
  match Map.find a.values v with
  | None -> None
  | Some { antecedent; _ } -> antecedent

let dl (a : t) (v : Variable.t) : int option =
  match Map.find a.values v with None -> None | Some { dl; _ } -> Some dl

let assign (a : t) (v : Variable.t) (b : bool) (c : Clause.t option) : t =
  {
    a with
    values =
      Map.set a.values ~key:v ~data:{ value = b; antecedent = c; dl = a.dl };
  }

let unassign (a : t) (v : Variable.t) : t =
  { a with values = Map.remove a.values v }

let satisfy (a : t) (f : Formula.t) : bool =
  Formula.clauses f
  |> List.for_all ~f:(fun c ->
         List.exists (Clause.literals c) ~f:(fun l ->
             match value_of_literal a l with Some b -> b | None -> false))

let string_of_t (a : t) : string =
  Map.to_alist a.values
  |> List.map ~f:(fun (v, { value; _ }) ->
         let sign = if value then "" else "-" in
         Printf.sprintf "%s%s" sign (Variable.string_of_t v))
  |> String.concat ~sep:" "
