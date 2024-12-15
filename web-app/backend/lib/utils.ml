open Lwt.Syntax

let json_response data =
  Dream.json (Yojson.Safe.to_string data)

let build_response ~status ~message ?data to_yojson =
  let response = {
    Types.status;
    Types.message;
    Types.data;
  } in
  json_response (Types.response_to_yojson to_yojson response)

let build_success_response ~message ?data to_yojson =
  build_response ~status:"success" ~message ?data to_yojson

let build_error_response_with_converter ?(code=400) ~message ?data to_yojson =
  let response = {
    Types.status = "error";
    Types.message = message;
    Types.data = data;
  } in
  Lwt.return (Dream.response 
    ~code
    ~headers:["Content-Type", "application/json"]
    (Yojson.Safe.to_string (Types.response_to_yojson to_yojson response)))

(** Build a standard JSON response for Sudoku problems *)
let build_sudoku_response ?(status="success") ~message ?data () =
  build_response ~status ~message ?data Types.sudoku_data_to_yojson

(** Build a standard JSON response for SAT/SMT solutions *)
let build_solution_response ?(status="success") ~message ?data () =
  build_response ~status ~message ?data Types.solution_to_yojson

(** Build a standard JSON response for SAT/SMT problems *)
let build_problem_response ?(status="success") ~message ?data () =
  build_response ~status ~message ?data Types.problem_to_yojson

(** Build an error response *)
let build_error_response ?(code=400) ~message ~problem_type () =
  match problem_type with
  | Types.Sudoku -> 
      build_error_response_with_converter ~code ~message Types.sudoku_data_to_yojson
  | Types.SAT | Types.SMT -> 
      build_error_response_with_converter ~code ~message Types.solution_to_yojson


let with_timeout ~timeout ?on_cancel f =
  let task = 
    Lwt.catch
      (fun () ->
        let%lwt result = Lwt_preemptive.detach
          (fun () ->
            try
              f ()
            with e ->
              Error ("Exception: " ^ Printexc.to_string e))
          ()
        in
        Lwt.return result)
      (function
        | Lwt.Canceled ->
            (match on_cancel with
             | Some cb -> cb ()
             | None -> ());
            Lwt.return (Error "Task timed out")
        | e -> Lwt.return (Error ("Unexpected error: " ^ Printexc.to_string e)))
  in

  let timeout_thread = 
    let* () = Lwt_unix.sleep (float_of_int timeout /. 1000.0) in
    Lwt.cancel task;
    Lwt.return (Error "Task timed out")
  in

  let* result = Lwt.pick [
    (let* x = task in Lwt.return x);
    timeout_thread
  ] in
  Lwt.cancel timeout_thread;
  Lwt.return result



