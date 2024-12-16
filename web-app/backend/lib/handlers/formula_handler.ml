let solve_formula_handler (request : Dream.request) : Dream.response Lwt.t =
  let%lwt body = Dream.body request in
  try
    let json = Yojson.Safe.from_string body in
      let open Yojson.Safe.Util in
      let formula_type = member "type" json |> to_string in
      let formula_content = member "content" json |> to_string in

      let%lwt result =
        Utils.with_timeout ~timeout:5000 (fun () ->
            try
              match formula_type with
              | "sat" -> Ok (Logical_solver.solve_sat_formula formula_content)
              | "smt" -> Ok (Logical_solver.solve_smt_formula formula_content)
              | _ -> Error "Unknown formula type"
            with e -> Error (Printexc.to_string e))
      in

      match result with
      | Ok solution ->
          Utils.build_solution_response
            ~message:"Formula received successfully"
            ~data:
              {
                Types.problem_type =
                  (if formula_type = "sat" then Types.SAT else Types.SMT);
                Types.data = solution;
                Types.time_taken = 0.0;
              }
            ()
      | Error msg ->
          Utils.build_error_response
            ~message:("Failed to process formula: " ^ msg)
            ~problem_type:Types.SAT ()
    with e ->
      Utils.build_error_response
        ~message:("Failed to process formula: " ^ Printexc.to_string e)
        ~problem_type:Types.SAT ()