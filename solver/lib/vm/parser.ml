open Core
open Smt

let parse (s : string) : Context.t =
  let rec parse_op (ops : string list) (ctx : Context.t) (stack : Bitvec.t list)
      : Context.t =
    match ops with
    | [] -> ctx
    | "END" :: ops -> (
        match stack with
        | [] -> parse_op ops ctx []
        | _ -> failwith "Invalid stack size")
    | "VAR" :: id :: ops ->
        let ctx, o = Context.bvNew ctx @@ Int.of_string id in
        parse_op ops ctx (o :: stack)
    | "CONST" :: n :: ops ->
        let bv = Bitvec.constant Context.bConst (Int.of_string n) in
        parse_op ops ctx (bv :: stack)
    | "XOR" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_xor ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for XOR")
    | "AND" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_and ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for AND")
    | "OR" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_or ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for OR")
    | "NOT" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx, o = Bvop.op_not ctx { i0 = op } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for NOT")
    | "EQ" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx = Bvop.constraint_eq ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx stack
        | _ -> failwith "Not enough operands for EQ")
    | "NEQ0" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx = Bvop.constraint_neq0 ctx { i0 = op } in
            parse_op ops ctx stack
        | _ -> failwith "Not enough operands for NEQ0")
    | "ADD" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_add ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for ADD")
    | "SHL" :: n :: ops -> (
        match stack with
        | op :: stack ->
            let ctx, o = Bvop.op_shl ctx { i0 = op; i1 = Int.of_string n } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for SHL")
    | "MUL" :: n :: ops -> (
        match stack with
        | op :: stack ->
            let ctx, o = Bvop.op_mul ctx { i0 = op; i1 = Int.of_string n } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> failwith "Not enough operands for MUL")
    | op -> failwith @@ "Invalid operation: " ^ String.concat ~sep:" " op
  in
  parse_op (Utils.list_words s) Context.empty []
