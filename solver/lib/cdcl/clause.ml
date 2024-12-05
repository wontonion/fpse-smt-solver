open Core

type t = Literal.t list

let create (ls : Literal.t list) : t =
  List.dedup_and_sort ls ~compare:Literal.compare

let string_of_t (c : t) : string =
  String.concat ~sep:" | " (List.map ~f:Literal.string_of_t c)

let literals (c : t) : Literal.t list = c

let variables (c : t) : Int.Set.t =
  List.fold_left c ~init:Int.Set.empty ~f:(fun acc l ->
      Set.add acc (Literal.variable l))

let equal (c1 : t) (c2 : t) : bool = List.equal Literal.equal c1 c2
