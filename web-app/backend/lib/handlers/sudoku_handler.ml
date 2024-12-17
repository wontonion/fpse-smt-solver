let generate_sudoku_handler (request : Dream.request) : Dream.response Lwt.t =
  let block_size =
    match Dream.query request "blockSize" with
    | Some size -> int_of_string_opt size |> Option.value ~default:3
    | None -> 3
  in

  if not (List.mem block_size [ 2; 3 ]) then
    let json_string = "Block size must be either 2 or 3" in
    Utils.build_simple_json_string ~msg:json_string
    |> Dream.json 
      ~status:`Bad_Request 
    (* Utils.build_error_response ~message:"Block size must be either 2 or 3"
      ~problem_type:Types.Sudoku () *)
  else
    let%lwt result =
      Utils.with_timeout ~timeout:5000 (fun () ->
          try Ok (Sudoku_utils.generate_puzzle ~block_size)
          with e -> Error (Printexc.to_string e))
    in

    match result with
    | Ok grid ->
        let sudoku_data = Sudoku_utils.convert_to_sudoku_data grid in
        Utils.build_string_from_json 
          ~msg:"Sudoku puzzle generated successfully" 
          ~problem_type:Types.Sudoku 
          ~data:(Some sudoku_data) 
          ~data_to_yojson:Types.sudoku_data_to_yojson
        |> Dream.json 
          ~status:`OK
        (* Utils.build_sudoku_response
          ~message:"Sudoku puzzle generated successfully" ~data:sudoku_data *)
    | Error msg ->
        let json_string = "Failed to generate sudoku puzzle: " ^ msg in
        Utils.build_simple_json_string ~msg:json_string
        |> Dream.json
          ~status:`Internal_Server_Error
        (* Utils.build_error_response
          ~message:("Failed to generate sudoku puzzle: " ^ msg)
          ~problem_type:Types.Sudoku () *)


let solve_sudoku_handler (request : Dream.request) : Dream.response Lwt.t =
 let%lwt body = Dream.body request in
      try
        let json = Yojson.Safe.from_string body in
        let data = Sudoku_utils.convert_frontend_grid json in
        let int_grid =
          List.map
            (fun row -> 
              List.map
                (fun cell ->
                  if cell.Types.is_initial then
                    match cell.Types.value with
                    | "" -> 0
                    | s -> ( try int_of_string s with _ -> 0)
                  else 0)
                row)
            data.grid
        in
        let%lwt result =
          Utils.with_timeout ~timeout:10000 (fun () ->
              try Ok (Sudoku_utils.solve_sudoku int_grid data.size)
              with e -> Error (Printexc.to_string e))
              (* Utils.with_timeout_new ~timeout:1000 (fun () ->
                Sudoku.solve_sudoku int_grid data.size) *)
          (* Lwt_unix.with_timeout 1.0 
          (fun () ->
            (* let%lwt _ = Lwt_unix.sleep 0. in *)
            Lwt.return (Sudoku.solve_sudoku int_grid data.size)
          )*)
        in 

        match result with
        | Ok result ->
          let grid = Result.get_ok result in
            let merged_grid =
              List.map2
                (fun solved_row orig_row ->
                  List.map2
                    (fun solved_val orig_cell ->
                      {
                        Types.value = string_of_int solved_val;
                        Types.is_initial = orig_cell.Types.is_initial;
                        Types.is_valid = true;
                      })
                    solved_row orig_row)
                grid data.grid
            in
            Utils.build_string_from_json 
              ~msg:"Sudoku solved successfully" 
              ~problem_type:Types.Sudoku 
              ~data:(Some { Types.size = data.size; Types.grid = merged_grid }) 
              ~data_to_yojson:Types.sudoku_data_to_yojson
            |> Dream.json 
              ~status:`OK
            (* let response =
              {
                Types.status = "success";
                Types.message = "Sudoku solved successfully";
                Types.data =
                  Some { Types.size = data.size; Types.grid = merged_grid };
              }
            in
            Utils.json_response
              (Types.response_to_yojson Types.sudoku_data_to_yojson response) *)
        | Error msg ->
            let json_string = "Failed to solve sudoku: " ^ msg in
            Utils.build_simple_json_string ~msg:json_string
            |> Dream.json
              ~status:`Internal_Server_Error
            (* let error_response =
              {
                Types.status = "error";
                Types.message = "Failed to solve sudoku: " ^ msg;
                Types.data = None;
              }
            in
            Utils.json_response
              (Types.response_to_yojson Types.sudoku_data_to_yojson
                 error_response) *)
      with e ->
        let json_string = "Server error: " ^ Printexc.to_string e in
        Utils.build_simple_json_string ~msg:json_string
        |> Dream.json
          ~status:`Internal_Server_Error
        (* {
            Types.status = "error";
            Types.message = "Server error: " ^ Printexc.to_string e;
            Types.data = None;
          }
        in
        Utils.json_response
          (Types.response_to_yojson Types.sudoku_data_to_yojson error_response) *)
