open Core
module RandomSolver = Cdcl.Solver.Make (Cdcl.Heuristic.Random)

let[@landmark] main () =
  let input = In_channel.input_all In_channel.stdin in
  let formula = Dimacs.Parser.parse input in
  match RandomSolver.cdcl_solve formula with
  | `UNSAT -> print_endline "UNSATISFIABLE"
  | `SAT assignment ->
      print_endline "SATISFIABLE";
      print_endline (Cdcl.Assignment.string_of_t assignment)

let () = main ()
