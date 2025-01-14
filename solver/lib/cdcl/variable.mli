open Core

type t = Var of int [@@ unboxed]
(** A variable is represented by an integer *)
type comparator_witness

val comparator : (t, comparator_witness) Comparator.t

val compare : t -> t -> int
(** [compare v1 v2] compares two variables [v1] and [v2] *)

val equal : t -> t -> bool
(** [equal v1 v2] checks if two variables [v1] and [v2] are equal *)

val sexp_of_t : t -> Sexp.t
(** [sexp_of_t v] returns the sexp representation of variable [v] *)

val t_of_sexp : Sexp.t -> t
(** [t_of_sexp s] returns the variable represented by sexp [s] *)

val string_of_t : t -> string
(** [string_of_t v] returns a string representation of variable [v] *)
