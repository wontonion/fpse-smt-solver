open Core

type status = SATIISFIED | UNSATISFIED | UNIT | UNRESOLVED


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
        | None -> (v, false))
  in
  loop (Set.to_list (Formula.variables f))

let backtrack (a : Assignment.t) (dl : int) : Assignment.t =
  {
    values = Map.filter ~f:(fun (d : Assignment.d) -> d.dl < dl) a.values;
    dl;
  }

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
  | num_true, _, _ when num_true > 0 -> SATIISFIED
  | _, _, num_unassigned when num_unassigned = 1 -> UNIT
  | num_true, _, num_unassigned when num_true = 0 && num_unassigned = 0 ->
      UNSATISFIED
  | _ -> UNRESOLVED

let unit_propagation (f : Formula.t) (a : Assignment.t) :
    Assignment.t * Clause.t option =
  let unit_propagation_once (f : Formula.t) (a : Assignment.t) :
      Assignment.t * Clause.t option * bool =
    List.fold_until (Formula.clauses f) ~init:(a, None, true)
      ~f:(fun (a, conflict, finish) c ->
        match clause_status c a with
        | SATIISFIED | UNRESOLVED -> Continue (a, conflict, finish)
        | UNSATISFIED -> Stop (a, Some c, finish)
        | UNIT ->
            let l =
              List.find_exn (Clause.literals c) ~f:(fun l -> Option.is_none @@ Assignment.value a l)
            in
            Continue
              ( Assignment.assign a l.variable (not l.negation) (Some c),
                conflict,
                false ))
      ~finish:Fn.id
  in
  let rec loop (a : Assignment.t) : Assignment.t * Clause.t option =
    let a', conflict, finish = unit_propagation_once f a in
    if finish then (a', conflict) else loop a'
  in
  loop a

let resolve (c1 : Clause.t) (c2 : Clause.t) (v : int) : Clause.t =
  let lits1 = List.filter (Clause.literals c1) ~f:(fun l -> l.variable <> v) in
  let lits2 = List.filter (Clause.literals c2) ~f:(fun l -> l.variable <> v) in
  Clause.create (lits1 @ lits2)

let conflict_analysis_once (c : Clause.t) (a : Assignment.t) : Clause.t * bool =
  let literals =
    List.filter (Clause.literals c) ~f:(fun l ->
        match Assignment.dl a l.variable with
        | Some dl -> dl = a.dl
        | None -> false)
  in
  match List.length literals with
  | 1 -> (c, true)
  | _ ->
      let literals =
        List.filter literals ~f:(fun l ->
            match Assignment.antecedent a l.variable with
            | Some _ -> true
            | None -> false)
      in
      let literal = List.hd_exn literals in
      let antecedent =
        Option.value_exn (Assignment.antecedent a literal.variable)
      in
      (resolve c antecedent literal.variable, false)

let conflict_analysis (c : Clause.t) (a : Assignment.t) : int * Clause.t option
    =
  match a.dl with
  | 0 -> (-1, None)
  | _ -> (
      let rec loop (c : Clause.t) (a : Assignment.t) : Clause.t =
        let c', finish = conflict_analysis_once c a in
        if finish then c' else loop c' a
      in
      let clause = loop c a in
      let decision_levels =
        List.map (Clause.literals clause) ~f:(fun l ->
            match Assignment.dl a l.variable with
            | Some dl -> dl
            | None -> failwith "variable not in assignment")
      in
      match List.length decision_levels with
      | 0 | 1 -> (List.hd_exn decision_levels, Some clause)
      | _ ->
          let max_dl = List.max_elt decision_levels ~compare:Int.compare in
          let decision_levels =
            List.filter decision_levels ~f:(fun dl ->
                dl < Option.value_exn max_dl)
          in
          ( List.max_elt decision_levels ~compare:Int.compare |> Option.value_exn,
            Some clause ))

type choice = Backtrack of int | Continue of Assignment.t

let rec cdcl_solve_once (formula : Formula.t) (assignment : Assignment.t) :
    Formula.t * choice =
  match all_variables_assigned formula assignment with
  | true -> (formula, Continue assignment)
  | false -> (
      let var, value = pick_branching_variable formula assignment in
      let assignment =
        Assignment.assign
          { assignment with dl = assignment.dl + 1 }
          var value None
      in
      let clause = unit_propagation formula assignment in
      match clause with
      | assignment, None -> cdcl_solve_once formula assignment
      | assignment, Some clause ->
          let dl, learnt_clause = conflict_analysis clause assignment in
          let formula =
            match learnt_clause with
            | Some learnt_clause -> Formula.add_clause formula learnt_clause
            | None -> formula
          in
          (formula, Backtrack dl))

let cdcl_solve (formula : Formula.t) : Assignment.t option =
  let assignment = Assignment.empty in
  let clause = unit_propagation formula assignment in
  match clause with
  | _, Some _ -> None
  | _, None -> (
      cdcl_solve_once formula assignment |> snd |> function
      | Backtrack dl -> Some (backtrack assignment dl)
      | Continue assignment -> Some assignment)
