type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : d Core.Map.M(Core.Int).t }

val empty : t

val value : t -> Literal.t -> bool option
(** [value a l] returns the value of literal [l] in assignment [a] *)

val antecedent : t -> int -> Clause.t option
(** [antecedent a v] returns the antecedent of variable [v] in assignment [a] *)

val dl : t -> int -> int option
(** [dl a] returns the decision level of assignment [a] *)

val assign : t -> int -> bool -> Clause.t option -> t
(** [assign a v b c] assigns value [b] to variable [v] in assignment [a] with antecedent [c] *)

val unassign : t -> int -> t
(** [unassign a v] unassigns variable [v] in assignment [a] *)

val satisfy : t -> Formula.t -> bool
(** [satisfy a f] returns [true] if formula [f] is satisfied by assignment [a], [false] otherwise *)

val string_of_t : t -> string
(** [string_of_t a] returns a string representation of assignment [a] *)
