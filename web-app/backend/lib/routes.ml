let hello_route =
  Dream.get "/api/hello" Handlers.hello_handler

let generate_sudoku_route =
  Dream.get "/api/sudoku/generate" Handlers.generate_sudoku_handler

let solve_sudoku_route =
  Dream.post "/api/sudoku/solve" Handlers.solve_sudoku_handler

let solve_formula_route =
  Dream.post "/api/solver/solve" Handlers.solve_formula_handler
