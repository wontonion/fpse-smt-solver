open OUnit2
open Sudoku

let test_create_empty_grid _ =
  let grid = create_empty_grid () in
  assert_equal 9 (List.length grid) ~msg:"grid should have 9 rows";
  assert_equal 9 (List.length (List.hd grid)) ~msg:"grid should have 9 columns";
  assert_bool "all cells should be 0" 
    (List.for_all (List.for_all ((=) 0)) grid)
  
let test_is_valid _ =
  let grid = create_empty_grid () in
  let grid = update_grid grid 0 0 5 in
  assert_bool "should not allow same number in row" 
    (not (is_valid grid 0 1 5));
  assert_bool "should allow different number"
    (is_valid grid 0 1 6)

let test_get_row _ =
  let grid = create_empty_grid () in
  let grid = update_grid grid 0 1 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_row grid 0)

let test_get_col _ =
  let grid = create_empty_grid () in
  let grid = update_grid grid 1 0 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_col grid 0)

let test_get_block _ =
  let grid = create_empty_grid () in
  let grid = update_grid grid 0 0 5 in
  let grid = update_grid grid 1 1 6 in
  assert_equal [5; 0; 0; 0; 6; 0; 0; 0; 0] (get_block grid 0 0)

let test_update_grid _ =
  let grid = create_empty_grid () in
  let grid = update_grid grid 0 0 5 in
  assert_equal 5 (List.hd (List.hd grid)) ~msg:"should update value at position"

let suite =
  "sudoku_tests" >::: [
    "test_create_empty_grid" >:: test_create_empty_grid;
    "test_is_valid" >:: test_is_valid;
    "test_get_row" >:: test_get_row;
    "test_get_col" >:: test_get_col;
    "test_get_block" >:: test_get_block;
    "test_update_grid" >:: test_update_grid;
  ]

let () = run_test_tt_main suite