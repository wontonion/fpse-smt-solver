open Core
module RandomSolver = Cdcl.Solver.Make (Cdcl.Heuristic.Random)

let[@landmark] main () =
  let input =
    match Sys.get_argv () |> Array.to_list with
    | _ :: [] -> In_channel.input_all In_channel.stdin
    | [ _; input_file ] -> In_channel.read_all input_file
    | _ -> failwith "Invalid arguments\n"
  in
  let formula = Dimacs.Parser.parse input in
  match RandomSolver.cdcl_solve formula with
  | `UNSAT -> print_endline "UNSATISFIABLE"
  | `SAT assignment ->
      if not @@ Cdcl.Assignment.satisfy assignment formula then
        failwith "Should not happen! Assignment does not satisfy formula";
      print_endline "SATISFIABLE";
      print_endline (Cdcl.Assignment.string_of_t assignment)

let () = main ()
