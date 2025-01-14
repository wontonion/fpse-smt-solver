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

let test_example _ =
  let input = "p cnf 3 2\n1 2 -3 0\n-2 3 0" in
  let c1 = Clause.create [ l1; l2; l3' ] in
  let c2 = Clause.create [ l2'; l3 ] in
  let expected = [ c1; c2 ] in
  let actual =
    match Dimacs.Parser.parse input with Error msg -> failwith msg | Ok f -> f
  in
  assert_equal expected @@ Formula.clauses actual

let test_invalid_variable _ =
  let input = "p cnf 3 1\n1 2 -4 0" in
  assert_equal (Error "Invalid variable in clause") (Dimacs.Parser.parse input)

let test_wrong_number_of_clauses _ =
  let input = "p cnf 3 2\n1 2 -3 0" in
  assert_equal (Error "Too few clauses") (Dimacs.Parser.parse input);
  let input = "p cnf 3 2\n1 2 -3 0\n-2 3 0\n1 2 3 0" in
  assert_equal (Error "Too many clauses") (Dimacs.Parser.parse input)

let test_invalid_header _ =
  let input = "d cnf 3 2\n1 2 -3 0\n-2 3 0" in
  assert_equal (Error "Invalid DIMACS header") (Dimacs.Parser.parse input);
  let input = "p dnf 3 2\n1 2 -3 0\n-2 3 0" in
  assert_equal (Error "Invalid DIMACS header") (Dimacs.Parser.parse input);
  let input = "p cnf 1" in
  assert_equal (Error "Invalid DIMACS header") (Dimacs.Parser.parse input)

let test_invalid_parameter _ =
  let input = "p cnf 0 2\n1 2 -3 0\n-2 3 0" in
  assert_equal (Error "Invalid number of variables") (Dimacs.Parser.parse input);
  let input = "p cnf 3 0\n1 2 -3 0\n-2 3 0" in
  assert_equal (Error "Invalid number of clauses") (Dimacs.Parser.parse input)

let test_invalid_clause _ =
  let input = "p cnf 3 2\n 1" in
  assert_equal (Error "Invalid clause: missing terminating zero")
    (Dimacs.Parser.parse input);
  let input = "p cnf d c\n a" in
  assert_equal (Error "Invalid number of variables") (Dimacs.Parser.parse input)

let series =
  "Parser tests"
  >::: [
         "Test example" >:: test_example;
         "Test invalid variable" >:: test_invalid_variable;
         "Test wrong number of clauses" >:: test_wrong_number_of_clauses;
         "Test invalid header" >:: test_invalid_header;
         "Test invalid parameter" >:: test_invalid_parameter;
         "Test invalid clause" >:: test_invalid_clause;
       ]
