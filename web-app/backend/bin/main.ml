let routes = [ 
  Routes.hello_route; 
  Routes.generate_sudoku_route; 
  Routes.solve_sudoku_route;
  Routes.solve_formula_route;
  Routes.timeout_test_route
] 


let () = Dream.run ~interface:"0.0.0.0" ~port:8080 
  @@ Dream.logger
  @@ Dream.router routes