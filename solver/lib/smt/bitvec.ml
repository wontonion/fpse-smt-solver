open Cdcl

type t = Variable.t list

let constant (f : bool -> Cdcl.Variable.t) (n : int) =
  let rec aux (acc : Variable.t list) (n : int) (bits : int) : Variable.t list =
    if bits = 0 then acc else aux (f (n land 1 = 1) :: acc) (n lsr 1) (bits - 1)
  in
  List.rev @@ aux [] n 16

let value (a : Assignment.t) (v : t) =
  let rec aux (acc : int) (v : t) : int =
    match v with
    | [] -> acc
    | x :: xs ->
        aux
          ((acc lsl 1)
          + if Assignment.value_of_variable a x |> Option.get then 1 else 0)
          xs
  in
  aux 0 @@ List.rev v
