open OUnit2
open Sudoku

let test_create_empty_grid_3x3 _ =
  let grid = create_empty_grid ~block_size:3 () in
  assert_equal 9 (List.length grid) ~msg:"3x3 grid should have 9 rows";
  assert_equal 9 (List.length (List.hd grid)) ~msg:"3x3 grid should have 9 columns";
  assert_bool "all cells should be 0" 
    (List.for_all (List.for_all ((=) 0)) grid)

let test_create_empty_grid_2x2 _ =
  let grid = create_empty_grid ~block_size:2 () in
  assert_equal 4 (List.length grid) ~msg:"2x2 grid should have 4 rows";
  assert_equal 4 (List.length (List.hd grid)) ~msg:"2x2 grid should have 4 columns";
  assert_bool "all cells should be 0" 
    (List.for_all (List.for_all ((=) 0)) grid)
  
let test_is_valid_3x3 _ =
  let grid = create_empty_grid ~block_size:3 () in
  let grid = update_grid grid 0 0 5 in
  assert_bool "should not allow same number in row" 
    (not (is_valid grid 0 1 5 ~block_size:3));
  assert_bool "should allow different number"
    (is_valid grid 0 1 6 ~block_size:3)

let test_is_valid_2x2 _ =
  let grid = create_empty_grid ~block_size:2 () in
  let grid = update_grid grid 0 0 2 in
  assert_bool "should not allow same number in row" 
    (not (is_valid grid 0 1 2 ~block_size:2));
  assert_bool "should allow different number"
    (is_valid grid 0 1 3 ~block_size:2)

let test_get_row _ =
  let grid = create_empty_grid ~block_size:3 () in
  let grid = update_grid grid 0 1 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_row grid 0)

let test_get_col _ =
  let grid = create_empty_grid ~block_size:3 () in
  let grid = update_grid grid 1 0 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_col grid 0)

let test_get_block_3x3 _ =
  let grid = create_empty_grid ~block_size:3 () in
  let grid = update_grid grid 0 0 5 in
  let grid = update_grid grid 1 1 6 in
  assert_equal [5; 0; 0; 0; 6; 0; 0; 0; 0] (get_block grid 0 0 ~block_size:3)

let test_get_block_2x2 _ =
  let grid = create_empty_grid ~block_size:2 () in
  let grid = update_grid grid 0 0 2 in
  let grid = update_grid grid 1 1 3 in
  assert_equal [2; 0; 0; 3] (get_block grid 0 0 ~block_size:2)

let test_update_grid _ =
  let grid = create_empty_grid ~block_size:3 () in
  let grid = update_grid grid 0 0 5 in
  assert_equal 5 (List.hd (List.hd grid)) ~msg:"should update value at position"

let test_generate_puzzle_size _ =
  let grid_3x3 = generate_puzzle ~block_size:3 () in
  let grid_2x2 = generate_puzzle ~block_size:2 () in
  assert_equal 9 (List.length grid_3x3) ~msg:"3x3 grid should have 9 rows";
  assert_equal 4 (List.length grid_2x2) ~msg:"2x2 grid should have 4 rows";
  assert_equal 9 (List.length (List.hd grid_3x3)) ~msg:"3x3 grid should have 9 columns";
  assert_equal 4 (List.length (List.hd grid_2x2)) ~msg:"2x2 grid should have 4 columns"

let test_invalid_block_size _ =
  assert_raises 
    (Failure "Block size must be either 2 or 3")
    (fun () -> generate_puzzle ~block_size:4 ())

let suite =
  "sudoku_tests" >::: [
    "test_create_empty_grid_3x3" >:: test_create_empty_grid_3x3;
    "test_create_empty_grid_2x2" >:: test_create_empty_grid_2x2;
    "test_is_valid_3x3" >:: test_is_valid_3x3;
    "test_is_valid_2x2" >:: test_is_valid_2x2;
    "test_get_row" >:: test_get_row;
    "test_get_col" >:: test_get_col;
    "test_get_block_3x3" >:: test_get_block_3x3;
    "test_get_block_2x2" >:: test_get_block_2x2;
    "test_update_grid" >:: test_update_grid;
    "test_generate_puzzle_size" >:: test_generate_puzzle_size;
    "test_invalid_block_size" >:: test_invalid_block_size;
  ]

let () = run_test_tt_main suite