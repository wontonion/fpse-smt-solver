open Core

let[@landmark] main () =
  let input =
    match Sys.get_argv () |> Array.to_list with
    | _ :: [] -> In_channel.input_all In_channel.stdin [@coverage off]
    | [ _; input_file ] -> In_channel.read_all input_file
    | _ -> failwith "Invalid arguments\n" [@coverage off]
  in
  let context = Vm.Parser.parse input in
  let assignment =
    match Smt.Context.solve context with
    | `SAT assignment -> assignment
    | `UNSAT -> failwith "UNSAT\n"
  in
  let output = Smt.Context.to_string context assignment in
  Out_channel.output_string Out_channel.stdout output

let () = main ()
