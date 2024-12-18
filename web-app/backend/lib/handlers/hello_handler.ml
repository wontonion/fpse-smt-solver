let hello_handler (_ : Dream.request) : Dream.response Lwt.t =
  (* let json_string = "Hello from Dream(backend)!" in
  Utils.build_simple_json_string ~msg:json_string
  |> Dream.json 
    ~status:`OK *)
  
  let%lwt result = Lwt_unix.with_timeout 
      1.0 
    (fun () ->
      let%lwt _ = Lwt_unix.sleep 2. in
      Lwt.return "Hello from Dream(backend)!" 
      )
  in
  Dream.json ~status:`OK result
  
  (* let with_timeout_test (sec: float) (func: ) *)
  