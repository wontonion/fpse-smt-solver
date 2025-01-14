open Core

module T = struct
  type t = Var of int [@@unboxed] [@@deriving sexp, compare, equal]
end

include T
include Comparable.Make (T)

let string_of_t (v : t) : string = match v with Var i -> Int.to_string i
