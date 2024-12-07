type t

val create : int * int -> t
(** [create (n, m)] creates a new bitvector of size [n] and initializes it with [m] *)

val size : t -> int
(** [size bv] returns the size of the bitvector [bv] *)

val add : t -> int -> t
(** [add bv v] adds the value [v] to the bitvector [bv] *)

val neg : t -> t
(** [neg bv] returns the negation of the bitvector [bv] *)

val multiply : t -> int -> t
(** [multiply bv v] multiplies the bitvector [bv] by the value [v] *)

val greater_than : t -> int -> Cdcl.Literal.t list
(** [greater_than bv v] returns a list of literals that represent the constraint [bv > v] *)

val less_than : t -> int -> Cdcl.Literal.t list
(** [less_than bv v] returns a list of literals that represent the constraint [bv < v] *)