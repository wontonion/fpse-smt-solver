module type H = sig
    type t
    val empty : t
    val pick_branching_variable : t -> Formula.t -> Assignment.t -> t * int * bool
    (** [pick_branching_variable h f a] picks a branching variable from formula [f]
        and assignment [a] using the heuristic [h] *)
    val backtrack : t -> int -> t
    (** [backtrack h dl] backtracks the heuristic [h] to decision level [dl] *)
  end

module Random : H