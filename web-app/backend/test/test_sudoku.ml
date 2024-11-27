open OUnit2
open Sudoku

let test_create_empty_board _ =
  let board = create_empty_board () in
  assert_equal 9 (Array.length board) ~msg:"board should have 9 rows";
  assert_equal 9 (Array.length board.(0)) ~msg:"board should have 9 columns";
  assert_bool "all cells should be 0" 
    (Array.for_all (Array.for_all (fun x -> x = 0)) board)

let test_is_valid _ =
  let board = create_empty_board () in
  board.(0).(0) <- 5;
  assert_bool "should not allow same number in row" 
    (not (is_valid board 0 1 5));
  assert_bool "should allow different number"
    (is_valid board 0 1 6)

let suite =
  "sudoku_tests" >::: [
    "test_create_empty_board" >:: test_create_empty_board;
    "test_is_valid" >:: test_is_valid;
  ]

let () = run_test_tt_main suite