
open Cdcl

module RandomSolver = Solver.Make (Heuristic.Randomized)

let solve_sat_formula (dimacs : string) : string =
  match Dimacs.Parser.parse dimacs with
  | Error msg -> msg
  | Ok formula -> (
      match RandomSolver.cdcl_solve formula with
      | `SAT assignment ->
          "SATISFIABLE\n" ^ Assignment.string_of_t assignment ^ "\n"
      | `UNSAT -> "UNSATISFIABLE\n")

let solve_smt_formula (smt : string) : string =
  match Vm.Parser.parse smt with
  | Error msg -> msg
  | Ok context -> (
      match Smt.Context.solve context with
      | `SAT assignment ->
          "SATISFIABLE\n" ^ Smt.Context.to_string context assignment ^ "\n"
      | `UNSAT -> "UNSATISFIABLE\n")