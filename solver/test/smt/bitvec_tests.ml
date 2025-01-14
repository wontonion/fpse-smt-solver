open OUnit2
open Smt

let ctx = Context.empty
let f = Context.bConst
let bTrue = Context.bTrue
let bFalse = Context.bFalse

let test_constant _ =
  assert_equal
    [
      bTrue;
      bTrue;
      bTrue;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
      bFalse;
    ]
  @@ Bitvec.constant f 7

let test_value _ =
  let bv = Bitvec.constant f 7 in
  let assignment =
    match Context.solve ctx with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected SAT"
  in
  assert_equal 7 @@ Bitvec.value assignment bv

let test_value_random _ =
  let v = Random.int 65536 in
  let bv = Bitvec.constant f v in
  let assignment =
    match Context.solve ctx with
    | `SAT a -> a
    | `UNSAT -> failwith "Expected SAT"
  in
  assert_equal v @@ Bitvec.value assignment bv

let series =
  "Bitvec tests"
  >::: [
         "Test constant" >:: test_constant;
         "Test value" >:: test_value;
         "Test value random" >:: test_value_random;
       ]
