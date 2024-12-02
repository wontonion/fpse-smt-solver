open Core

type t

val create : Clause.t list -> t
(** [create c] creates a formula from a list of clauses *)

val string_of_t : t -> string
(** [string_of_t f] returns a string representation of formula [f] *)

val clauses : t -> Clause.t list
(** [clauses f] returns the list of clauses of formula [f] *)

val variables : t -> Int.Set.t
(** [variables f] returns the set of variables in formula [f] *)