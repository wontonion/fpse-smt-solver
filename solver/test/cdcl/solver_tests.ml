open OUnit2
open Core

[@@@warning "-26"]

let test_init_watches _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c0 = Cdcl.Clause.create [ l2'; l3' ] in
  let c1 = Cdcl.Clause.create [ l1'; l2 ] in
  let c2 = Cdcl.Clause.create [ l1 ] in
  let f = Cdcl.Formula.create [ c0; c1; c2 ] in
  let state = Cdcl.Solver.init_watches f in

  let lits2clauses = state.lit2clauses in
  assert_equal [ c2 ] (Map.find_exn lits2clauses l1);
  assert_equal [ c1 ] (Map.find_exn lits2clauses l2);
  assert_equal None (Map.find lits2clauses l3);
  assert_equal [ c1 ] (Map.find_exn lits2clauses l1');
  assert_equal [ c0 ] (Map.find_exn lits2clauses l2');
  assert_equal [ c0 ] (Map.find_exn lits2clauses l3');

  let clauses2lits = state.clause2lits in
  assert_equal [ l2'; l3' ] (Map.find_exn clauses2lits c0);
  assert_equal [ l2; l1' ] (Map.find_exn clauses2lits c1);
  assert_equal [ l1 ] (Map.find_exn clauses2lits c2)

let test_all_variables_assigned _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c1 = Cdcl.Clause.create [ l1 ] in
  let c2 = Cdcl.Clause.create [ l2'; l3' ] in
  let f = Cdcl.Formula.create [ c1; c2 ] in
  assert_equal false
    (Cdcl.Solver.all_variables_assigned f Cdcl.Assignment.empty);

  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal false (Cdcl.Solver.all_variables_assigned f a);

  let a' = Cdcl.Assignment.assign a 2 true None in
  assert_equal false (Cdcl.Solver.all_variables_assigned f a');

  let a'' = Cdcl.Assignment.assign a' 3 true None in
  assert_equal true (Cdcl.Solver.all_variables_assigned f a'')

let test_clause_status _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c0 = Cdcl.Clause.create [ l1 ] in
  let c1 = Cdcl.Clause.create [ l2'; l3' ] in
  let c2 = Cdcl.Clause.create [ l1'; l2 ] in
  assert_equal Cdcl.Solver.UNIT
    (Cdcl.Solver.clause_status c0 Cdcl.Assignment.empty);
  assert_equal Cdcl.Solver.UNRESOLVED
    (Cdcl.Solver.clause_status c1 Cdcl.Assignment.empty);
  assert_equal Cdcl.Solver.UNRESOLVED
    (Cdcl.Solver.clause_status c2 Cdcl.Assignment.empty);

  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal Cdcl.Solver.SATISFIED (Cdcl.Solver.clause_status c0 a);
  assert_equal Cdcl.Solver.UNRESOLVED (Cdcl.Solver.clause_status c1 a);
  assert_equal Cdcl.Solver.UNIT (Cdcl.Solver.clause_status c2 a)

let test_unit_propagation_1 _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c0 = Cdcl.Clause.create [ l2'; l3' ] in
  let c1 = Cdcl.Clause.create [ l1'; l2 ] in
  let c2 = Cdcl.Clause.create [ l1 ] in
  let f = Cdcl.Formula.create [ c0; c1; c2 ] in
  let state = Cdcl.Solver.init_watches f in

  let state', conflict' =
    Cdcl.Solver.unit_propagation { state with to_propagate = [ l1 ] }
  in
  assert_equal `NoConflict conflict';
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 1 false);
  assert_equal (Some true)
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 2 false);
  assert_equal (Some false)
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 3 false);

  let state', conflict' =
    Cdcl.Solver.unit_propagation { state with to_propagate = [ l1' ] }
  in
  assert_equal (`Conflict c2) conflict';
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 1 false);
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 2 false);
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 3 false)

let test_unit_propagation_2 _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let l4 = Cdcl.Literal.create 4 false in
  let l4' = Cdcl.Literal.create 4 true in
  let c0 = Cdcl.Clause.create [ l1'; l3'; l4 ] in
  let c1 = Cdcl.Clause.create [ l1'; l2 ] in
  let c2 = Cdcl.Clause.create [ l1 ] in
  let f = Cdcl.Formula.create [ c0; c1; c2 ] in
  let state = Cdcl.Solver.init_watches f in

  let state', conflict' =
    Cdcl.Solver.unit_propagation { state with to_propagate = [ l1 ] }
  in
  assert_equal `NoConflict conflict';
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 1 false);
  assert_equal (Some true)
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 2 false);
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 3 false);
  assert_equal None
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 4 false)

let test_unit_propagation_3 _ =
  let c =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 false;
        Cdcl.Literal.create 2 false;
        Cdcl.Literal.create 3 false;
      ]
  in
  let f = Cdcl.Formula.create [ c ] in
  let state = Cdcl.Solver.init_watches f in

  let state', conflict' =
    Cdcl.Solver.unit_propagation
      {
        state with
        to_propagate = [ Cdcl.Literal.create 1 true ];
        assignment = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 false None;
      }
  in
  assert_equal `NoConflict conflict';
  assert_equal (Some false)
    (Cdcl.Assignment.value state'.assignment @@ Cdcl.Literal.create 1 false);

  let state'', conflict'' =
    Cdcl.Solver.unit_propagation
      {
        state' with
        to_propagate = [ Cdcl.Literal.create 2 true ];
        assignment = Cdcl.Assignment.assign state'.assignment 2 false None;
      }
  in
  assert_equal `NoConflict conflict'';
  assert_equal (Some false)
    (Cdcl.Assignment.value state''.assignment @@ Cdcl.Literal.create 1 false);
  assert_equal (Some false)
    (Cdcl.Assignment.value state''.assignment @@ Cdcl.Literal.create 2 false);
  assert_equal (Some true)
    (Cdcl.Assignment.value state''.assignment @@ Cdcl.Literal.create 3 false)

let test_resolve _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let l4 = Cdcl.Literal.create 4 false in
  let l4' = Cdcl.Literal.create 4 true in
  let c1 = Cdcl.Clause.create [ l1'; l2 ] in
  let c2 = Cdcl.Clause.create [ l1; l3' ] in
  let c = Cdcl.Solver.resolve c1 c2 1 in
  assert_equal [ l3'; l2 ] (Cdcl.Clause.literals c)

let test_conflict_analysis _ =
  let c1 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 2 true;
        Cdcl.Literal.create 3 true;
        Cdcl.Literal.create 4 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c2 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 5 true;
        Cdcl.Literal.create 6 false;
      ]
  in
  let c3 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 5 true; Cdcl.Literal.create 7 false ]
  in
  let c4 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 6 true;
        Cdcl.Literal.create 7 true;
      ]
  in
  let c5 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 2 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c6 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 3 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c7 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 4 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c7 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 2 false;
        Cdcl.Literal.create 3 false;
        Cdcl.Literal.create 4 false;
        Cdcl.Literal.create 5 false;
        Cdcl.Literal.create 6 true;
      ]
  in
  let f = Cdcl.Formula.create [ c1; c2; c3; c4; c5; c6; c7 ] in
  let state = Cdcl.Solver.init_watches f in

  let a1 =
    Cdcl.Assignment.assign { Cdcl.Assignment.empty with dl = 1 } 1 true None
  in
  let state', conflict' =
    Cdcl.Solver.unit_propagation
      {
        state with
        assignment = a1;
        to_propagate = [ Cdcl.Literal.create 1 false ];
      }
  in
  assert_equal `NoConflict conflict';

  let a2 = Cdcl.Assignment.assign { a1 with dl = 2 } 2 true None in
  let state'', conflict'' =
    Cdcl.Solver.unit_propagation
      {
        state' with
        assignment = a2;
        to_propagate = [ Cdcl.Literal.create 2 false ];
      }
  in
  let dl, learned =
    match conflict'' with
    | `Conflict clause ->
        Cdcl.Solver.conflict_analysis clause state''.assignment
    | `NoConflict -> failwith "Expected a conflict"
  in
  assert_equal 1 dl;
  assert_equal
    [ Cdcl.Literal.create 5 true; Cdcl.Literal.create 1 true ]
    (Cdcl.Clause.literals learned)

module TrueFirstSolver = Cdcl.Solver.Make (Cdcl.Heuristic.OrderedTrueFirst)
module FalseFirstSolver = Cdcl.Solver.Make (Cdcl.Heuristic.OrderedFalseFirst)
module RandomSolver = Cdcl.Solver.Make (Cdcl.Heuristic.Random)

let test_cdcl_solve_0 _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c0 = Cdcl.Clause.create [ l2'; l3' ] in
  let c1 = Cdcl.Clause.create [ l1'; l2 ] in
  let c2 = Cdcl.Clause.create [ l1 ] in
  let f = Cdcl.Formula.create [ c0; c1; c2 ] in

  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l1);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l2);
  assert_equal (Some false) (Cdcl.Assignment.value assignment l3);

  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l1);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l2);
  assert_equal (Some false) (Cdcl.Assignment.value assignment l3);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l1);
  assert_equal (Some true) (Cdcl.Assignment.value assignment l2);
  assert_equal (Some false) (Cdcl.Assignment.value assignment l3)

let test_cdcl_solve_1 _ =
  let c1 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 2 true;
        Cdcl.Literal.create 3 true;
        Cdcl.Literal.create 4 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c2 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 5 true;
        Cdcl.Literal.create 6 false;
      ]
  in
  let c3 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 5 true; Cdcl.Literal.create 7 false ]
  in
  let c4 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 6 true;
        Cdcl.Literal.create 7 true;
      ]
  in
  let c5 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 2 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c6 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 3 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c7 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 4 true;
        Cdcl.Literal.create 5 false;
      ]
  in
  let c8 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 true;
        Cdcl.Literal.create 2 false;
        Cdcl.Literal.create 3 false;
        Cdcl.Literal.create 4 false;
        Cdcl.Literal.create 5 false;
        Cdcl.Literal.create 6 true;
      ]
  in
  let f = Cdcl.Formula.create [ c1; c2; c3; c4; c5; c6; c7; c8 ] in
  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);

  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f)

let test_cdcl_solve_2 _ =
  let c1 = Cdcl.Clause.create [ Cdcl.Literal.create 1 false ] in
  let c2 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 1 true; Cdcl.Literal.create 2 false ]
  in
  let c3 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 2 true; Cdcl.Literal.create 3 false ]
  in
  let c4 = Cdcl.Clause.create [ Cdcl.Literal.create 3 true ] in
  let f = Cdcl.Formula.create [ c1; c2; c3; c4 ] in
  assert_equal `UNSAT (TrueFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (FalseFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (RandomSolver.cdcl_solve f)

let test_cdcl_solve_3 _ =
  let c =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 false;
        Cdcl.Literal.create 2 false;
        Cdcl.Literal.create 3 false;
      ]
  in
  let f = Cdcl.Formula.create [ c ] in

  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);
  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Cdcl.Assignment.satisfy assignment f)

let test_cdcl_solve_4 _ =
  let c1 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 1 false; Cdcl.Literal.create 2 false ]
  in
  let c2 = Cdcl.Clause.create [ Cdcl.Literal.create 1 true ] in
  let c3 = Cdcl.Clause.create [ Cdcl.Literal.create 2 true ] in
  let f = Cdcl.Formula.create [ c1; c2; c3 ] in
  assert_equal `UNSAT (TrueFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (FalseFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (RandomSolver.cdcl_solve f)

let series =
  "Solver tests"
  >::: [
         "Test init_watches" >:: test_init_watches;
         "Test all_variables_assigned" >:: test_all_variables_assigned;
         "Test clause_status" >:: test_clause_status;
         "Test unit_propagation 1" >:: test_unit_propagation_1;
         "Test unit_propagation 2" >:: test_unit_propagation_2;
         "Test unit_propagation 3" >:: test_unit_propagation_3;
         "Test resolve" >:: test_resolve;
         "Test conflict_analysis" >:: test_conflict_analysis;
         "Test cdcl_solve 0" >:: test_cdcl_solve_0;
         "Test cdcl_solve 1" >:: test_cdcl_solve_1;
         "Test cdcl_solve 2" >:: test_cdcl_solve_2;
         "Test cdcl_solve 3" >:: test_cdcl_solve_3;
         "Test cdcl_solve 4" >:: test_cdcl_solve_4;
       ]
