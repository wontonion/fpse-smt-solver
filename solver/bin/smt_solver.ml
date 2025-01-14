open Core

let[@landmark] main () =
  let input =
    match Sys.get_argv () |> Array.to_list with
    | _ :: [] -> In_channel.input_all In_channel.stdin [@coverage off]
    | [ _; input_file ] -> In_channel.read_all input_file
    | _ -> failwith "Invalid arguments" [@coverage off]
  in
  let context =
    match Vm.Parser.parse input with
    | Ok context -> context
    | Error message -> failwith message [@coverage off]
  in
  match Smt.Context.solve context with
  | `UNSAT -> print_endline "UNSATISFIABLE"
  | `SAT assignment ->
      print_endline "SATISFIABLE";
      Out_channel.output_string Out_channel.stdout
      @@ Smt.Context.to_string context assignment

let () = main ()
