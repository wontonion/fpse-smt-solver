open OUnit2

let test_example _ =
  let input = "VAR 1 MUL 3 CONST 4 ADD VAR 1 CONST 14 XOR EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success

let test_op _ =
  let input = "CONST 1 CONST 2 XOR CONST 3 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 1 CONST 2 AND CONST 1 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 1 CONST 2 OR CONST 3 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 1 NOT CONST 65534 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 1 NEQ0 END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 1 SHL 2 CONST 4 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "CONST 3 MUL 2 CONST 6 EQ END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal true success;

  let input = "INVALID" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success

let test_invalid_stack _ =
  let input = "CONST 1 END" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "XOR" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "AND" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "OR" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "NOT" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "EQ" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "NEQ0" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "ADD" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "SUB" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "SHL 1" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "MUL 3" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success

let test_invalid_param _ =
  let input = "VAR a" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "CONST a" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "SHL a" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success;

  let input = "MUL a" in
  let success =
    match Vm.Parser.parse input with Ok _ -> true | Error _ -> false
  in
  assert_equal false success

let series =
  "Parser tests"
  >::: [
         "Example" >:: test_example;
         "Op" >:: test_op;
         "Invalid stack" >:: test_invalid_stack;
         "Invalid param" >:: test_invalid_param;
       ]
