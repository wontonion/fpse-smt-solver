open Core

[@@@coverage off]

module T = struct
  type t = Literal.t list [@@deriving sexp]

  let compare (c1 : t) (c2 : t) : int = List.compare Literal.compare c1 c2
end

[@@@coverage on]

include T
include Comparable.Make (T)

let create (ls : Literal.t list) : t =
  List.dedup_and_sort ls ~compare:Literal.compare

let string_of_t (c : t) : string =
  String.concat ~sep:" | " (List.map ~f:Literal.string_of_t c)

let literals (c : t) : Literal.t list = c

open! Core

let variables (c : t) : Int.Set.t =
  List.fold_left c ~init:Int.Set.empty ~f:(fun acc l ->
      Set.add acc (Literal.variable l))

let equal (c1 : t) (c2 : t) : bool = List.equal Literal.equal c1 c2
