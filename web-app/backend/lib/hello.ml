open Types

let json_response data =
  Dream.json (Yojson.Safe.to_string data)

let hello_handler =
  Dream.get "/" (fun _ ->
    let response = {
      status = "success";
      message = "Hello from Dream!";
      data = None;
    } in
    json_response (response_to_yojson (fun _ -> `Null) response))

let backend_hello_handler =
  Dream.get "/backend/hello" (fun _ ->
    let sample_data = {
      problem_type = Boolean;
      assignments = Some [("x1", "true"); ("x2", "false")];
      time_taken = 0.001;
    } in
    let response = {
      status = "success";
      message = "Hello from Dream(backend)!";
      data = Some sample_data;
    } in
    json_response (response_to_yojson solution_to_yojson response))
