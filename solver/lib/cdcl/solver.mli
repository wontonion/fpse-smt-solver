open Core

type status = SATISFIED | UNSATISFIED | UNIT | UNRESOLVED

type solver_state = {
  formula : Formula.t;
  assignment : Assignment.t;
  lit2clauses : Clause.t list Map.M(Literal).t;
  clause2lits : Literal.t list Map.M(Clause).t;
  to_propagate : Literal.t list;
}

module type S = sig
  val cdcl_solve : Formula.t -> [ `SAT of Assignment.t | `UNSAT ]
  (** [cdcl_solve f] solves formula [f] using the CDCL algorithm *)
end

module Make (_ : Heuristic.H) : S

val init_watches : Formula.t -> solver_state
(** [init_watches f] initializes watches for formula [f] *)

val add_learnt_clause : solver_state -> Clause.t -> solver_state
(** [add_learnt_clause s c] adds learnt clause [c] to state [s] *)

val all_variables_assigned : Formula.t -> Assignment.t -> bool
(** [all_variables_assigned f a] returns [true] if all variables in formula [f] are assigned in assignment [a] *)

val backtrack : Assignment.t -> int -> Assignment.t
(** [backtrack a dl] backtracks assignment [a] to decision level [dl] *)

val clause_status : Clause.t -> Assignment.t -> status
(** [clause_status c a] returns the status of clause [c] in assignment [a] *)

val unit_propagation :
  solver_state -> solver_state * [ `NoConflict | `Conflict of Clause.t ]
(** [unit_propagation s] performs unit propagation on state [s] *)

val resolve : Clause.t -> Clause.t -> int -> Clause.t
(** [resolve c1 c2 v] resolves clauses [c1] and [c2] on variable [v] *)

val conflict_analysis : Clause.t -> Assignment.t -> int * Clause.t
(** [conflict_analysis c a] performs conflict analysis on clause [c] with assignment [a], returns the decision level and the learned clause *)
