type t

val create : Variable.t -> bool -> t
(** [create v p] creates a literal from a variable [v] and a polarity [p] *)

val value : t -> Assignment.t -> Assignment.value
(** [value l] returns the value of the literal [l] in the current assignment *)