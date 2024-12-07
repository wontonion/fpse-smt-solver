open OUnit2

let test_example _ =
  let input = "p cnf 3 2\n1 2 -3 0\n-2 3 0" in
  let c1 =
    Cdcl.Clause.create
      [
        Cdcl.Literal.create 1 false;
        Cdcl.Literal.create 2 false;
        Cdcl.Literal.create 3 true;
      ]
  in
  let c2 =
    Cdcl.Clause.create
      [ Cdcl.Literal.create 2 true; Cdcl.Literal.create 3 false ]
  in
  let expected = [ c1; c2 ] in
  let actual = Dimacs.Parser.parse input in
  assert_equal expected @@ Cdcl.Formula.clauses actual

let test_invalid_variable _ =
  let input = "p cnf 3 1\n1 2 -4 0" in
  assert_raises (Failure "Invalid variable in clause") (fun () ->
      Dimacs.Parser.parse input)

let test_wrong_number_of_clauses _ =
  let input = "p cnf 3 2\n1 2 -3 0" in
  assert_raises (Failure "Too few clauses") (fun () ->
      Dimacs.Parser.parse input);
  let input = "p cnf 3 2\n1 2 -3 0\n-2 3 0\n1 2 3 0" in
  assert_raises (Failure "Too many clauses") (fun () ->
      Dimacs.Parser.parse input)

let test_invalid_header _ =
  let input = "d cnf 3 2\n1 2 -3 0\n-2 3 0" in
  assert_raises (Failure "Invalid DIMACS header") (fun () ->
      Dimacs.Parser.parse input);
  let input = "p dnf 3 2\n1 2 -3 0\n-2 3 0" in
  assert_raises (Failure "Invalid DIMACS header") (fun () ->
      Dimacs.Parser.parse input);
  let input = "p cnf 1" in
  assert_raises (Failure "Invalid DIMACS header") (fun () ->
      Dimacs.Parser.parse input)

let test_invalid_parameter _ =
  let input = "p cnf 0 2\n1 2 -3 0\n-2 3 0" in
  assert_raises (Failure "Invalid number of variables") (fun () ->
      Dimacs.Parser.parse input);
  let input = "p cnf 3 0\n1 2 -3 0\n-2 3 0" in
  assert_raises (Failure "Invalid number of clauses") (fun () ->
      Dimacs.Parser.parse input)

let series =
  "Parser tests"
  >::: [
         "Test example" >:: test_example;
         "Test invalid variable" >:: test_invalid_variable;
         "Test wrong number of clauses" >:: test_wrong_number_of_clauses;
         "Test invalid header" >:: test_invalid_header;
         "Test invalid parameter" >:: test_invalid_parameter;
       ]
