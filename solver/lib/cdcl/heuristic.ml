open Core

module type H = sig
  type t

  val empty : t
  val pick_branching_variable : t -> Formula.t -> Assignment.t -> t * int * bool
  val backtrack : t -> int -> t
end

module Random : H = struct
  type t = unit

  let empty = ()

  let pick_branching_variable _ (f : Formula.t) (a : Assignment.t) =
    let rec loop (vars : int list) : t * int * bool =
      match vars with
      | [] -> failwith "no unassigned variables"
      | v :: vs -> (
          match Assignment.value a (Literal.create v false) with
          | Some _ -> loop vs
          | None -> ((), v, Random.bool ()))
    in
    loop (Set.to_list (Formula.variables f))

  let backtrack _ _ = ()
end
