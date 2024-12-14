open OUnit2
open Cdcl
open Smt

let ctx = Context.empty
let f = Context.bConst ctx
let bTrue = Context.bTrue ctx
let bFalse = Context.bFalse ctx

let test_xor _ =
  let ctx', o = Bitop.op_xor ctx { i0 = bFalse; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_xor ctx { i0 = bFalse; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_xor ctx { i0 = bTrue; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_xor ctx { i0 = bTrue; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get)

let test_and _ =
  let ctx', o = Bitop.op_and ctx { i0 = bFalse; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_and ctx { i0 = bFalse; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_and ctx { i0 = bTrue; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_and ctx { i0 = bTrue; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get)

let test_or _ =
  let ctx', o = Bitop.op_or ctx { i0 = bFalse; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_or ctx { i0 = bFalse; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_or ctx { i0 = bTrue; i1 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_or ctx { i0 = bTrue; i1 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get)

let test_not _ =
  let ctx', o = Bitop.op_not ctx { i0 = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.o0 |> Option.get);

  let ctx', o = Bitop.op_not ctx { i0 = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.o0 |> Option.get)

let test_eq _ =
  let ctx' = Bitop.constraint_eq ctx { i0 = bFalse; i1 = bFalse } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal true sat;

  let ctx' = Bitop.constraint_eq ctx { i0 = bFalse; i1 = bTrue } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat;

  let ctx' = Bitop.constraint_eq ctx { i0 = bTrue; i1 = bFalse } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat;

  let ctx' = Bitop.constraint_eq ctx { i0 = bTrue; i1 = bTrue } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal true sat

let test_neq _ =
  let ctx' = Bitop.constraint_neq ctx { i0 = bFalse; i1 = bFalse } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat;

  let ctx' = Bitop.constraint_neq ctx { i0 = bFalse; i1 = bTrue } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal true sat;

  let ctx' = Bitop.constraint_neq ctx { i0 = bTrue; i1 = bFalse } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal true sat;

  let ctx' = Bitop.constraint_neq ctx { i0 = bTrue; i1 = bTrue } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat

let test_add _ =
  let ctx', o = Bitop.op_add ctx { i0 = bFalse; i1 = bFalse; cin = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal false
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bFalse; i1 = bFalse; cin = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal false
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bFalse; i1 = bTrue; cin = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal false
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bFalse; i1 = bTrue; cin = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal true
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bTrue; i1 = bFalse; cin = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal false
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bTrue; i1 = bFalse; cin = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal true
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bTrue; i1 = bTrue; cin = bFalse } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal false (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal true
    (Assignment.value_of_variable assignment o.cout |> Option.get);

  let ctx', o = Bitop.op_add ctx { i0 = bTrue; i1 = bTrue; cin = bTrue } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true (Assignment.value_of_variable assignment o.s |> Option.get);
  assert_equal true
    (Assignment.value_of_variable assignment o.cout |> Option.get)

let series =
  "Op tests"
  >::: [
         "Test XOR" >:: test_xor;
         "Test AND" >:: test_and;
         "Test OR" >:: test_or;
         "Test NOT" >:: test_not;
         "Test EQ" >:: test_eq;
         "Test NEQ" >:: test_neq;
         "Test ADD" >:: test_add;
       ]
