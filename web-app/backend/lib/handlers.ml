let json_response data =
  let json_string = Yojson.Safe.to_string data in
  Dream.json json_string

let hello_handler =
  Dream.get "/api/hello" (fun _ ->
    let sample_data = {
      Types.problem_type = Types.SAT;
      Types.assignments = Some [("x1", "true"); ("x2", "false")];
      Types.time_taken = 0.001;
    } in
    let response: Types.solution Types.response = {
      status = "success";
      message = "Hello from Dream(backend)!Do you hear me?";
      data = Some sample_data;
    } in
    json_response (Types.response_to_yojson Types.solution_to_yojson response))

let generate_sudoku_handler =
  Dream.get "/api/sudoku/generate" (fun _ ->
    try
      let grid = Sudoku.generate_puzzle_with_timeout ~timeout:2.0 () in
      let sudoku_data = Sudoku.convert_to_sudoku_data grid in
      Utils.build_sudoku_response 
        ~message:"Sudoku puzzle generated successfully"
        ~data:sudoku_data
        ()
    with
    | e -> 
        let error_response = {
          Types.status = "error";
          Types.message = "Failed to generate sudoku puzzle: " ^ Printexc.to_string e;
          Types.data = None
        } in
        json_response (Types.response_to_yojson Types.solution_to_yojson error_response)
  )


let convert_frontend_cell json =
  let open Yojson.Safe.Util in
  {
    Types.value = member "value" json |> to_string;
    Types.is_initial = member "isInitial" json |> to_bool;
    Types.is_valid = member "isValid" json |> to_bool;
  }

let convert_frontend_grid json =
  let open Yojson.Safe.Util in
  let size = member "size" json |> to_int in
  let grid = member "grid" json |> to_list |> List.map (fun row ->
    to_list row |> List.map convert_frontend_cell
  ) in
  { Types.size; Types.grid }

let solve_sudoku_handler =
  Dream.post "/api/sudoku/solve" (fun request ->
    let%lwt body = Dream.body request in
    try
      let json = Yojson.Safe.from_string body in
      let data = convert_frontend_grid json in
      (* Convert grid to int list list, keeping ONLY initial values *)
      let int_grid = List.map (fun row ->
        List.map (fun cell ->
          if cell.Types.is_initial then
            match cell.Types.value with
            | "" -> 0
            | s -> try int_of_string s with _ -> 0
          else
            0  (* Clear non-initial values *)
        ) row
      ) data.grid in
      
      (* TODO: Call actual solve function here *)
      let solved_grid = int_grid in (* Using initial grid for now *)
      
      (* Merge solved result with original isInitial flags *)
      let merged_grid = List.map2 (fun solved_row orig_row ->
        List.map2 (fun solved_val orig_cell ->
          { Types.value = string_of_int solved_val;
            Types.is_initial = orig_cell.Types.is_initial;
            Types.is_valid = true }
        ) solved_row orig_row
      ) solved_grid data.grid in
      
      let response = {
        Types.status = "success";
        Types.message = "Sudoku processed";
        Types.data = Some { Types.size = data.size; Types.grid = merged_grid };
      } in
      json_response (Types.response_to_yojson Types.sudoku_data_to_yojson response)
    with e ->
      let error_response = {
        Types.status = "error";
        Types.message = "Server error: " ^ Printexc.to_string e;
        Types.data = None;
      } in
      json_response (Types.response_to_yojson Types.sudoku_data_to_yojson error_response)
  )
