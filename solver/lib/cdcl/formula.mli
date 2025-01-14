open Core

type t

val create : Clause.t list -> t
(** [create c] creates a formula from a list of clauses *)

val string_of_t : t -> string
(** [string_of_t f] returns a string representation of formula [f] *)

val clauses : t -> Clause.t list
(** [clauses f] returns the list of clauses of formula [f] *)

val variables : t -> Set.M(Variable).t
(** [variables f] returns the set of variables in formula [f] *)

val add_clause : t -> Clause.t -> t
(** [add_clause f c] adds clause [c] to formula [f] *)
