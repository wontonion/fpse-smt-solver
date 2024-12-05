open Core
open OUnit2

let test_string_of_t _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l2 = Cdcl.Literal.create 2 true in
  let c = Cdcl.Clause.create [ l1; l2; l2 ] in
  assert_equal "-2 | 1" (Cdcl.Clause.string_of_t c)

let test_literals _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l2 = Cdcl.Literal.create 2 true in
  let c = Cdcl.Clause.create [ l1; l2 ] in
  assert_equal [ l2; l1 ] (Cdcl.Clause.literals c)

let test_variables _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l2 = Cdcl.Literal.create 2 true in
  let c = Cdcl.Clause.create [ l1; l2 ] in
  assert_equal true
  @@ Int.Set.equal (Int.Set.of_list [ 1; 2 ]) (Cdcl.Clause.variables c)

let test_equal _ =
  let l1 = Cdcl.Literal.create 1 false in
  let l1' = Cdcl.Literal.create 1 true in
  let l2 = Cdcl.Literal.create 2 false in
  let l2' = Cdcl.Literal.create 2 true in
  let c0 = Cdcl.Clause.create [ l1; l2 ] in
  let c0' = Cdcl.Clause.create [ l2; l1 ] in
  let c1 = Cdcl.Clause.create [ l1; l2' ] in
  let c2 = Cdcl.Clause.create [ l1'; l2 ] in
  let c3 = Cdcl.Clause.create [ l1'; l2' ] in
  assert_equal true (Cdcl.Clause.equal c0 c0');
  assert_equal false (Cdcl.Clause.equal c0 c1);
  assert_equal false (Cdcl.Clause.equal c0 c2);
  assert_equal false (Cdcl.Clause.equal c0 c3);
  assert_equal false (Cdcl.Clause.equal c1 c2);
  assert_equal false (Cdcl.Clause.equal c1 c3);
  assert_equal false (Cdcl.Clause.equal c2 c3)

let series =
  "Clause tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test literals" >:: test_literals;
         "Test variables" >:: test_variables;
         "Test equal" >:: test_equal;
       ]
