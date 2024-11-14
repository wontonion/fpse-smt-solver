open Dream
let hello_handler = 
  get "/" (fun _ -> html "Hello from Dream!") 

let routes = [ hello_handler ] 

let () = run ~interface:"0.0.0.0" ~port:8080
  @@ logger
  @@ router routes