open OUnit2
open Smt

let ctx = Context.empty
let f = Context.bConst
let bTrue = Context.bTrue
let bFalse = Context.bFalse

let test_xor _ =
  let bv1 = Bitvec.constant f 47165 in
  let bv2 = Bitvec.constant f 63577 in
  let ctx', o = Bvop.op_xor ctx { i0 = bv1; i1 = bv2 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 16484 @@ Bitvec.value assignment o.o0

let test_and _ =
  let bv1 = Bitvec.constant f 26922 in
  let bv2 = Bitvec.constant f 16230 in
  let ctx', o = Bvop.op_and ctx { i0 = bv1; i1 = bv2 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 10530 @@ Bitvec.value assignment o.o0

let test_or _ =
  let bv1 = Bitvec.constant f 35451 in
  let bv2 = Bitvec.constant f 11492 in
  let ctx', o = Bvop.op_or ctx { i0 = bv1; i1 = bv2 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 44799 @@ Bitvec.value assignment o.o0

let test_not _ =
  let bv1 = Bitvec.constant f 26844 in
  let ctx', o = Bvop.op_not ctx { i0 = bv1 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 38691 @@ Bitvec.value assignment o.o0

let test_eq _ =
  let bv1 = Bitvec.constant f 47165 in
  let bv2 = Bitvec.constant f 63577 in
  let bv3 = Bitvec.constant f 16484 in
  let ctx', bv4 = Bvop.op_var ctx in
  let ctx', o = Bvop.op_xor ctx' { i0 = bv1; i1 = bv2 } in
  let ctx' = Bvop.constraint_eq ctx' { i0 = o.o0; i1 = bv4.o0 } in
  let ctx' = Bvop.constraint_eq ctx' { i0 = o.o0; i1 = bv3 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 16484 @@ Bitvec.value assignment o.o0;
  assert_equal 16484 @@ Bitvec.value assignment bv4.o0;

  let bv5 = Bitvec.constant f 26922 in
  let ctx', o = Bvop.op_xor ctx { i0 = bv1; i1 = bv2 } in
  let ctx' = Bvop.constraint_eq ctx' { i0 = o.o0; i1 = bv5 } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat

let test_neq0 _ =
  let bv1 = Bitvec.constant f 65533 in
  let bv2 = Bitvec.constant f 3 in
  let ctx', o = Bvop.op_add ctx { i0 = bv1; i1 = bv2 } in
  let ctx' = Bvop.constraint_neq0 ctx' { i0 = o.o0 } in
  let sat = match Context.solve ctx' with `SAT _ -> true | `UNSAT -> false in
  assert_equal false sat

let test_add _ =
  let bv1 = Bitvec.constant f 60321 in
  let bv2 = Bitvec.constant f 34073 in
  let ctx', o = Bvop.op_add ctx { i0 = bv1; i1 = bv2 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 28858 @@ Bitvec.value assignment o.o0

let test_shl _ =
  let bv1 = Bitvec.constant f 25109 in
  let i = 3 in
  let ctx', o = Bvop.op_shl ctx { i0 = bv1; i1 = i } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 4264 @@ Bitvec.value assignment o.o0

let test_mul _ =
  let bv1 = Bitvec.constant f 12051 in
  let i = 5 in
  let ctx', o = Bvop.op_mul ctx { i0 = bv1; i1 = i } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 60255 @@ Bitvec.value assignment o.o0;

  let bv1 = Bitvec.constant f 12871 in
  let i = 4 in
  let ctx', o = Bvop.op_mul ctx { i0 = bv1; i1 = i } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal 51484 @@ Bitvec.value assignment o.o0

let test_solve_equation _ =
  let ctx', bv1 = Bvop.op_var ctx in
  let ctx', bv2 = Bvop.op_mul ctx' { i0 = bv1.o0; i1 = 3 } in
  let ctx', bv3 = Bvop.op_add ctx' { i0 = bv2.o0; i1 = Bitvec.constant f 4 } in
  let ctx', bv4 = Bvop.op_xor ctx' { i0 = bv1.o0; i1 = Bitvec.constant f 14 } in
  let ctx' = Bvop.constraint_eq ctx' { i0 = bv3.o0; i1 = bv4.o0 } in
  let assignment =
    match Context.solve ctx' with
    | `SAT assignment -> assignment
    | `UNSAT -> assert_failure "UNSAT"
  in
  assert_equal true @@ List.mem (Bitvec.value assignment bv1.o0) [ 32771; 3 ]

let series =
  "BitOp tests"
  >::: [
         "Test XOR" >:: test_xor;
         "Test AND" >:: test_and;
         "Test OR" >:: test_or;
         "Test NOT" >:: test_not;
         "Test EQ" >:: test_eq;
         "Test NEQ0" >:: test_neq0;
         "Test ADD" >:: test_add;
         "Test SHL" >:: test_shl;
         "Test MUL" >:: test_mul;
         "Test solve equation" >:: test_solve_equation;
       ]
