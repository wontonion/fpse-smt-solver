type t

val create : Literal.t list -> t
(** [create l] creates a clause from a list of literals *)

val literals : t -> Literal.t list
(** [literals c] returns the list of literals of clause [c] *)

val bcp : t -> Assignment.t -> Assignment.t option
(** [bcp c a] performs the boolean constraint propagation of clause [c] on assignment [a],
    and returns the new assignment if the clause is unit, or [None] otherwise *)

val is_satisfied : t -> Assignment.t -> bool
(** [is_satisfied c a] returns [true] if clause [c] is satisfied by assignment [a], and [false] otherwise *)

val next_free_literal : t -> Assignment.t -> Literal.t option
(** [next_free_literal c a] returns the next free literal in clause [c] under assignment [a], or [None] if there is no free literal *)