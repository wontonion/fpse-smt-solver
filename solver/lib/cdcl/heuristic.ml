open Core

module type H = sig
  type t

  val empty : t

  val pick_branching_variable :
    t -> Formula.t -> Assignment.t -> t * Variable.t * bool

  val backtrack : t -> int -> t
end

module OrderedTrueFirst : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    Set.filter (Formula.variables f) ~f:(fun v ->
        not (Assignment.is_assigned a v))
    |> Set.min_elt_exn

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, true)

  let backtrack _ _ = ()
end

module OrderedFalseFirst : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    Set.filter (Formula.variables f) ~f:(fun v ->
        not (Assignment.is_assigned a v))
    |> Set.min_elt_exn

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, false)

  let backtrack _ _ = ()
end

module Randomized : H = struct
  type t = unit

  let empty = ()

  let unassigned_vars (f : Formula.t) (a : Assignment.t) : Variable.t list =
    Set.filter (Formula.variables f) ~f:(fun v ->
        not (Assignment.is_assigned a v))
    |> Set.to_list

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    let vars = unassigned_vars f a in
    ((), List.random_element_exn vars, Random.bool ())

  let backtrack _ _ = ()
end
