type d = { value : bool; antecedent : Clause.t option; dl : int }
type t = { dl : int; values : d Core.Map.M(Variable).t }

val empty : t

val value_of_literal : t -> Literal.t -> bool option
(** [value_of_literal a l] returns the value of literal [l] in assignment [a] *)

val value_of_variable : t -> Variable.t -> bool option
(** [value_of_variable a v] returns the value of variable [v] in assignment [a] *)

val is_assigned : t -> Variable.t -> bool
(** [is_assigned a v] returns [true] if variable [v] is assigned in assignment [a], [false] otherwise *)

val antecedent : t -> Variable.t -> Clause.t option
(** [antecedent a v] returns the antecedent of variable [v] in assignment [a] *)

val dl : t -> Variable.t -> int option
(** [dl a v] returns the decision level of variable [v] in assignment [a] *)

val assign : t -> Variable.t -> bool -> Clause.t option -> t
(** [assign a v b c] assigns value [b] to variable [v] in assignment [a] with antecedent [c] *)

val unassign : t -> Variable.t -> t
(** [unassign a v] unassigns variable [v] in assignment [a] *)

val satisfy : t -> Formula.t -> bool
(** [satisfy a f] returns [true] if formula [f] is satisfied by assignment [a], [false] otherwise *)

val string_of_t : t -> string
(** [string_of_t a] returns a string representation of assignment [a] *)

val to_list : t -> bool list
(** [to_list a] returns a list of boolean values of all variables in assignment [a] *)
