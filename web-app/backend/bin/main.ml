let routes = [ Hello.hello_handler; Hello.backend_hello_handler ] 


let () = Dream.run ~interface:"0.0.0.0" ~port:8080 
  @@ Dream.logger
  @@ Dream.router routes
