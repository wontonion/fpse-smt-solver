open Core

(** A type for the polarity of a literal *)
type polarity = Positive | Negative [@@deriving sexp]

type t = { polarity : polarity; variable : Variable.t }

type comparator_witness
(** A witness type for the comparator *)

val comparator : (t, comparator_witness) Comparator.t
(** A comparator for literals *)

val create : Variable.t -> polarity -> t
(** [create v p] creates a literal with variable [v] and polarity [p] *)

val string_of_t : t -> string
(** [string_of_t l] returns a string representation of literal [l] *)

val neg : t -> t
(** [neg l] returns the negation of literal [l] *)

val equal : t -> t -> bool
(** [equal l1 l2] returns [true] if [l1] and [l2] are equal, [false] otherwise *)

val compare : t -> t -> int
(** [compare l1 l2] compares two literals [l1] and [l2] *)

val sexp_of_t : t -> Sexp.t
(** [sexp_of_t l] returns the sexp representation of literal [l] *)

val t_of_sexp : Sexp.t -> t
(** [t_of_sexp s] returns the literal represented by sexp [s] *)

val compare_polarity : polarity -> polarity -> int
(** [compare_polarity p1 p2] compares two polarities [p1] and [p2] *)

val bool_to_polarity : bool -> polarity
(** [bool_to_polarity b] returns the polarity corresponding to boolean [b] *)

val polarity_to_bool : polarity -> bool
(** [polarity_to_bool p] returns the boolean corresponding to polarity [p] *)
