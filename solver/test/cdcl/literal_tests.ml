open OUnit2

let test_string_of_t _ =
  let l = Cdcl.Literal.create 1 false in
  assert_equal "1" (Cdcl.Literal.string_of_t l);
  let l = Cdcl.Literal.create 1 true in
  assert_equal "-1" (Cdcl.Literal.string_of_t l)

let test_neg _ =
  let l = Cdcl.Literal.create 1 false in
  let l' = Cdcl.Literal.neg l in
  assert_equal true l'.negation;
  assert_equal 1 l'.variable;
  let l = Cdcl.Literal.create 1 true in
  let l' = Cdcl.Literal.neg l in
  assert_equal false l'.negation;
  assert_equal 1 l'.variable

let test_equal _ =
  let l = Cdcl.Literal.create 1 false in
  let l' = Cdcl.Literal.create 1 false in
  assert_equal true (Cdcl.Literal.equal l l');
  let l = Cdcl.Literal.create 1 false in
  let l' = Cdcl.Literal.create 1 true in
  assert_equal false (Cdcl.Literal.equal l l');
  let l = Cdcl.Literal.create 1 false in
  let l' = Cdcl.Literal.create 2 false in
  assert_equal false (Cdcl.Literal.equal l l')

let test_variable _ =
  let l = Cdcl.Literal.create 1 false in
  assert_equal 1 (Cdcl.Literal.variable l);
  let l = Cdcl.Literal.create 2 false in
  assert_equal 2 (Cdcl.Literal.variable l)

let series =
  "Literal tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test neg" >:: test_neg;
         "Test equal" >:: test_equal;
         "Test variable" >:: test_variable;
       ]
