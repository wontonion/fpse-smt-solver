type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : (d Map.Make(Int).t);}

val empty : t

val value : t -> Literal.t -> bool
(** [value a l] returns the value of literal [l] in assignment [a] *)

val assign : t -> int -> bool -> Clause.t option -> t
(** [assign a v b c] assigns value [b] to variable [v] in assignment [a] with antecedent [c] *)

val unassign : t -> int -> t
(** [unassign a v] unassigns variable [v] in assignment [a] *)

val satisfy : t -> Formula.t -> bool
(** [satisfy a f] returns [true] if formula [f] is satisfied by assignment [a], [false] otherwise *)