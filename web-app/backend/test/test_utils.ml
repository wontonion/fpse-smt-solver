open OUnit2
open Utils

let test_successful_execution _ =
  let result = 
    Lwt_main.run (
      with_timeout ~timeout:1000 (fun () ->
        Unix.sleep 0;  (* 立即返回的任务 *)
        Ok "success"
      )
    )
  in
  assert_equal (Ok "success") result

let test_timeout _ =
  let result = 
    Lwt_main.run (
      with_timeout ~timeout:100 (fun () ->
        Unix.sleep 1;  (* 睡眠1秒，会触发超时 *)
        Ok "should not reach here"
      )
    )
  in
  assert_equal (Error "Task timed out") result

let test_error_propagation _ =
  let result =
    Lwt_main.run (
      with_timeout ~timeout:1000 (fun () ->
        Error "custom error"
      )
    )
  in
  assert_equal (Error "custom error") result

let test_exception_handling _ =
  let result =
    Lwt_main.run (
      with_timeout ~timeout:1000 (fun () ->
        raise (Invalid_argument "test exception");
      )
    )
  in
  Printf.printf "Exception handling test received: %s\n" 
    (match result with 
     | Ok s -> "Ok: " ^ s 
     | Error s -> "Error: " ^ s);
  assert_equal 
    (Error "Exception: Invalid_argument(\"test exception\")")
    result

let test_on_cancel_callback _ =
  let was_cancelled = ref false in
  let result = 
    Lwt_main.run (
      with_timeout 
        ~timeout:100 
        ~on_cancel:(fun () -> 
          was_cancelled := true;
          Printf.printf "Cancel callback executed, was_cancelled = %b\n" !was_cancelled)
        (fun () ->
          Unix.sleep 1;  (* 这会导致超时 *)
          Ok "should not reach here"
        )
    )
  in
  Printf.printf "On cancel test received: %s\n" 
    (match result with 
     | Ok s -> "Ok: " ^ s 
     | Error s -> "Error: " ^ s);
  Printf.printf "Final was_cancelled value: %b\n" !was_cancelled;
  assert_equal (Error "Task timed out") result

let suite =
  "Utils tests" >::: [
    "test successful execution" >:: test_successful_execution;
    "test timeout" >:: test_timeout;
    "test error propagation" >:: test_error_propagation;
    "test exception handling" >:: test_exception_handling;
    "test on_cancel callback" >:: test_on_cancel_callback;
  ]

let () =
  run_test_tt_main suite
