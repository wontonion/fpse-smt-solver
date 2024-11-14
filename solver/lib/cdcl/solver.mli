type t

module type H = sig
    type t
    (** The type of the heuristic *)
    val heuristic : t -> Clause.t list -> Variable.t -> Assignment.value
end

module type S = sig
    type h
    (** The type of the heuristic *)

    val create : unit -> t
    (** [create ()] creates a new solver *)
    
    val add_clause : t -> Clause.t list -> unit
    (** [add_clause s c] adds clause [c] to solver [s] *)
    
    val solve : t -> Assignment.t option
    (** [solve s] returns [Some a] if the solver [s] is satisfiable, where [a] is a satisfying assignment. Otherwise, it returns [None] *)
end

module Make (H : H) : S with type h = H.t