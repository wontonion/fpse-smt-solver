open Core
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

let test_string_of_t _ =
  let c1 = Clause.create [ l1; l2; l3 ] in
  let c2 = Clause.create [ l1'; l2'; l3' ] in

  assert_equal "(1 | 2 | 3) & (-3 | -2 | -1)"
    (Formula.string_of_t (Formula.create [ c1; c2 ]))

let test_clauses _ =
  let c1 = Clause.create [ l1; l2; l3 ] in
  let c2 = Clause.create [ l1'; l2'; l3' ] in

  assert_equal [ c1; c2 ] (Formula.clauses (Formula.create [ c1; c2 ]))

let test_variables _ =
  let c1 = Clause.create [ l1 ] in
  let c2 = Clause.create [ l2'; l3' ] in

  assert_equal true
  @@ List.equal Variable.equal [ v1; v2; v3 ]
       (Set.to_list @@ Formula.variables (Formula.create [ c1; c2 ]))

let test_add_clause _ =
  let c1 = Clause.create [ l1 ] in
  let c2 = Clause.create [ l2'; l3' ] in

  let f = Formula.create [ c1 ] in
  let f' = Formula.add_clause f c2 in

  assert_equal [ c2; c1 ] (Formula.clauses f')

let series =
  "Formula tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test clauses" >:: test_clauses;
         "Test variables" >:: test_variables;
         "Test add_clause" >:: test_add_clause;
       ]
