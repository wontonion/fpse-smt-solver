type t
type value = Positive | Negative | Absent

val create : unit -> t
(** [create ()] creates a new assignment *)

val set : t -> Variable.t -> value -> t
(** [set a v v'] returns a new assignment where the value of variable [v] is [v'] *)

val get : t -> Variable.t -> value
(** [get a v] returns the value of variable [v] in assignment [a] *)