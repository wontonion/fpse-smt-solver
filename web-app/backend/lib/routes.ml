open Core
let hello_route =
  Dream.get "/api/hello" Handlers.hello_handler

let generate_sudoku_route =
  Dream.get "/api/sudoku/generate" Handlers.generate_sudoku_handler

let[@landmark] solve_sudoku_route =
  Dream.post "/api/sudoku/solve" Handlers.solve_sudoku_handler

let solve_formula_route =
  Dream.post "/api/solver/solve" Handlers.solve_formula_handler

let timeout_test_route =
  Dream.get "/api/timeout/test" (fun _ ->
    let expensive_fun (timeout_sec : float) : int Lwt.t =
      let rec loop n =
        let%lwt () = Lwt.pause () in (* Give a chance for Lwt to check if we have timed out yet *)
        if n <= 0
        then Lwt.return 0
        else
          let%lwt res = loop (n - 1) in
          Lwt.return (res + n)
      in
      Lwt_unix.with_timeout timeout_sec
      @@ fun () -> loop Core.Int.(10 ** 10) (* loop way too many times to finish in 1 second *)
    in
    let timeout_example () =
      try
        expensive_fun 3.0
        |> Lwt_main.run (* run the computation *)
        |> Result.return (* if we got here (because an exception could have been thrown in the line above) then the computation finished in time *)
      with
      | Lwt_unix.Timeout -> Result.fail "Timed out"
    in
    match timeout_example () with
    | Ok res -> Dream.json ~status:`OK (string_of_int res)
    | Error err -> Dream.json ~status:`Internal_Server_Error err
  )
