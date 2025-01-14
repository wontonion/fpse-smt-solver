open OUnit2
open Utils

let test_with_timeout_success _ =
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
     abs(new_count - final_count) < 1000000)

let suite =
  "Utils Test Suite" >::: [
    "test_with_timeout_success" >:: test_with_timeout_success;
    "test_with_timeout_timeout" >:: test_with_timeout_timeout;
    "test_with_timeout_cancellation" >:: test_with_timeout_cancellation;
    "test_with_timeout_cpu_intensive" >:: test_with_timeout_cpu_intensive;
  ]

let () = run_test_tt_main suite