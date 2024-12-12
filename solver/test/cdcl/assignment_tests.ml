open OUnit2
open Cdcl
open Cdcl.Variable

[@@@warning "-26"]

let v1 = Var 1
let v2 = Var 2
let v3 = Var 3
let l1 = Literal.create v1 Positive
let l1' = Literal.create v1 Negative
let l2 = Literal.create v2 Positive
let l2' = Literal.create v2 Negative
let l3 = Literal.create v3 Positive
let l3' = Literal.create v3 Negative

let test_value _ =
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal (Some true) (Assignment.value_of_literal a l1);
  assert_equal (Some false) (Assignment.value_of_literal a l1');
  assert_equal None (Assignment.value_of_literal a l2);
  assert_equal None (Assignment.value_of_literal a l2')

let test_antecedent _ =
  let c = Clause.create [ l1 ] in
  let a = Assignment.assign Assignment.empty v1 true (Some c) in
  assert_equal (Some c) (Assignment.antecedent a v1);
  assert_equal None (Assignment.antecedent a v2)

let test_dl _ =
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal (Some 0) (Assignment.dl a v1);
  assert_equal None (Assignment.dl a v2)

let test_assign _ =
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal (Some true) (Assignment.value_of_literal a l1);
  let a' = Assignment.assign a v1 false None in
  assert_equal (Some false) (Assignment.value_of_literal a' l1)

let test_unassign _ =
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal (Some true) (Assignment.value_of_literal a l1);
  let a' = Assignment.unassign a v1 in
  assert_equal None (Assignment.value_of_literal a' l1)

let test_satisfy _ =
  let c0 = Clause.create [ l1; l2 ] in
  let c1 = Clause.create [ l1; l2'; l3 ] in
  let c2 = Clause.create [ l1; l3 ] in
  let f = Formula.create [ c0; c1; c2 ] in
  assert_equal false (Assignment.satisfy Assignment.empty f);
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal true (Assignment.satisfy a f);

  let a = Assignment.assign Assignment.empty v2 true None in
  assert_equal false (Assignment.satisfy a f);
  let a' = Assignment.assign a v3 true None in
  assert_equal true (Assignment.satisfy a' f)

let test_string_of_t _ =
  let a = Assignment.assign Assignment.empty v1 true None in
  assert_equal "1" (Assignment.string_of_t a);
  let a = Assignment.assign a v2 false None in
  assert_equal "1 -2" (Assignment.string_of_t a)

let series =
  "Assignment tests"
  >::: [
         "Test value" >:: test_value;
         "Test antecedent" >:: test_antecedent;
         "Test dl" >:: test_dl;
         "Test assign" >:: test_assign;
         "Test unassign" >:: test_unassign;
         "Test satisfy" >:: test_satisfy;
         "Test string_of_t" >:: test_string_of_t;
       ]
