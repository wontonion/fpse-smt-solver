let routes = [ 
  Handlers.hello_handler; 
  Handlers.generate_sudoku_handler; 
  Handlers.solve_sudoku_handler;
  Handlers.solve_formula_handler 
] 


let () = Dream.run ~interface:"0.0.0.0" ~port:8080 
  @@ Dream.logger
  @@ Dream.router routes
