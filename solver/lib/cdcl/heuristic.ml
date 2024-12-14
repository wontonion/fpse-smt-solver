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
    let rec loop (vars : Variable.t list) : Variable.t =
      match vars with
      | [] -> failwith "no unassigned variables" [@coverage off]
      | v :: vs -> if Assignment.is_assigned a v then loop vs else v
    in
    loop (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, true)

  let backtrack _ _ = ()
end

module OrderedFalseFirst : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    let rec loop (vars : Variable.t list) : Variable.t =
      match vars with
      | [] -> failwith "no unassigned variables" [@coverage off]
      | v :: vs -> if Assignment.is_assigned a v then loop vs else v
    in
    loop (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, false)

  let backtrack _ _ = ()
end

module Randomized : H = struct
  type t = unit

  let empty = ()

  let unassigned_vars (f : Formula.t) (a : Assignment.t) =
    let rec loop (ls : Variable.t list) (vars : Variable.t list) :
        Variable.t list =
      match vars with
      | [] -> ls
      | v :: vs ->
          if Assignment.is_assigned a v then loop ls vs else loop (v :: ls) vs
    in
    loop [] (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    let vars = unassigned_vars f a in
    ((), List.random_element_exn vars, Random.bool ())

  let backtrack _ _ = ()
end
