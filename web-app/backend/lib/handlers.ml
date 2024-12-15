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
      Utils.json_response (Types.response_to_yojson Types.solution_to_yojson response)
  )

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
        let%lwt timeout_result = Utils.with_timeout ~timeout:5000 (fun _ ->
          try Ok (Sudoku.generate_puzzle ~block_size ())
          with e -> Error (Printexc.to_string e)
        ) in
        Lwt.return timeout_result
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
            ()
  )

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
                  | s -> (try int_of_string s with _ -> 0)
                else 0)
              row)
          data.grid
      in

      let%lwt result = Sudoku.solve_sudoku int_grid data.size in
      match result with
      | Ok grid ->
          let sudoku_data = Sudoku.convert_to_sudoku_data grid in
          Utils.build_sudoku_response 
            ~message:"Sudoku puzzle generated successfully" 
            ~data:sudoku_data 
            ()
      | Error msg ->
          Utils.build_error_response 
            ~message:("Failed to solve sudoku: " ^ msg)
            ~problem_type:Types.Sudoku 
            ()
    with e ->
      Utils.build_error_response
        ~message:("Server error: " ^ Printexc.to_string e)
        ~problem_type:Types.Sudoku
        ()
  )

let solve_formula_handler =
  Dream.post "/api/solver/solve" (fun request ->
    let%lwt body = Dream.body request in
    try
      let json = Yojson.Safe.from_string body in
      let open Yojson.Safe.Util in
      let formula_type = member "type" json |> to_string in
      let formula_content = member "content" json |> to_string in

      let%lwt result = 
        Utils.with_timeout ~timeout:5000 (fun _ ->
          try 
            let result = match formula_type with
              | "sat" -> Logical_solver.solve_sat_formula formula_content
              | "smt" -> Logical_solver.solve_smt_formula formula_content
              | _ -> failwith "Unknown formula type"
            in
            Ok result
          with e -> Error (Printexc.to_string e)
        )
      in

      match result with
      | Ok solution ->
          Utils.build_solution_response 
            ~message:"Formula received successfully"
            ~data:{
              Types.problem_type = (if formula_type = "sat" then Types.SAT else Types.SMT);
              Types.data = solution;
              Types.time_taken = 0.0;
            }
            ()
      | Error msg ->
          Utils.build_error_response
            ~message:("Failed to process formula: " ^ msg)
            ~problem_type:Types.SAT
            ()
    with e ->
      Utils.build_error_response
        ~message:("Failed to process formula: " ^ Printexc.to_string e)
        ~problem_type:Types.SAT
        ()
  )
