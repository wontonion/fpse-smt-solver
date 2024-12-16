let hello_handler (_ : Dream.request) : Dream.response Lwt.t =
  let json_string = "Hello from Dream(backend)!" in
  Utils.build_simple_json_string ~msg:json_string
  |> Dream.json 
    ~status:`OK
  (* Dream.json 
    ~status:`OK 
    message *)
