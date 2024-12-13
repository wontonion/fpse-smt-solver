open Core

module T = struct
  type polarity = Positive | Negative [@@deriving sexp, equal, compare]

  type t = { polarity : polarity; variable : Variable.t }
  [@@deriving sexp, equal]

  let compare (l1 : t) (l2 : t) : int =
    let v1 = match l1.variable with Variable.Var i -> i in
    let v2 = match l2.variable with Variable.Var i -> i in
    let v1' = match l1.polarity with Positive -> v1 | Negative -> -v1 in
    let v2' = match l2.polarity with Positive -> v2 | Negative -> -v2 in
    Int.compare v1' v2'
end

include T
include Comparable.Make (T)

let create (v : Variable.t) (p : polarity) : t = { variable = v; polarity = p }

let string_of_t (l : t) : string =
  let sign = match l.polarity with Positive -> "" | Negative -> "-" in
  sign ^ Variable.string_of_t l.variable

let neg (l : t) : t =
  match l.polarity with
  | Positive -> { l with polarity = Negative }
  | Negative -> { l with polarity = Positive }

let bool_to_polarity (b : bool) : polarity = if b then Positive else Negative

let polarity_to_bool (p : polarity) : bool =
  match p with Positive -> true | Negative -> false
