open OUnit2
open Utils

let test_build_simple_json_string _ =
  let json_string1 = build_simple_json_string ~msg:"test sat" ~problem_type:Utils_types.SAT in
  let json_string2 = build_simple_json_string ~msg:"test smt" ~problem_type:Utils_types.SMT in
  let json_string3 = build_simple_json_string ~msg:"test sudoku" ~problem_type:Utils_types.Sudoku in
  let expected_string1 = "{\"message\":\"test sat\",\"problem_type\":\"SAT\",\"data\":null}" in
  let expected_string2 = "{\"message\":\"test smt\",\"problem_type\":\"SMT\",\"data\":null}" in
  let expected_string3 = "{\"message\":\"test sudoku\",\"problem_type\":\"Sudoku\",\"data\":null}" in
  assert_equal 
    (Yojson.Safe.from_string expected_string1) 
    (Yojson.Safe.from_string json_string1);
  assert_equal 
    (Yojson.Safe.from_string expected_string2) 
    (Yojson.Safe.from_string json_string2);
  assert_equal 
    (Yojson.Safe.from_string expected_string3) 
    (Yojson.Safe.from_string json_string3)

let test_build_string_from_json _ =
  let json_string1 = build_string_from_json ~msg:"test" ~problem_type:Utils_types.SAT ~data:None ~data_to_yojson:Utils_types.sat_smt_data_to_yojson in
  let json_string2 = build_string_from_json ~msg:"test" ~problem_type:Utils_types.SMT ~data:None ~data_to_yojson:Utils_types.sat_smt_data_to_yojson in
  let json_string3 = build_string_from_json ~msg:"test" ~problem_type:Utils_types.Sudoku ~data:None ~data_to_yojson:Utils_types.sudoku_data_to_yojson in
  let expected_string1 = "{\"message\":\"test\",\"problem_type\":\"SAT\",\"data\":null}" in
  let expected_string2 = "{\"message\":\"test\",\"problem_type\":\"SMT\",\"data\":null}" in
  let expected_string3 = "{\"message\":\"test\",\"problem_type\":\"Sudoku\",\"data\":null}" in
  assert_equal 
    (Yojson.Safe.from_string expected_string1) 
    (Yojson.Safe.from_string json_string1);
  assert_equal 
    (Yojson.Safe.from_string expected_string2) 
    (Yojson.Safe.from_string json_string2);
  assert_equal 
    (Yojson.Safe.from_string expected_string3) 
    (Yojson.Safe.from_string json_string3)

(* let test_with_timeout_success _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:2000 (fun () ->
      Ok "success"
    )
  ) in
  assert_equal (Ok "success") result

let test_with_timeout_timeout _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      Unix.sleep 2;
      Ok "should not reach here"
    )
  ) in
  assert_equal (Error "Task timed out") result

let test_with_timeout_cancellation _ =
  let start_time = Unix.gettimeofday () in
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      while true do
        Unix.sleepf 0.1;
      done;
      Ok "never reaches here"
    )
  ) in
  let end_time = Unix.gettimeofday () in
  let execution_time = end_time -. start_time in
  
  Printf.printf "Execution time: %.2f seconds\n" execution_time;
  (* check execution time whether it is around 1 second *)
  assert_bool "Execution should be around 1 second (timeout value)" 
    (execution_time >= 0.9 && execution_time <= 1.5);
  assert_equal (Error "Task timed out") result

let test_with_timeout_cpu_intensive _ =
  let counter = ref 0 in
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      let rec heavy_computation n =
        if n mod 1000000 = 0 then counter := n;
        heavy_computation (n + 1)
      in
      heavy_computation 0;
  
    )
  ) in
  Unix.sleep 2;
  let final_count = !counter in
  Printf.printf "Final counter value: %d\n" final_count;
  assert_equal (Error "Task timed out") result;
  assert_bool "Counter should stop increasing after timeout" 
    (let new_count = !counter in
     Printf.printf "Counter after 2s: %d\n" new_count;
     abs(new_count - final_count) < 1000000) *)

let suite =
  "Utils Test Suite" >::: [
    "test_build_simple_json_string" >:: test_build_simple_json_string;
    "test_build_string_from_json" >:: test_build_string_from_json;
    (* "test_with_timeout_success" >:: test_with_timeout_success;
    "test_with_timeout_timeout" >:: test_with_timeout_timeout;
    "test_with_timeout_cancellation" >:: test_with_timeout_cancellation;
    "test_with_timeout_cpu_intensive" >:: test_with_timeout_cpu_intensive; *)
  ]

let () = run_test_tt_main suite