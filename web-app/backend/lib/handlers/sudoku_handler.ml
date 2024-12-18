open Core

let generate_sudoku_handler (request : Dream.request) : Dream.response Lwt.t =
  let block_size =
    match Dream.query request "blockSize" with
    | Some size -> int_of_string_opt size |> Option.value ~default:3
    | None -> 3
  in

  if not (List.mem Sudoku_utils.sudoku_block_sizes block_size ~equal:Int.equal) then
    let json_string = "Block size must be either 2 or 3" in
    Utils.build_simple_json_string 
      ~msg:json_string
      ~problem_type:Utils_types.Sudoku
    |> Dream.json 
      ~status:`Bad_Request 

  else
    let%lwt result =
      Utils.with_timeout ~timeout:5000 (fun () ->
          try Ok (Sudoku_utils.generate_puzzle ~block_size)
          with e -> Error (Exn.to_string e))
    in

    match result with
    | Ok grid ->
        let sudoku_data = Sudoku_utils.to_frontend_sudoku_data grid in
        Utils.build_string_from_json 
          ~msg:"Sudoku puzzle generated successfully" 
          ~problem_type:Utils_types.Sudoku 
          ~data:(Some sudoku_data) 
          ~data_to_yojson:Utils_types.sudoku_data_to_yojson
        |> Dream.json 
          ~status:`OK

    | Error msg ->
        let json_string = "Failed to generate sudoku puzzle: " ^ msg in
        Utils.build_simple_json_string 
          ~msg:json_string
          ~problem_type:Utils_types.Sudoku
        |> Dream.json
          ~status:`Internal_Server_Error


let solve_sudoku_handler (request : Dream.request) : Dream.response Lwt.t =
 let%lwt body = Dream.body request in
      try
        let json = Yojson.Safe.from_string body in
        let data: Utils_types.sudoku_data = Sudoku_utils.to_backend_sudoku_data json in
        let int_grid = Sudoku_utils.to_int_grid data.grid in
        let%lwt result =
          Utils.with_timeout ~timeout:10000 (fun () ->
              try Ok (Sudoku_utils.solve_sudoku int_grid data.size)
              with e -> Error (Exn.to_string e))
        in 

        match result with
        | Ok result ->
          let grid = Result.ok_or_failwith result in
            let merged_grid =
              Sudoku_utils.merge_grid_with_initial grid data.grid
            in
            Utils.build_string_from_json 
              ~msg:"Sudoku solved successfully" 
              ~problem_type:Utils_types.Sudoku 
              ~data:(Some { Utils_types.size = data.size; Utils_types.grid = merged_grid }) 
              ~data_to_yojson:Utils_types.sudoku_data_to_yojson
            |> Dream.json 
              ~status:`OK

        | Error msg ->
            let json_string = "Failed to solve sudoku: " ^ msg in
            Utils.build_simple_json_string 
              ~msg:json_string
              ~problem_type:Utils_types.Sudoku
            |> Dream.json
              ~status:`Internal_Server_Error

      with e ->
        let json_string = "Server error: " ^Exn.to_string e in
        Utils.build_simple_json_string 
          ~msg:json_string
          ~problem_type:Utils_types.Sudoku
        |> Dream.json
          ~status:`Internal_Server_Error
    