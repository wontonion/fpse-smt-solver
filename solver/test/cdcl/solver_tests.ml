open OUnit2
open Core
open Cdcl
open Cdcl.Variable

[@@@warning "-26"]

let v1 = Var 1
let v2 = Var 2
let v3 = Var 3
let v4 = Var 4
let v5 = Var 5
let v6 = Var 6
let v7 = Var 7
let l1 = Literal.create v1 Positive
let l1' = Literal.create v1 Negative
let l2 = Literal.create v2 Positive
let l2' = Literal.create v2 Negative
let l3 = Literal.create v3 Positive
let l3' = Literal.create v3 Negative
let l4 = Literal.create v4 Positive
let l4' = Literal.create v4 Negative
let l5 = Literal.create v5 Positive
let l5' = Literal.create v5 Negative
let l6 = Literal.create v6 Positive
let l6' = Literal.create v6 Negative
let l7 = Literal.create v7 Positive
let l7' = Literal.create v7 Negative

let test_init_watches _ =
  let c0 = Clause.create [ l2'; l3' ] in
  let c1 = Clause.create [ l1'; l2 ] in
  let c2 = Clause.create [ l1 ] in
  let f = Formula.create [ c0; c1; c2 ] in
  let state = Solver.init_watches f in

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
  let c1 = Clause.create [ l1 ] in
  let c2 = Clause.create [ l2'; l3' ] in
  let f = Formula.create [ c1; c2 ] in
  assert_equal false (Solver.all_variables_assigned f Assignment.empty);

  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal false (Solver.all_variables_assigned f a);

  let a' = Assignment.assign a v2 true None in
  assert_equal false (Solver.all_variables_assigned f a');

  let a'' = Assignment.assign a' v3 true None in
  assert_equal true (Solver.all_variables_assigned f a'')

let test_clause_status _ =
  let c0 = Clause.create [ l1 ] in
  let c1 = Clause.create [ l2'; l3' ] in
  let c2 = Clause.create [ l1'; l2 ] in
  assert_equal Solver.UNIT (Solver.clause_status c0 Assignment.empty);
  assert_equal Solver.UNRESOLVED (Solver.clause_status c1 Assignment.empty);
  assert_equal Solver.UNRESOLVED (Solver.clause_status c2 Assignment.empty);

  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal Solver.SATISFIED (Solver.clause_status c0 a);
  assert_equal Solver.UNRESOLVED (Solver.clause_status c1 a);
  assert_equal Solver.UNIT (Solver.clause_status c2 a)

let test_unit_propagation_1 _ =
  let c0 = Clause.create [ l2'; l3' ] in
  let c1 = Clause.create [ l1'; l2 ] in
  let c2 = Clause.create [ l1 ] in
  let f = Formula.create [ c0; c1; c2 ] in
  let state = Solver.init_watches f in

  let state', conflict' =
    Solver.unit_propagation { state with to_propagate = [ l1 ] }
  in
  assert_equal `NoConflict conflict';
  assert_equal None (Assignment.value_of_literal state'.assignment l1);
  assert_equal (Some true) (Assignment.value_of_literal state'.assignment l2);
  assert_equal (Some false) (Assignment.value_of_literal state'.assignment l3);

  let state', conflict' =
    Solver.unit_propagation { state with to_propagate = [ l1' ] }
  in
  assert_equal (`Conflict c2) conflict';
  assert_equal None (Assignment.value_of_literal state'.assignment l1);
  assert_equal None (Assignment.value_of_literal state'.assignment l2);
  assert_equal None (Assignment.value_of_literal state'.assignment l3)

let test_unit_propagation_2 _ =
  let c0 = Clause.create [ l1'; l3'; l4 ] in
  let c1 = Clause.create [ l1'; l2 ] in
  let c2 = Clause.create [ l1 ] in
  let f = Formula.create [ c0; c1; c2 ] in
  let state = Solver.init_watches f in

  let state', conflict' =
    Solver.unit_propagation { state with to_propagate = [ l1 ] }
  in
  assert_equal `NoConflict conflict';
  assert_equal None (Assignment.value_of_literal state'.assignment l1);
  assert_equal (Some true) (Assignment.value_of_literal state'.assignment l2);
  assert_equal None (Assignment.value_of_literal state'.assignment l3);
  assert_equal None (Assignment.value_of_literal state'.assignment l4)

let test_unit_propagation_3 _ =
  let c = Clause.create [ l1; l2; l3 ] in
  let f = Formula.create [ c ] in
  let state = Solver.init_watches f in

  let state', conflict' =
    Solver.unit_propagation
      {
        state with
        to_propagate = [ l1' ];
        assignment = Assignment.assign Assignment.empty v1 false None;
      }
  in
  assert_equal `NoConflict conflict';
  assert_equal (Some false) (Assignment.value_of_literal state'.assignment l1);

  let state'', conflict'' =
    Solver.unit_propagation
      {
        state' with
        to_propagate = [ l2' ];
        assignment = Assignment.assign state'.assignment v2 false None;
      }
  in
  assert_equal `NoConflict conflict'';
  assert_equal (Some false) (Assignment.value_of_literal state''.assignment l1);
  assert_equal (Some false) (Assignment.value_of_literal state''.assignment l2);
  assert_equal (Some true) (Assignment.value_of_literal state''.assignment l3)

let test_resolve _ =
  let c1 = Clause.create [ l1'; l2 ] in
  let c2 = Clause.create [ l1; l3' ] in
  let c = Solver.resolve c1 c2 v1 in
  assert_equal [ l3'; l2 ] (Clause.literals c)

let test_conflict_analysis _ =
  let c1 = Clause.create [ l2'; l3'; l4'; l5 ] in
  let c2 = Clause.create [ l1'; l5'; l6 ] in
  let c3 = Clause.create [ l5'; l7 ] in
  let c4 = Clause.create [ l1'; l6'; l7' ] in
  let c5 = Clause.create [ l1'; l2'; l5 ] in
  let c6 = Clause.create [ l1'; l3'; l5 ] in
  let c7 = Clause.create [ l1'; l4'; l5 ] in
  let c7 = Clause.create [ l1'; l2; l3; l4; l5; l6' ] in
  let f = Formula.create [ c1; c2; c3; c4; c5; c6; c7 ] in
  let state = Solver.init_watches f in

  let a1 = Assignment.assign { Assignment.empty with dl = 1 } v1 true None in
  let state', conflict' =
    Solver.unit_propagation
      { state with assignment = a1; to_propagate = [ l1 ] }
  in
  assert_equal `NoConflict conflict';

  let a2 = Assignment.assign { a1 with dl = 2 } v2 true None in
  let state'', conflict'' =
    Solver.unit_propagation
      { state' with assignment = a2; to_propagate = [ l2 ] }
  in
  let dl, learned =
    match conflict'' with
    | `Conflict clause -> Solver.conflict_analysis clause state''.assignment
    | `NoConflict -> failwith "Expected a conflict"
  in
  assert_equal 1 dl;
  assert_equal [ l5'; l1' ] (Clause.literals learned)

module TrueFirstSolver = Solver.Make (Heuristic.OrderedTrueFirst)
module FalseFirstSolver = Solver.Make (Heuristic.OrderedFalseFirst)
module RandomSolver = Solver.Make (Heuristic.Random)

let test_cdcl_solve_0 _ =
  let c0 = Clause.create [ l2'; l3' ] in
  let c1 = Clause.create [ l1'; l2 ] in
  let c2 = Clause.create [ l1 ] in
  let f = Formula.create [ c0; c1; c2 ] in

  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);
  assert_equal (Some true) (Assignment.value_of_literal assignment l1);
  assert_equal (Some true) (Assignment.value_of_literal assignment l2);
  assert_equal (Some false) (Assignment.value_of_literal assignment l3);

  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);
  assert_equal (Some true) (Assignment.value_of_literal assignment l1);
  assert_equal (Some true) (Assignment.value_of_literal assignment l2);
  assert_equal (Some false) (Assignment.value_of_literal assignment l3);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);
  assert_equal (Some true) (Assignment.value_of_literal assignment l1);
  assert_equal (Some true) (Assignment.value_of_literal assignment l2);
  assert_equal (Some false) (Assignment.value_of_literal assignment l3)

let test_cdcl_solve_1 _ =
  let c1 = Clause.create [ l2'; l3'; l4'; l5 ] in
  let c2 = Clause.create [ l1'; l5'; l6 ] in
  let c3 = Clause.create [ l5'; l7 ] in
  let c4 = Clause.create [ l1'; l6'; l7' ] in
  let c5 = Clause.create [ l1'; l2'; l5 ] in
  let c6 = Clause.create [ l1'; l3'; l5 ] in
  let c7 = Clause.create [ l1'; l4'; l5 ] in
  let c8 = Clause.create [ l1'; l2; l3; l4; l5; l6' ] in
  let f = Formula.create [ c1; c2; c3; c4; c5; c6; c7; c8 ] in
  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);

  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f)

let test_cdcl_solve_2 _ =
  let c1 = Clause.create [ l1 ] in
  let c2 = Clause.create [ l1'; l2 ] in
  let c3 = Clause.create [ l2'; l3 ] in
  let c4 = Clause.create [ l3' ] in
  let f = Formula.create [ c1; c2; c3; c4 ] in
  assert_equal `UNSAT (TrueFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (FalseFirstSolver.cdcl_solve f);
  assert_equal `UNSAT (RandomSolver.cdcl_solve f)

let test_cdcl_solve_3 _ =
  let c = Clause.create [ l1; l2; l3 ] in
  let f = Formula.create [ c ] in

  let assignment =
    match TrueFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);
  let assignment =
    match FalseFirstSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f);

  let assignment =
    match RandomSolver.cdcl_solve f with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected a solution"
  in
  assert_equal true (Assignment.satisfy assignment f)

let test_cdcl_solve_4 _ =
  let c1 = Clause.create [ l1; l2 ] in
  let c2 = Clause.create [ l1' ] in
  let c3 = Clause.create [ l2' ] in
  let f = Formula.create [ c1; c2; c3 ] in
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
