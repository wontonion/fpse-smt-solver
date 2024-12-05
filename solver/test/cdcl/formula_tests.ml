open Core
open OUnit2

[@@@warning "-26"]

let test_string_of_t _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in

  let c1 = Cdcl.Clause.create [ l1; l2; l3 ] in
  let c2 = Cdcl.Clause.create [ l1'; l2'; l3' ] in

  assert_equal "(1 | 2 | 3) & (-3 | -2 | -1)"
    (Cdcl.Formula.string_of_t (Cdcl.Formula.create [ c1; c2 ]))

let test_clauses _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in

  let c1 = Cdcl.Clause.create [ l1; l2; l3 ] in
  let c2 = Cdcl.Clause.create [ l1'; l2'; l3' ] in

  assert_equal [ c1; c2 ]
    (Cdcl.Formula.clauses (Cdcl.Formula.create [ c1; c2 ]))

let test_variables _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in

  let c1 = Cdcl.Clause.create [ l1 ] in
  let c2 = Cdcl.Clause.create [ l2'; l3' ] in

  assert_equal true
  @@ Int.Set.equal
       (Int.Set.of_list [ 1; 2; 3 ])
       (Cdcl.Formula.variables (Cdcl.Formula.create [ c1; c2 ]))

let test_add_clause _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let l3 = Cdcl.Literal.create 3 false in
  let l3' = Cdcl.Literal.create 3 true in

  let c1 = Cdcl.Clause.create [ l1 ] in
  let c2 = Cdcl.Clause.create [ l2'; l3' ] in

  let f = Cdcl.Formula.create [ c1 ] in
  let f' = Cdcl.Formula.add_clause f c2 in

  assert_equal [ c2; c1 ] (Cdcl.Formula.clauses f')

let series =
  "Formula tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test clauses" >:: test_clauses;
         "Test variables" >:: test_variables;
         "Test add_clause" >:: test_add_clause;
       ]
