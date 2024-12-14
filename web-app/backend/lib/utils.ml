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

(** Run a function with timeout (timeout in milliseconds) *)
let with_timeout ~timeout f =
  let task = f () in
  let timeout_thread = 
    let* () = Lwt_unix.sleep (float_of_int timeout /. 1000.0) in
    Lwt.cancel task;
    Lwt.return (Error "Task timed out")
  in
  Lwt.catch
    (fun () ->
      let* result = Lwt.pick [timeout_thread; (let* x = task in Lwt.return (Ok x))] in
      Lwt.cancel timeout_thread;
      Lwt.return result)
    (function
      | Lwt.Canceled -> Lwt.return (Error "Task timed out")
      | e -> Lwt.fail e)

let json_response data =
  let json_string = Yojson.Safe.to_string data in
  Dream.json json_string