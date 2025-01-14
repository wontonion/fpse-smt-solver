module type H = sig
    type t
    val empty : t
    val pick_branching_variable : t -> Formula.t -> Assignment.t -> t * Variable.t * bool
    (** [pick_branching_variable h f a] returns a new heuristic [h], a variable [v]
        and assignment [a] using the heuristic [h] *)
    val backtrack : t -> int -> t
    (** [backtrack h dl] backtracks the heuristic [h] to decision level [dl] *)
  end

module OrderedTrueFirst : H
module OrderedFalseFirst : H
module Randomized : H
