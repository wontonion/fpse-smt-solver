open Core

module T = struct
  [@@@coverage off]

  type t = Literal.t list [@@deriving sexp, compare, equal, hash]

  [@@@coverage on]
end

include T
include Comparable.Make (T)

let create (ls : Literal.t list) : t =
  List.dedup_and_sort ls ~compare:Literal.compare

let string_of_t (c : t) : string =
  String.concat ~sep:" | " (List.map ~f:Literal.string_of_t c)

let literals (c : t) : Literal.t list = c

let variables (c : t) : Core.Set.M(Variable).t =
  List.fold_left c
    ~init:(Core.Set.empty (module Variable))
    ~f:(fun acc l -> Core.Set.add acc l.variable)
