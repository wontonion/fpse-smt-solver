
let hello_handler = 
  Dream.get "/" (fun _ -> Dream.html "Hello from Dream!") 

let backend_hello_handler = 
  Dream.get "/backend/hello" (fun _ -> Dream.html "Hello from Dream(backend)!Really?" )


let routes = [ hello_handler; backend_hello_handler ] 


let () = Dream.run ~interface:"0.0.0.0" ~port:8080 
  @@ Dream.logger
  @@ Dream.router routes
