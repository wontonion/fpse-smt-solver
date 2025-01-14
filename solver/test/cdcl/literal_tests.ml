open OUnit2
open Cdcl
open Cdcl.Variable

let v1 = Var 1
let v2 = Var 2

let test_string_of_t _ =
  let l = Literal.create v1 Positive in
  assert_equal "1" (Literal.string_of_t l);
  let l' = Literal.create v1 Negative in
  assert_equal "-1" (Literal.string_of_t l')

let test_neg _ =
  let l = Literal.create v1 Positive in
  let l' = Literal.neg l in
  assert_equal false @@ Literal.polarity_to_bool l'.polarity;
  assert_equal v1 l'.variable;
  let l = Literal.create v1 Negative in
  let l' = Literal.neg l in
  assert_equal true @@ Literal.polarity_to_bool l'.polarity;
  assert_equal v1 l'.variable

let test_equal _ =
  let l = Literal.create v1 Positive in
  let l' = Literal.create v1 Positive in
  assert_equal true (Literal.equal l l');
  let l = Literal.create v1 Positive in
  let l' = Literal.create v1 Negative in
  assert_equal false (Literal.equal l l');
  let l = Literal.create v1 Positive in
  let l' = Literal.create v2 Positive in
  assert_equal false (Literal.equal l l')

let series =
  "Literal tests"
  >::: [
         "Test string_of_t" >:: test_string_of_t;
         "Test neg" >:: test_neg;
         "Test equal" >:: test_equal;
       ]
