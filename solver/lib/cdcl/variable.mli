type t

val create : string -> t
(** [create n] creates a new variable with name [n] *)

val name : t -> string
(** [name v] returns the name of variable [v] *)