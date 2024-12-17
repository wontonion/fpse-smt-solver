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
  
  (* let%lwt result = Utils.with_timeout ~timeout:1000 (fun () ->
    "Hello from Dream(backend)!"
  ) in
  result |> Lwt.return |> Dream.json ~status:`OK *)

  (* Dream.json 
    ~status:`OK 
    message *)
