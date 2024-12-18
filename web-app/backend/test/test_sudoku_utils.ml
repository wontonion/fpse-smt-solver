open OUnit2
open Sudoku_utils

let test_create_empty_grid_3x3 _ =
  let grid = create_empty_grid ~block_size:3 in
  assert_equal 9 (List.length grid) ~msg:"3x3 grid should have 9 rows";
  assert_equal 9 (List.length (List.hd grid)) ~msg:"3x3 grid should have 9 columns";
  assert_bool "all cells should be 0" 
    (List.for_all (List.for_all ((=) 0)) grid)

let test_create_empty_grid_2x2 _ =
  let grid = create_empty_grid ~block_size:2 in
  assert_equal 4 (List.length grid) ~msg:"2x2 grid should have 4 rows";
  assert_equal 4 (List.length (List.hd grid)) ~msg:"2x2 grid should have 4 columns";
  assert_bool "all cells should be 0" 
    (List.for_all (List.for_all ((=) 0)) grid)
  

let test_is_valid_3x3 _ =
  let grid = create_empty_grid ~block_size:3 in
  let grid = update_grid grid 0 0 5 in
  assert_bool "should not allow same number in row" 
    (not (is_valid grid 0 1 5 ~block_size:3));
  assert_bool "should allow different number"
    (is_valid grid 0 1 6 ~block_size:3)
  

let test_is_valid_2x2 _ =
  let grid = create_empty_grid ~block_size:2 in
  let grid = update_grid grid 0 0 2 in
  assert_bool "should not allow same number in row" 
    (not (is_valid grid 0 1 2 ~block_size:2));
  assert_bool "should allow different number"
    (is_valid grid 0 1 3 ~block_size:2);
  assert_bool "should allow number 0 in column"
    (is_valid grid 0 0 0 ~block_size:2)

let test_get_row _ =
  let grid = create_empty_grid ~block_size:3 in
  let grid = update_grid grid 0 1 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_row grid 0)

let test_get_col _ =
  let grid = create_empty_grid ~block_size:3 in
  let grid = update_grid grid 1 0 5 in
  assert_equal [0; 5; 0; 0; 0; 0; 0; 0; 0] (get_col grid 0)

let test_get_block_3x3 _ =
  let grid = create_empty_grid ~block_size:3 in
  let grid = update_grid grid 0 0 5 in
  let grid = update_grid grid 1 1 6 in
  assert_equal [5; 0; 0; 0; 6; 0; 0; 0; 0] (get_block grid 0 0 ~block_size:3)

let test_get_block_2x2 _ =
  let grid = create_empty_grid ~block_size:2 in
  let grid = update_grid grid 0 0 2 in
  let grid = update_grid grid 1 1 3 in
  assert_equal [2; 0; 0; 3] (get_block grid 0 0 ~block_size:2)

let test_update_grid _ =
  let grid = create_empty_grid ~block_size:3 in
  let grid = update_grid grid 0 0 5 in
  assert_equal 5 (List.hd (List.hd grid)) ~msg:"should update value at position"


let test_count_solution _ =
  let grid = create_empty_grid ~block_size:3 in
  let result = count_solution grid 0 ~block_size:3 in
  assert_equal 0 result ~msg:"count_solution should return 0 when max_solutions is 0"

let test_generate_puzzle_size _ =
  let grid_3x3 = generate_puzzle ~block_size:3 in
  let grid_2x2 = generate_puzzle ~block_size:2 in
  assert_equal 9 (List.length grid_3x3) ~msg:"3x3 grid should have 9 rows";
  assert_equal 4 (List.length grid_2x2) ~msg:"2x2 grid should have 4 rows";
  assert_equal 9 (List.length (List.hd grid_3x3)) ~msg:"3x3 grid should have 9 columns";
  assert_equal 4 (List.length (List.hd grid_2x2)) ~msg:"2x2 grid should have 4 columns"

let test_invalid_block_size _ =
  assert_raises 
    (Failure "Block size must be either 2 or 3")
    (fun () -> generate_puzzle ~block_size:4)

(* let test_solve_grid_failure _ =
  let grid = create_empty_grid ~block_size:3 in
  (* Create an impossible grid by putting same number in same row *)
  let grid = update_grid grid 0 0 1 in
  let grid = update_grid grid 0 1 1 in
  assert_equal None (solve_grid grid ~block_size:3) 
    ~msg:"solve_grid should return None for impossible grid" *)

(* let test_solve_sudoku_2x2_success _ =
  let input_grid = [
    [0; 0; 0; 2];
    [2; 0; 0; 0];
    [0; 0; 0; 3];
    [1; 0; 0; 0]
  ] in
  match solve_sudoku input_grid 4 with
  | Ok solved_grid ->
      (* Check grid size *)
      assert_equal 4 (List.length solved_grid) ~msg:"Grid should have 4 rows";
      assert_equal 4 (List.length (List.hd solved_grid)) ~msg:"Grid should have 4 columns";
      
      (* Verify each number is between 1 and 4 *)
      List.iter (fun row ->
        List.iter (fun num ->
          assert_bool "Numbers should be between 1 and 4" (num >= 1 && num <= 4)
        ) row
      ) solved_grid;
      
      (* Verify the initial numbers are preserved *)
      assert_equal 2 (List.nth (List.nth solved_grid 0) 3);
      assert_equal 2 (List.nth (List.nth solved_grid 1) 0);
      assert_equal 3 (List.nth (List.nth solved_grid 2) 3);
      assert_equal 1 (List.nth (List.nth solved_grid 3) 0)
  | Error msg -> 
      assert_failure ("Should successfully solve the grid but got error: " ^ msg)

 let test_solve_sudoku_invalid_size _ =
  let invalid_grid = [
    [0; 0; 0];
    [0; 0; 0];
    [0; 0; 0]
  ] in
  match solve_sudoku invalid_grid 3 with
  | Ok _ -> assert_failure "Should fail with invalid grid size"
  | Error msg -> 
      assert_equal "Invalid grid size" msg
        ~msg:"Should return error message for invalid grid size"

let test_solve_sudoku_unsolvable _ =
  let unsolvable_grid = [
    [1; 1; 0; 0];
    [0; 0; 0; 0];
    [0; 0; 0; 0];
    [0; 0; 0; 0]
  ] in
  match solve_sudoku unsolvable_grid 4 with
  | Ok _ -> assert_failure "Should fail with unsolvable grid"
  | Error msg -> 
      assert_equal "Unsatisfiable" msg
        ~msg:"Should return unsatisfiable for impossible grid" *)

let test_bool_to_value _ =
  (* Test case 1: size 2 *)
  assert_equal [1; 2] 
    (bool_ls_to_int_ls 2 [true; false; false; true]) 
    ~msg:"Should convert [true; false; false; true] to [1; 2] for size 2";
  
  (* Test case 2: size 3 *)
  assert_equal [2; 1; 3] 
    (bool_ls_to_int_ls 3 [false; true; false; true; false; false; false; false; true])
    ~msg:"Should correctly convert boolean list to values for size 3";
    
  (* Test case 3: empty list *)
  assert_equal [] 
    (bool_ls_to_int_ls 2 []) 
    ~msg:"Should handle empty list";
    
  (* Test case 4: all false *)
  assert_equal [0; 0] 
    (bool_ls_to_int_ls 2 [false; false; false; false])
    ~msg:"Should handle list with all false values"

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
    "test_count_solution" >:: test_count_solution;
    "test_generate_puzzle_size" >:: test_generate_puzzle_size;
    "test_invalid_block_size" >:: test_invalid_block_size;
    (* "test_solve_grid_failure" >:: test_solve_grid_failure; *)
    (* "test_solve_sudoku_2x2_success" >:: test_solve_sudoku_2x2_success;
    "test_solve_sudoku_invalid_size" >:: test_solve_sudoku_invalid_size;
    "test_solve_sudoku_unsolvable" >:: test_solve_sudoku_unsolvable; *)
    "test_bool_to_value" >:: test_bool_to_value;
  ]

let () = run_test_tt_main suite