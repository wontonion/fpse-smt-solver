open Core
open OUnit2
open Cdcl
open Cdcl.Variable

let v1 = Var 1
let v2 = Var 2
let v3 = Var 3
let l1 = Literal.create v1 Positive
let l1' = Literal.create v1 Negative
let l2 = Literal.create v2 Positive
let l2' = Literal.create v2 Negative
let l3 = Literal.create v3 Positive
let l3' = Literal.create v3 Negative

let test_string_of_t _ =
  let c = Clause.create [ l1; l2'; l2' ] in
  assert_equal "-2 | 1" (Clause.string_of_t c)

let test_literals _ =
  let c = Clause.create [ l1; l2' ] in
  assert_equal [ l2'; l1 ] (Clause.literals c)

let test_variables _ =
  let c = Clause.create [ l1; l2 ] in
  assert_equal true
  @@ List.equal Variable.equal [ v1; v2 ] (Set.to_list @@ Clause.variables c)

let test_equal _ =
  let c0 = Clause.create [ l1; l2 ] in
  let c0' = Clause.create [ l2; l1 ] in
  let c1 = Clause.create [ l1; l2' ] in
  let c2 = Clause.create [ l1'; l2 ] in
  let c3 = Clause.create [ l1'; l2' ] in
  assert_equal true (Clause.equal c0 c0');
  assert_equal false (Clause.equal c0 c1);
  assert_equal false (Clause.equal c0 c2);
  assert_equal false (Clause.equal c0 c3);
  assert_equal false (Clause.equal c1 c2);
  assert_equal false (Clause.equal c1 c3);
  assert_equal false (Clause.equal c2 c3)

let series =
  "Clause tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test literals" >:: test_literals;
         "Test variables" >:: test_variables;
         "Test equal" >:: test_equal;
       ]
