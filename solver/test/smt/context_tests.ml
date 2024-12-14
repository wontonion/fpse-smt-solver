open OUnit2
open Smt

let test_constants _ =
  let ctx = Context.empty in
  assert_equal (Context.bTrue ctx) (Var 1);
  assert_equal (Context.bFalse ctx) (Var 2);
  assert_equal (Context.bConst ctx true) (Var 1);
  assert_equal (Context.bConst ctx false) (Var 2)

let test_var _ =
  let ctx = Context.empty in
  let ctx, var = Context.bVar ctx in
  assert_equal var (Var 3);
  let _, var = Context.bVar ctx in
  assert_equal var (Var 4)

let test_vars _ =
  let ctx = Context.empty in
  let ctx, vars = Context.bVars ctx 3 in
  assert_equal vars [ Var 3; Var 4; Var 5 ];
  let _, vars = Context.bVars ctx 2 in
  assert_equal vars [ Var 6; Var 7 ]

let series =
  "Context tests"
  >::: [
         "Test constants" >:: test_constants;
         "Test var" >:: test_var;
         "Test vars" >:: test_vars;
       ]
