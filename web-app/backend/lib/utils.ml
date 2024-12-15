open Types
open Lwt.Syntax

(** Build a standard JSON response for Sudoku problems *)
let build_sudoku_response ?(status="success") ~message ?data () =
  let response = {
    status;
    message;
    data;
  } in
  Dream.json (Yojson.Safe.to_string (response_to_yojson sudoku_data_to_yojson response))

(** Build a standard JSON response for SAT/SMT solutions *)
let build_solution_response ?(status="success") ~message ?data () =
  let response = {
    status;
    message;
    data;
  } in
  Dream.json (Yojson.Safe.to_string (response_to_yojson solution_to_yojson response))

(** Build a standard JSON response for SAT/SMT problems *)
let build_problem_response ?(status="success") ~message ?data () =
  let response = {
    status;
    message;
    data;
  } in
  Dream.json (Yojson.Safe.to_string (response_to_yojson problem_to_yojson response))

(** Build an error response *)
let build_error_response ~message ~problem_type () =
  let error_message = match problem_type with
    | Sudoku -> build_sudoku_response ~status:"error" ~message ()
    | SAT | SMT -> build_solution_response ~status:"error" ~message ()
  in
  error_message

(** Run a computation with timeout and cancellation support
    @param timeout Timeout in milliseconds
    @param on_cancel Optional callback when task is cancelled
    @param f The computation to run
*)
let with_timeout ~timeout ?on_cancel f =
  let cancelled = ref false in
  let pid = Unix.getpid () in
  
  Printf.printf "[PID:%d] Starting computation\n%!" pid;
  
  let task = 
    Lwt.catch
      (fun () ->
        let%lwt result = Lwt_preemptive.detach
          (fun () ->
            Printf.printf "[PID:%d] Worker thread started\n%!" pid;
            if !cancelled then (
              Printf.printf "[PID:%d] Task cancelled early\n%!" pid;
              Error "Cancelled"
            ) else (
              try
                f cancelled
              with e ->
                Printf.printf "[PID:%d] Error in computation: %s\n%!" 
                  pid (Printexc.to_string e);
                Error (Printexc.to_string e)
            ))
          ()
        in
        Lwt.return result)
      (function
        | Lwt.Canceled ->
            Printf.printf "[PID:%d] Task cancelled\n%!" pid;
            cancelled := true;
            (match on_cancel with
             | Some cb -> cb ()
             | None -> ());
            Lwt.return (Error "Cancelled")
        | e -> 
            Printf.printf "[PID:%d] Error: %s\n%!" pid (Printexc.to_string e);
            Lwt.fail e)
  in

  let timeout_thread = 
    let* () = Lwt_unix.sleep (float_of_int timeout /. 1000.0) in
    Lwt.cancel task;
    Lwt.return (Error "Task timed out")
  in

  Lwt.catch
    (fun () ->
      let* result = Lwt.pick [timeout_thread; (let* x = task in Lwt.return x)] in
      Lwt.cancel timeout_thread;
      Lwt.return result)
    (function
      | Lwt.Canceled -> Lwt.return (Error "Task timed out")
      | e -> Lwt.fail e)

let json_response data =
  let json_string = Yojson.Safe.to_string data in
  Dream.json json_string




