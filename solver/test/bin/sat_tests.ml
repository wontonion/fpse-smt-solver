open Core
open OUnit2

(* This has a non-exhaustive pattern match. Turn off warning -8 *)
[@@@ocaml.warning "-8"]

let string_of_seq (s : char Seq.t) : string =
  (* the pattern-matched argument in the following function is a "thawed" sequence *)
  let rec char_lst_of_seq (Seq.Cons (h, t)) lst =
    try char_lst_of_seq (t ()) (h :: lst) with _ -> List.rev lst
  in
  String.of_char_list @@ char_lst_of_seq (s ()) []

let assert_string_output (message : string) (expected : string)
    (cseq : char Seq.t) : unit =
  let actual = string_of_seq cseq |> String.strip in
  let expected = String.strip expected in
  (* get string from char Seq.t *)
  assert_bool
    (Printf.sprintf "Failed on: %s\n- expected: %s\n- actual: %s\n" message
       expected actual)
    (String.equal expected actual)

let exec_dir = "../bin/" (* note that cwd is _build/default/src-test *)
let test_dir = "../test/"

(* We may get timing errors when using dune exec -- src/filename.exe <args>, so we locate the executable and run it directly. *)
let test_exec (args : string) (expected : string) (ctxt : test_ctxt) : unit =
  assert_command
    ~foutput:(assert_string_output ("sat.exe " ^ args) expected)
      (* this is a function from char Seq.t to unit that throws an exception if the output is not as expected *)
    ~ctxt (exec_dir ^ "sat.exe")
    (String.split ~on:' ' args)
(* Arguments to exec *)

let test_example =
  test_exec (test_dir ^ "files/example.cnf") "SATISFIABLE\n1 2 -3\n"

let test_unsat = test_exec (test_dir ^ "files/unsat.cnf") "UNSATISFIABLE\n"

let test_sudoku =
  test_exec
    (test_dir ^ "files/sudoku.cnf")
    (In_channel.read_all (test_dir ^ "files/sudoku.cnf.sat"))

let series =
  "Sat tests"
  >::: [
         "Example" >:: test_example;
         "Unsat" >:: test_unsat;
         "Sudoku" >:: test_sudoku;
       ]
