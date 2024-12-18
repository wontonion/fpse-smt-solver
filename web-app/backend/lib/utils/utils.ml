let build_simple_json_string ~msg ~problem_type =
  let body = {
    Utils_types.message = msg;
    Utils_types.problem_type = problem_type;
    Utils_types.data = None;
  } in
  body
  |> Utils_types.json_body_to_yojson (fun _ -> `Null)
  |> Yojson.Safe.to_basic
  |> Yojson.Basic.to_string

let build_string_from_json ~msg ~problem_type ~data ~data_to_yojson =
  let body = {
    Utils_types.message = msg;
    Utils_types.problem_type = problem_type;
    Utils_types.data = data;
  } in
  body
  |> Utils_types.json_body_to_yojson data_to_yojson
  |> Yojson.Safe.to_basic
  |> Yojson.Basic.to_string

[@@@coverage off]
(* this version directly terminate the process *)
let with_timeout ~timeout ?on_cancel f =
  let pid_ref = ref None in
  
  let task = 
    Lwt.catch
      (fun () ->
        let%lwt result = 
          Lwt_preemptive.detach
            (fun () ->
              pid_ref := Some (Unix.getpid ());
              Printf.printf "Process ID: %d\n%!" (match !pid_ref with Some pid -> pid | None -> -1);
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
            (match !pid_ref with
             | Some pid -> 
                 (try Unix.kill pid Sys.sigkill 
                  with Unix.Unix_error _ -> ())
             | None -> ());
            Lwt.return (Error "Task timed out")
        | e -> Lwt.return (Error ("Unexpected error: " ^ Printexc.to_string e)))
  in

  let timeout_thread = 
    Lwt.cancel task;
    let%lwt () = Lwt_unix.sleep (float_of_int timeout /. 1000.0) in
    (match !pid_ref with
     | Some pid -> 
         (try Unix.kill pid Sys.sigkill 
          with Unix.Unix_error _ -> ())
     | None -> ());
    Lwt.return (Error "Task timed out")
  in

  let%lwt result = Lwt.pick [
    (let%lwt x = task in Lwt.return x);
    timeout_thread
  ] in
  Lwt.cancel timeout_thread;
  Lwt.return result
[@@@coverage on]

(* didn't terminate calculation but cancel the promise *)
(* let with_timeout ~timeout ?on_cancel f =
  let task = 
    Lwt.catch
      (fun () ->
        let%lwt () = Lwt.pause () in  (* Allow other tasks to run *)
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
      let%lwt () = Lwt_unix.sleep (float_of_int timeout /. 1000.0) in
      Lwt.cancel task;
      Lwt.return (Error "Task timed out")
    in
  
    let%lwt result = Lwt.pick [
      (let%lwt x = task in Lwt.return x);
      timeout_thread
    ] in
    Lwt.cancel timeout_thread;
  Lwt.return result *)



