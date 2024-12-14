open OUnit2
open Utils
open Lwt.Syntax

let test_with_timeout_success _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:2000 (fun () ->
      let* () = Lwt_unix.sleep 1.0 in
      Lwt.return "success"
    )
  ) in
  assert_equal (Ok "success") result

let test_with_timeout_timeout _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      let* () = Lwt_unix.sleep 2.0 in
      Lwt.return "should not reach here"
    )
  ) in
  assert_equal (Error "Task timed out") result

let test_with_timeout_cancellation _ =
  let counter = ref 0 in
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      let rec loop () =
        let* () = Lwt_unix.sleep 0.1 in
        incr counter;
        loop ()
      in
      loop ()
    )
  ) in
  Unix.sleep 2;
  assert_bool "Counter should be limited due to cancellation" (!counter < 15);
  assert_equal (Error "Task timed out") result

let test_with_timeout_cpu_intensive _ =
  let counter = ref 0 in
  let result = Lwt_main.run (
    with_timeout ~timeout:1000 (fun () ->
      Lwt_preemptive.detach (fun () ->
        let rec heavy_computation n =
          if n mod 1000000 = 0 then counter := n;
          heavy_computation (n + 1)
        in
        heavy_computation 0
      ) ()
    )
  ) in
  Unix.sleep 2;  (* Wait to ensure computation has been cancelled *)
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
