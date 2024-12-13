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

(** Run a task with timeout
    @param timeout Timeout in seconds
    @param f The function that returns a Lwt promise
    @return Lwt promise containing either the result or timeout error
*)
let with_timeout ~timeout f =
  let* result = 
    Lwt.pick [
      (let* () = Lwt_unix.sleep (float_of_int timeout) in
       Lwt.return (Error "Task timed out"));
      (let* x = f () in 
       Lwt.return (Ok x))
    ]
  in
  Lwt.return result

  