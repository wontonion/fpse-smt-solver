open Core

module type H = sig
  type t

  val empty : t
  val pick_branching_variable : t -> Formula.t -> Assignment.t -> t * int * bool
  val backtrack : t -> int -> t
end

module TrueFirst : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    let rec loop (vars : int list) : int =
      match vars with
      | [] -> failwith "no unassigned variables" [@coverage off]
      | v :: vs -> (
          match Assignment.value a (Literal.create v false) with
          | Some _ -> loop vs
          | None -> v)
    in
    loop (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, true)

  let backtrack _ _ = ()
end

module FalseFirst : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    let rec loop (vars : int list) : int =
      match vars with
      | [] -> failwith "no unassigned variables" [@coverage off]
      | v :: vs -> (
          match Assignment.value a (Literal.create v false) with
          | Some _ -> loop vs
          | None -> v)
    in
    loop (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, false)

  let backtrack _ _ = ()
end

module Random : H = struct
  type t = unit

  let empty = ()

  let next_variable (f : Formula.t) (a : Assignment.t) =
    let rec loop (vars : int list) : int =
      match vars with
      | [] -> failwith "no unassigned variables" [@coverage off]
      | v :: vs -> (
          match Assignment.value a (Literal.create v false) with
          | Some _ -> loop vs
          | None -> v)
    in
    loop (Set.to_list (Formula.variables f))

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    ((), next_variable f a, Random.bool ())

  let backtrack _ _ = ()
end
