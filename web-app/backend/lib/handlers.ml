let hello_handler =
  Dream.get "/api/hello" (fun _ ->
      let sample_data =
        {
          Types.problem_type = Types.SAT;
          Types.data = "TODO: Implement SAT solver\nReceived formula:\n";
          Types.time_taken = 0.001;
        }
      in
      let response : Types.solution Types.response =
        {
          status = "success";
          message = "Hello from Dream(backend)!Do you hear me?";
          data = Some sample_data;
        }
      in
      Utils.json_response (Types.response_to_yojson Types.solution_to_yojson response))

let generate_sudoku_handler =
  Dream.get "/api/sudoku/generate" (fun request ->
    let block_size =
      match Dream.query request "blockSize" with
      | Some size -> int_of_string_opt size |> Option.value ~default:3
      | None -> 3
    in
    
    if not (List.mem block_size [2; 3]) then
      Utils.build_error_response 
        ~message:"Block size must be either 2 or 3" 
        ~problem_type:Types.Sudoku 
        ()
    else
      let%lwt result = 
        Utils.with_timeout ~timeout:1000 (fun () ->
          Lwt.return @@ Sudoku.generate_puzzle ~block_size ()
        )
      in
      
      match result with
      | Ok grid ->
          let sudoku_data = Sudoku.convert_to_sudoku_data grid in
          Utils.build_sudoku_response 
            ~message:"Sudoku puzzle generated successfully" 
            ~data:sudoku_data 
            ()
      | Error msg ->
          Utils.build_error_response 
            ~message:("Failed to generate sudoku puzzle: " ^ msg)
            ~problem_type:Types.Sudoku 
            ())

let solve_sudoku_handler =
  Dream.post "/api/sudoku/solve" (fun request ->
      let%lwt body = Dream.body request in
      try
        let json = Yojson.Safe.from_string body in
        let data = Sudoku.convert_frontend_grid json in
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

        match Sudoku.solve_sudoku int_grid data.size with
        | Ok grid ->
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
            let response =
              {
                Types.status = "success";
                Types.message = "Sudoku solved successfully";
                Types.data =
                  Some { Types.size = data.size; Types.grid = merged_grid };
              }
            in
            Utils.json_response
              (Types.response_to_yojson Types.sudoku_data_to_yojson response)
        | Error msg ->
            let error_response =
              {
                Types.status = "error";
                Types.message = "Failed to solve sudoku: " ^ msg;
                Types.data = None;
              }
            in
            Utils.json_response
              (Types.response_to_yojson Types.sudoku_data_to_yojson
                 error_response)
      with e ->
        let error_response =
          {
            Types.status = "error";
            Types.message = "Server error: " ^ Printexc.to_string e;
            Types.data = None;
          }
        in
        Utils.json_response
          (Types.response_to_yojson Types.sudoku_data_to_yojson error_response))

let solve_formula_handler =
  Dream.post "/api/solver/solve" (fun request ->
      let%lwt body = Dream.body request in
      try
        let json = Yojson.Safe.from_string body in
        let open Yojson.Safe.Util in
        let formula_type = member "type" json |> to_string in
        let formula_content = member "content" json |> to_string in

        let result =
          match formula_type with
          | "sat" -> Logical_solver.solve_sat_formula formula_content
          | "smt" -> Logical_solver.solve_smt_formula formula_content
          | _ -> failwith "Unknown formula type"
        in

        let response =
          {
            Types.status = "success";
            Types.message = "Formula received successfully";
            Types.data =
              Some
                {
                  Types.problem_type =
                    (if formula_type = "sat" then Types.SAT else Types.SMT);
                  Types.data = result;
                  Types.time_taken = 0.0;
                };
          }
        in
        Utils.json_response
          (Types.response_to_yojson Types.solution_to_yojson response)
      with e ->
        let error_response =
          {
            Types.status = "error";
            Types.message = "Failed to process formula: " ^ Printexc.to_string e;
            Types.data = None;
          }
        in
        Utils.json_response
          (Types.response_to_yojson Types.solution_to_yojson error_response))
