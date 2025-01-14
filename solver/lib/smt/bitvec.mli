type t = Cdcl.Variable.t list

val constant : (bool -> Cdcl.Variable.t) -> int -> t
(** [constant f n] returns a bitvector of constant [n], where [f] is a function that returns variables for the bits. *)

val value : Cdcl.Assignment.t -> t -> int
(** [value a v] returns the integer value of the bitvector [v] in the assignment [a]. *)
