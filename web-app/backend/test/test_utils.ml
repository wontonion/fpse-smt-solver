open OUnit2
open Utils
open Lwt.Syntax

let test_with_timeout_success _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:2 (fun () ->
      let* () = Lwt_unix.sleep 1.0 in  (* 睡眠1秒，不会超时 *)
      Lwt.return "success"
    )
  ) in
  assert_equal (Ok "success") result

let test_with_timeout_timeout _ =
  let result = Lwt_main.run (
    with_timeout ~timeout:1 (fun () ->
      let* () = Lwt_unix.sleep 2.0 in  (* 睡眠2秒，会超时 *)
      Lwt.return "should not reach here"
    )
  ) in
  assert_equal (Error "Task timed out") result

let suite =
  "Utils Test Suite" >::: [
    "test_with_timeout_success" >:: test_with_timeout_success;
    "test_with_timeout_timeout" >:: test_with_timeout_timeout;
  ]

let () = run_test_tt_main suite
