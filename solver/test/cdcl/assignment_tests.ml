open OUnit2

[@@@warning "-26"]

let test_value _ =
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal (Some true)
    (Cdcl.Assignment.value a @@ Cdcl.Literal.create 1 false);
  assert_equal (Some false)
    (Cdcl.Assignment.value a @@ Cdcl.Literal.create 1 true);
  assert_equal None (Cdcl.Assignment.value a @@ Cdcl.Literal.create 2 false);
  assert_equal None (Cdcl.Assignment.value a @@ Cdcl.Literal.create 2 true)

let test_antecedent _ =
  let c = Cdcl.Clause.create [ Cdcl.Literal.create 1 false ] in
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true (Some c) in
  assert_equal (Some c) (Cdcl.Assignment.antecedent a 1);
  assert_equal None (Cdcl.Assignment.antecedent a 2)

let test_dl _ =
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal (Some 0) (Cdcl.Assignment.dl a 1);
  assert_equal None (Cdcl.Assignment.dl a 2)

let test_assign _ =
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal (Some true)
    (Cdcl.Assignment.value a @@ Cdcl.Literal.create 1 false);
  let a' = Cdcl.Assignment.assign a 1 false None in
  assert_equal (Some false)
    (Cdcl.Assignment.value a' @@ Cdcl.Literal.create 1 false)

let test_unassign _ =
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal (Some true)
    (Cdcl.Assignment.value a @@ Cdcl.Literal.create 1 false);
  let a' = Cdcl.Assignment.unassign a 1 in
  assert_equal None (Cdcl.Assignment.value a' @@ Cdcl.Literal.create 1 false)

let test_satisfy _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in
  let c0 = Cdcl.Clause.create [ l1; l2 ] in
  let c1 = Cdcl.Clause.create [ l1; l2'; l3 ] in
  let c2 = Cdcl.Clause.create [ l1; l3 ] in
  let f = Cdcl.Formula.create [ c0; c1; c2 ] in
  assert_equal false (Cdcl.Assignment.satisfy Cdcl.Assignment.empty f);
  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 1 true None in
  assert_equal true (Cdcl.Assignment.satisfy a f);

  let a = Cdcl.Assignment.assign Cdcl.Assignment.empty 2 true None in
  assert_equal false (Cdcl.Assignment.satisfy a f);
  let a' = Cdcl.Assignment.assign a 3 true None in
  assert_equal true (Cdcl.Assignment.satisfy a' f)

let series =
  "Assignment tests"
  >::: [
         "Test value" >:: test_value;
         "Test antecedent" >:: test_antecedent;
         "Test dl" >:: test_dl;
         "Test assign" >:: test_assign;
         "Test unassign" >:: test_unassign;
         "Test satisfy" >:: test_satisfy;
       ]
