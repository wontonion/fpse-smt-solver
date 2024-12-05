type status = SATIISFIED | UNSATISFIED | UNIT | UNRESOLVED

val all_variables_assigned : Formula.t -> Assignment.t -> bool
(** [all_variables_assigned f a] returns [true] if all variables in formula [f] are assigned in assignment [a] *)

val pick_branching_variable : Formula.t -> Assignment.t -> int * bool
(** [pick_branching_variable f a] picks a branching variable in formula [f] with assignment [a] *)

val backtrack : Assignment.t -> int -> Assignment.t
(** [backtrack a dl] backtracks assignment [a] to decision level [dl] *)

val clause_status : Clause.t -> Assignment.t -> status
(** [clause_status c a] returns the status of clause [c] in assignment [a] *)

val unit_propagation : Formula.t -> Assignment.t -> (Assignment.t * Clause.t option)
(** [unit_propagation f a] performs unit propagation on formula [f] with assignment [a], returns the new assignment and the conflict clause *)

val resolve : Clause.t -> Clause.t -> int -> Clause.t
(** [resolve c1 c2 v] resolves clauses [c1] and [c2] on variable [v] *)

val conflict_analysis : Clause.t -> Assignment.t -> int * Clause.t option
(** [conflict_analysis c a] performs conflict analysis on clause [c] with assignment [a], returns the decision level and the learned clause *)

val cdcl_solve : Formula.t -> Assignment.t option
(** [cdcl_solve f] solves formula [f] using the CDCL algorithm *)