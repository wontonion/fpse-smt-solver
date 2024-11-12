open Dream
let hello_handler = 
  get "/" (fun _ -> html "Hello from Dream!") 

let routes = [ hello_handler ] 


let cors_middleware =
  let allow_cors = fun handler request ->
 let headers = [
      "Access-Control-Allow-Origin", "*";
      "Access-Control-Allow-Headers", "Content-Type, Authorization";
      "Access-Control-Allow-Methods", "GET, POST, PUT, DELETE, OPTIONS";
    ] in 
    match Dream.method_ request with
    | `OPTIONS -> Dream.respond ~headers ""
    | _ -> handler request
  in 
  Dream.middleware_of_fn allow_cors

let () = run ~interface:"0.0.0.0" ~port:8080
  @@ logger
  @@ cors_middleware
  @@ router routes