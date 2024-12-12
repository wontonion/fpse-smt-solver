open Core

type t = { variable : int; negation : bool } [@@deriving sexp]

type comparator_witness
(** A witness type for the comparator *)

val comparator : (t, comparator_witness) Comparator.t
(** A comparator for literals *)

val create : int -> bool -> t
(** [create v n] creates a literal from a variable [v] and a negation [n] *)

val string_of_t : t -> string
(** [string_of_t l] returns a string representation of literal [l] *)

val neg : t -> t
(** [neg l] returns the negation of literal [l] *)

val equal : t -> t -> bool
(** [equal l1 l2] returns [true] if [l1] and [l2] are equal, [false] otherwise *)

val variable : t -> int
(** [variable l] returns the variable of literal [l] *)

val compare : t -> t -> int
(** [compare l1 l2] compares two literals [l1] and [l2] *)
