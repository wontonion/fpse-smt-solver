open Core

type status = SATISFIED | UNSATISFIED | UNIT | UNRESOLVED

[@@@warning "-32"]

module type Heuristic = sig
  val pick_branching_variable : Formula.t -> Assignment.t -> int * bool
  (** [pick_branching_variable f a] picks a branching variable in formula [f] with assignment [a] *)
end

module type Solver = sig
  val cdcl_solve : Formula.t -> Assignment.t option
  (** [cdcl_solve f] solves formula [f] using the CDCL algorithm *)
end

module Make (H : Heuristic) : Solver = struct
  let cdcl_solve = failwith "unimplemented"
end

let all_variables_assigned (f : Formula.t) (a : Assignment.t) : bool =
  List.for_all
    (Set.to_list (Formula.variables f))
    ~f:(fun v ->
      match Assignment.value a (Literal.create v false) with
      | Some _ -> true
      | None -> false)

let pick_branching_variable (f : Formula.t) (a : Assignment.t) : int * bool =
  let rec loop (vars : int list) : int * bool =
    match vars with
    | [] -> failwith "no unassigned variables"
    | v :: vs -> (
        match Assignment.value a (Literal.create v false) with
        | Some _ -> loop vs
        | None ->
            let b = Random.bool () in
            printf "Picking variable %d with value %b\n" v b;
            (v, b))
  in
  loop (Set.to_list (Formula.variables f))

let backtrack (a : Assignment.t) (dl : int) : Assignment.t =
  { values = Map.filter ~f:(fun (d : Assignment.d) -> d.dl <= dl) a.values; dl }

let clause_status (c : Clause.t) (a : Assignment.t) : status =
  let res =
    List.fold_until (Clause.literals c) ~init:(0, 0, 0)
      ~f:(fun (num_true, num_false, num_unassigned) l ->
        match Assignment.value a l with
        | Some b ->
            if b then Stop (num_true + 1, num_false, num_unassigned)
            else Continue (num_true, num_false + 1, num_unassigned)
        | None -> Continue (num_true, num_false, num_unassigned + 1))
      ~finish:Fn.id
  in
  match res with
  | num_true, _, _ when num_true > 0 -> SATISFIED
  | _, _, num_unassigned when num_unassigned = 1 -> UNIT
  | num_true, _, num_unassigned when num_true = 0 && num_unassigned = 0 ->
      UNSATISFIED
  | _ -> UNRESOLVED

let unit_propagation (f : Formula.t) (a : Assignment.t) :
    Assignment.t * [ `NoConflict | `Conflict of Clause.t ] =
  let rec unit_propagation_once (f : Formula.t) (a : Assignment.t) :
      Assignment.t * [ `NoConflict | `Conflict of Clause.t ] =
    List.fold_until (Formula.clauses f) ~init:(a, `NoConflict, true)
      ~f:(fun (a, conflict, finish) c ->
        match clause_status c a with
        | SATISFIED | UNRESOLVED -> Continue (a, conflict, finish)
        | UNSATISFIED -> Stop (a, `Conflict c, finish)
        | UNIT ->
            let l =
              List.find_exn (Clause.literals c) ~f:(fun l ->
                  Option.is_none @@ Assignment.value a l)
            in
            Continue
              ( Assignment.assign a l.variable (not l.negation) (Some c),
                conflict,
                false ))
      ~finish:Fn.id
    |> fun (a, conflict, finish) ->
    if finish then (a, conflict) else unit_propagation_once f a
  in
  unit_propagation_once f a

let resolve (c1 : Clause.t) (c2 : Clause.t) (v : int) : Clause.t =
  let lits1 = List.filter (Clause.literals c1) ~f:(fun l -> l.variable <> v) in
  let lits2 = List.filter (Clause.literals c2) ~f:(fun l -> l.variable <> v) in
  Clause.create (lits1 @ lits2)

let conflict_analysis (c : Clause.t) (a : Assignment.t) : int * Clause.t =
  let rec conflict_analysis_once (c : Clause.t) (a : Assignment.t) : Clause.t =
    let literals =
      List.filter (Clause.literals c) ~f:(fun l ->
          match Assignment.dl a l.variable with
          | Some dl -> dl = a.dl
          | None -> false)
    in
    match List.length literals with
    | 1 -> c
    | _ ->
        let literal =
          List.find_exn literals ~f:(fun l ->
              match Assignment.antecedent a l.variable with
              | Some _ -> true
              | None -> false)
        in
        let antecedent =
          Option.value_exn (Assignment.antecedent a literal.variable)
        in
        conflict_analysis_once (resolve c antecedent literal.variable) a
  in
  if a.dl <= 0 then failwith "Invalid decision level"
  else
    let clause = conflict_analysis_once c a in
    let decision_levels =
      List.dedup_and_sort ~compare:(fun x y -> Int.compare y x)
      @@ List.map (Clause.literals clause) ~f:(fun l ->
             match Assignment.dl a l.variable with
             | Some dl -> dl
             | None -> failwith "variable not in assignment")
    in
    match List.length decision_levels with
    | 0 | 1 -> (0, clause)
    | _ -> (List.nth_exn decision_levels 1, clause)

let cdcl_solve (formula : Formula.t) : Assignment.t option =
  let rec learn_clause (f : Formula.t) (a : Assignment.t) :
      Formula.t * Assignment.t =
    let assignment, conflict = unit_propagation f a in
    match conflict with
    | `NoConflict -> (f, assignment)
    | `Conflict clause ->
        let dl, learnt = conflict_analysis clause assignment in
        let formula' = Formula.add_clause f learnt in
        let assignment' = backtrack assignment dl in
        learn_clause formula' assignment'
  in
  let rec cdcl_solve_once (formula : Formula.t) (assignment : Assignment.t) :
      Assignment.t option =
    match all_variables_assigned formula assignment with
    | true -> Some assignment
    | false ->
        let variable, value = pick_branching_variable formula assignment in
        let assignment' =
          Assignment.assign
            { assignment with dl = assignment.dl + 1 }
            variable value None
        in
        let formula', assignment'' = learn_clause formula assignment' in
        cdcl_solve_once formula' assignment''
  in
  let a = Assignment.empty in
  let assignment, conflict = unit_propagation formula a in
  match conflict with
  | `Conflict _ -> None
  | `NoConflict -> cdcl_solve_once formula assignment
