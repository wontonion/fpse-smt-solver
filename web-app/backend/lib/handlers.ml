
let json_response data =
  Dream.json (Yojson.Safe.to_string data)

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

let solve_sudoku_handler =
    let _ = Cdcl.Literal.create 1 true in
    Dimacs.Parser.parse "p cnf 3 1\n1 0\n"


