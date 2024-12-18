open Core

type status = SATISFIED | UNSATISFIED | UNIT | UNRESOLVED

type solver_state = {
  formula : Formula.t;
  assignment : Assignment.t;
  lit2clauses : Clause.t list Hashtbl.M(Literal).t;
  clause2lits : Literal.t list Hashtbl.M(Clause).t;
  to_propagate : Literal.t list;
}

module type S = sig
  val cdcl_solve : Formula.t -> [ `SAT of Assignment.t | `UNSAT ]
end

let init_watches (f : Formula.t) : solver_state =
  let lit2clauses = Hashtbl.create (module Literal) in
  let clause2lits = Hashtbl.create (module Clause) in
  let _ =
    List.fold_left (Formula.clauses f) ~init:() ~f:(fun _ c ->
        match Clause.literals c with
        | [] -> failwith "Should not happen" [@coverage off]
        | lit :: [] ->
            Hashtbl.add_multi lit2clauses ~key:lit ~data:c;
            Hashtbl.add_multi clause2lits ~key:c ~data:lit
        | lit1 :: lit2 :: _ ->
            Hashtbl.add_multi lit2clauses ~key:lit1 ~data:c;
            Hashtbl.add_multi lit2clauses ~key:lit2 ~data:c;
            Hashtbl.add_multi clause2lits ~key:c ~data:lit1;
            Hashtbl.add_multi clause2lits ~key:c ~data:lit2)
  in
  {
    formula = f;
    assignment = Assignment.empty;
    lit2clauses;
    clause2lits;
    to_propagate = [];
  }

let add_learnt_clause (state : solver_state) (c : Clause.t) : solver_state =
  let rec add_learnt_clause_helper (state : solver_state) (clause : Clause.t)
      (lits : Literal.t list) : solver_state =
    match lits with
    | [] -> state
    | lit :: lits -> (
        match
          Hashtbl.find state.clause2lits clause |> Option.value ~default:[]
        with
        | [] | _ :: [] ->
            Hashtbl.add_multi state.clause2lits ~key:clause ~data:lit;
            Hashtbl.add_multi state.lit2clauses ~key:lit ~data:clause;
            add_learnt_clause_helper state clause lits
        | _ -> state)
  in
  let formula = Formula.add_clause state.formula c in
  let state = { state with formula } in
  let lits =
    List.sort (Clause.literals c) ~compare:(fun l1 l2 ->
        Int.compare
          (Assignment.dl state.assignment l2.variable |> Option.value_exn)
          (Assignment.dl state.assignment l1.variable |> Option.value_exn))
  in

  add_learnt_clause_helper state c lits

let all_variables_assigned (f : Formula.t) (a : Assignment.t) : bool =
  Set.for_all (Formula.variables f) ~f:(fun v -> Assignment.is_assigned a v)

let backtrack (a : Assignment.t) (dl : int) : Assignment.t =
  { values = Map.filter ~f:(fun (d : Assignment.d) -> d.dl <= dl) a.values; dl }

let clause_status (c : Clause.t) (a : Assignment.t) : status =
  let res =
    List.fold_until (Clause.literals c) ~init:(0, 0, 0)
      ~f:(fun (num_true, num_false, num_unassigned) l ->
        match Assignment.value_of_literal a l with
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

let rec unit_propagation (state : solver_state) :
    solver_state * [ `NoConflict | `Conflict of Clause.t ] =
  let try_rewatch (state : solver_state) (watching_lit : Literal.t)
      (watching_clause : Clause.t) : bool * solver_state =
    let rec try_rewatch_once (state : solver_state) (watching_lit : Literal.t)
        (watching_clause : Clause.t) (clause_lits : Literal.t list) :
        bool * solver_state =
      match clause_lits with
      | [] -> (false, state)
      | lit :: clause_lits ->
          if
            List.mem
              (Hashtbl.find state.clause2lits watching_clause
              |> Option.value ~default:[])
              lit ~equal:Literal.equal
          then try_rewatch_once state watching_lit watching_clause clause_lits
          else if
            Assignment.value_of_literal state.assignment lit
            |> Option.value ~default:true |> not
          then try_rewatch_once state watching_lit watching_clause clause_lits
          else
            let ls =
              lit
              :: (Hashtbl.find_exn state.clause2lits watching_clause
                 |> List.filter ~f:(fun l -> not (Literal.equal l watching_lit))
                 )
            in
            Hashtbl.set state.clause2lits ~key:watching_clause ~data:ls;

            let ls =
              Hashtbl.find_exn state.lit2clauses watching_lit
              |> List.filter ~f:(fun c -> not (Clause.equal c watching_clause))
            in
            Hashtbl.set state.lit2clauses ~key:watching_lit ~data:ls;
            Hashtbl.add_multi state.lit2clauses ~key:lit ~data:watching_clause;
            (true, state)
    in
    try_rewatch_once state watching_lit watching_clause
    @@ Clause.literals watching_clause
  in
  let rec process_watching_clause (state : solver_state)
      (watching_lit : Literal.t) (watching_clauses : Clause.t list) :
      solver_state * [ `NoConflict | `Conflict of Clause.t ] =
    match watching_clauses with
    | [] -> unit_propagation state
    | watching_clause :: watching_clauses -> (
        let rewatched, state = try_rewatch state watching_lit watching_clause in
        if rewatched then
          process_watching_clause state watching_lit watching_clauses
        else
          let watching_lits = Hashtbl.find_exn state.clause2lits watching_clause in
          match watching_lits with
          | [] -> failwith "Should not happen" [@coverage off]
          | _ :: [] -> (state, `Conflict watching_clause)
          | watching_lits_0 :: watching_lits_1 :: _ ->
              let other =
                if Literal.equal watching_lit watching_lits_0 then
                  watching_lits_1
                else watching_lits_0
              in
              if not @@ Assignment.is_assigned state.assignment other.variable
              then
                let assignment =
                  Assignment.assign state.assignment other.variable
                    (Literal.polarity_to_bool other.polarity)
                    (Some watching_clause)
                in
                let to_propagate = other :: state.to_propagate in
                let state = { state with assignment; to_propagate } in
                process_watching_clause state watching_lit watching_clauses
              else if
                Assignment.value_of_literal state.assignment other
                |> Option.value_exn
              then process_watching_clause state watching_lit watching_clauses
              else (state, `Conflict watching_clause))
  in
  match state.to_propagate with
  | [] -> (state, `NoConflict)
  | _ ->
      let to_propagate, watching_lit =
        List.split_n state.to_propagate @@ (List.length state.to_propagate - 1)
      in
      let watching_lit = Literal.neg @@ List.hd_exn watching_lit in
      let watching_clauses =
        Hashtbl.find state.lit2clauses watching_lit |> Option.value ~default:[]
      in
      process_watching_clause
        { state with to_propagate }
        watching_lit watching_clauses

let resolve (c1 : Clause.t) (c2 : Clause.t) (v : Variable.t) : Clause.t =
  let lits1 =
    List.filter (Clause.literals c1) ~f:(fun l ->
        not @@ Variable.equal l.variable v)
  in
  let lits2 =
    List.filter (Clause.literals c2) ~f:(fun l ->
        not @@ Variable.equal l.variable v)
  in
  Clause.create (lits1 @ lits2)

let snd_largest (l : int list) : int option =
  List.fold l ~init:(None, None) ~f:(fun (largest, snd_largest) x ->
      match largest with
      | None -> (Some x, None)
      | Some largest -> (
          match snd_largest with
          | None ->
              if x > largest then (Some x, Some largest)
              else (Some largest, Some x)
          | Some snd_largest ->
              if x > largest then (Some x, Some largest)
              else if x > snd_largest then (Some largest, Some x)
              else (Some largest, Some snd_largest)))
  |> snd

let conflict_analysis (c : Clause.t) (a : Assignment.t) : int * Clause.t =
  let rec conflict_analysis_once (c : Clause.t) (a : Assignment.t) : Clause.t =
    let literals =
      List.filter (Clause.literals c) ~f:(fun l ->
          match Assignment.dl a l.variable with
          | Some dl -> dl = a.dl
          | None -> false [@coverage off]
          (* Conflict clause has no unassigned literals *))
    in

    match literals with
    | _ :: [] -> c
    | _ ->
        let literal =
          List.find_exn literals ~f:(fun l ->
              Assignment.antecedent a l.variable |> Option.is_some)
        in
        let antecedent =
          Option.value_exn (Assignment.antecedent a literal.variable)
        in
        conflict_analysis_once (resolve c antecedent literal.variable) a
  in
  if a.dl <= 0 then failwith "Invalid decision level" [@coverage off]
  else
    let clause = conflict_analysis_once c a in
    let decision_levels =
      List.map (Clause.literals clause) ~f:(fun l ->
          Assignment.dl a l.variable |> Option.value_exn)
    in
    (snd_largest decision_levels |> Option.value ~default:0, clause)

module Make (Heuristic : Heuristic.H) : S = struct
  let cdcl_solve (formula : Formula.t) : [ `SAT of Assignment.t | `UNSAT ] =
    let rec learn_clause (state : solver_state) (heuristic : Heuristic.t) :
        solver_state * Heuristic.t =
      let state, conflict = unit_propagation state in
      match conflict with
      | `NoConflict -> (state, heuristic)
      | `Conflict clause ->
          let dl, learnt = conflict_analysis clause state.assignment in
          let assignment' = backtrack state.assignment dl in
          let literal =
            List.find_exn (Clause.literals learnt) ~f:(fun l ->
                not @@ Assignment.is_assigned assignment' l.variable)
          in
          let assignment =
            Assignment.assign assignment' literal.variable
              (Literal.polarity_to_bool literal.polarity)
              (Some learnt)
          in
          learn_clause
            {
              (add_learnt_clause state learnt) with
              assignment;
              to_propagate = [ literal ];
            }
            (Heuristic.backtrack heuristic dl)
    in
    let rec cdcl_solve_once (state : solver_state) (heuristic : Heuristic.t) :
        [ `SAT of Assignment.t | `UNSAT ] =
      match all_variables_assigned state.formula state.assignment with
      | true -> `SAT state.assignment
      | false ->
          let assignment' =
            { state.assignment with dl = state.assignment.dl + 1 }
          in
          let heuristic, variable, value =
            Heuristic.pick_branching_variable heuristic formula assignment'
          in
          let assignment = Assignment.assign assignment' variable value None in
          learn_clause
            {
              state with
              assignment;
              to_propagate =
                [ Literal.create variable (Literal.bool_to_polarity value) ];
            }
            heuristic
          |> Tuple2.uncurry cdcl_solve_once
    in
    let state = init_watches formula in
    let unit_clauses =
      List.filter (Formula.clauses formula) ~f:(fun c ->
          match Clause.literals c with _ :: [] -> true | _ -> false)
    in
    let state =
      List.fold unit_clauses ~init:state ~f:(fun state clause ->
          let lit = List.hd_exn (Clause.literals clause) in
          if Assignment.value_of_literal state.assignment lit |> Option.is_some
          then state
          else
            let assignment =
              Assignment.assign state.assignment lit.variable
                (Literal.polarity_to_bool lit.polarity)
                (Some clause)
            in
            {
              state with
              assignment;
              to_propagate = state.to_propagate |> List.append [ lit ];
            })
    in
    let state, conflict = unit_propagation state in
    match conflict with
    | `Conflict _ -> `UNSAT
    | `NoConflict -> cdcl_solve_once state Heuristic.empty
end
