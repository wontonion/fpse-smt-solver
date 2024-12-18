open Core

let solve_formula_handler (request : Dream.request) : Dream.response Lwt.t =
  let%lwt body = Dream.body request in
  try
    let json = Yojson.Safe.from_string body in
      let open Yojson.Safe.Util in
      let formula_type = member "type" json |> to_string in
      let formula_content = member "content" json |> to_string in
      let problem_type = 
        match formula_type with
        | "sat" -> Utils_types.SAT
        | "smt" -> Utils_types.SMT
        | _ -> failwith "Unknown formula type" in

      let%lwt result =
        Utils.with_timeout ~timeout:5000 (fun () ->
            try
              match formula_type with
              | "sat" -> Ok (Formula_utils.solve_sat_formula formula_content)
              | "smt" -> Ok (Formula_utils.solve_smt_formula formula_content)
              | _ -> Error "Unknown formula type"
            with e -> Error (Exn.to_string e))
      in
      
      match result with
      | Ok solution ->
        Utils.build_string_from_json 
          ~msg:"Formula received successfully" 
          ~problem_type:problem_type 
          ~data:(Some solution) 
          ~data_to_yojson:Utils_types.sat_smt_data_to_yojson
          |> Dream.json
          ~status:`OK

      | Error msg ->
        Utils.build_simple_json_string 
          ~msg:("Failed to process formula: " ^ msg)
          ~problem_type:problem_type
        |> Dream.json
          ~status:`Internal_Server_Error

    with e ->
      Utils.build_simple_json_string 
        ~msg:("Failed to process formula: " ^ Exn.to_string e)
        ~problem_type:Utils_types.SAT
        |> Dream.json
          ~status:`Internal_Server_Error
          
