open Core
open Smt

let parse (s : string) : (Context.t, string) Result.t =
  let rec parse_op (ops : string list) (ctx : Context.t) (stack : Bitvec.t list)
      : (Context.t, string) Result.t =
    match ops with
    | [] -> Ok ctx
    | "END" :: ops -> (
        match stack with
        | [] -> parse_op ops ctx []
        | _ -> Error "Invalid stack size")
    | "VAR" :: id :: ops -> (
        match Int.of_string_opt id with
        | None -> Error "Invalid variable id"
        | Some id ->
            let ctx, o = Context.bvNew ctx id in
            parse_op ops ctx (o :: stack))
    | "CONST" :: n :: ops -> (
        match Int.of_string_opt n with
        | None -> Error "Invalid constant"
        | Some n ->
            let bv = Bitvec.constant Context.bConst n in
            parse_op ops ctx (bv :: stack))
    | "XOR" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_xor ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for XOR")
    | "AND" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_and ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for AND")
    | "OR" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_or ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for OR")
    | "NOT" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx, o = Bvop.op_not ctx { i0 = op } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for NOT")
    | "EQ" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx = Bvop.constraint_eq ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx stack
        | _ -> Error "Not enough operands for EQ")
    | "NEQ0" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx = Bvop.constraint_neq0 ctx { i0 = op } in
            parse_op ops ctx stack
        | _ -> Error "Not enough operands for NEQ0")
    | "GEQ0" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx = Bvop.constraint_geq0 ctx { i0 = op } in
            parse_op ops ctx stack
        | _ -> Error "Not enough operands for GEQ0")
    | "LT0" :: ops -> (
        match stack with
        | op :: stack ->
            let ctx = Bvop.constraint_lt0 ctx { i0 = op } in
            parse_op ops ctx stack
        | _ -> Error "Not enough operands for LT0")
    | "ADD" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_add ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for ADD")
    | "SUB" :: ops -> (
        match stack with
        | op2 :: op1 :: stack ->
            let ctx, o = Bvop.op_sub ctx { i0 = op1; i1 = op2 } in
            parse_op ops ctx (o.o0 :: stack)
        | _ -> Error "Not enough operands for SUB")
    | "SHL" :: n :: ops -> (
        match Int.of_string_opt n with
        | None -> Error "Invalid shift amount"
        | Some n -> (
            match stack with
            | op :: stack ->
                let ctx, o = Bvop.op_shl ctx { i0 = op; i1 = n } in
                parse_op ops ctx (o.o0 :: stack)
            | _ -> Error "Not enough operands for SHL"))
    | "MUL" :: n :: ops -> (
        match Int.of_string_opt n with
        | None -> Error "Invalid constant"
        | Some n -> (
            match stack with
            | op :: stack ->
                let ctx, o = Bvop.op_mul ctx { i0 = op; i1 = n } in
                parse_op ops ctx (o.o0 :: stack)
            | _ -> Error "Not enough operands for MUL"))
    | op :: _ -> Error ("Invalid operation: " ^ op)
  in
  parse_op (Utils.list_words s) Context.empty []
