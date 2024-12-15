open Core

type input_1 = { i0 : Bitvec.t }
type input_int = { i0 : Bitvec.t; i1 : int }
type input_2 = { i0 : Bitvec.t; i1 : Bitvec.t }
type output_1 = { o0 : Bitvec.t }

let op_xor (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o =
    List.fold_left (List.zip_exn input.i0 input.i1) ~init:(ctx, [])
      ~f:(fun (ctx, acc) (i0, i1) ->
        let ctx, o = Bitop.op_xor ctx { i0; i1 } in
        (ctx, o.o0 :: acc))
  in
  (ctx, { o0 = List.rev o })

let op_and (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o =
    List.fold_left (List.zip_exn input.i0 input.i1) ~init:(ctx, [])
      ~f:(fun (ctx, acc) (i0, i1) ->
        let ctx, o = Bitop.op_and ctx { i0; i1 } in
        (ctx, o.o0 :: acc))
  in
  (ctx, { o0 = List.rev o })

let op_or (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o =
    List.fold_left (List.zip_exn input.i0 input.i1) ~init:(ctx, [])
      ~f:(fun (ctx, acc) (i0, i1) ->
        let ctx, o = Bitop.op_or ctx { i0; i1 } in
        (ctx, o.o0 :: acc))
  in
  (ctx, { o0 = List.rev o })

let op_not (ctx : Context.t) (input : input_1) : Context.t * output_1 =
  let ctx, o =
    List.fold_left input.i0 ~init:(ctx, []) ~f:(fun (ctx, acc) i0 ->
        let ctx, o = Bitop.op_not ctx { i0 } in
        (ctx, o.o0 :: acc))
  in
  (ctx, { o0 = List.rev o })

let constraint_eq (ctx : Context.t) (input : input_2) : Context.t =
  List.fold_left (List.zip_exn input.i0 input.i1) ~init:ctx
    ~f:(fun ctx (i0, i1) -> Bitop.constraint_eq ctx { i0; i1 })

let constraint_neq0 (ctx : Context.t) (input : input_1) : Context.t =
  Context.add_clause ctx
    (Cdcl.Clause.create
    @@ List.map input.i0 ~f:(fun i0 -> Cdcl.Literal.create i0 Positive))

let constraint_geq0 (ctx : Context.t) (input : input_1) : Context.t =
  Context.add_clause ctx
    (Cdcl.Clause.create
       [ Cdcl.Literal.create (List.nth_exn input.i0 15) Negative ])

let constraint_lt0 (ctx : Context.t) (input : input_1) : Context.t =
  Context.add_clause ctx
    (Cdcl.Clause.create
       [ Cdcl.Literal.create (List.nth_exn input.i0 15) Positive ])

let op_add (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o, _ =
    List.fold_left (List.zip_exn input.i0 input.i1)
      ~init:(ctx, [], Context.bFalse) ~f:(fun (ctx, acc, cin) (i0, i1) ->
        let ctx, o = Bitop.op_add ctx { i0; i1; cin } in
        (ctx, o.s :: acc, o.cout))
  in
  (ctx, { o0 = List.rev o })

let op_sub (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o, _ =
    List.fold_left (List.zip_exn input.i0 input.i1)
      ~init:(ctx, [], Context.bFalse) ~f:(fun (ctx, acc, bin) (i0, i1) ->
        let ctx, o = Bitop.op_sub ctx { i0; i1; bin } in
        (ctx, o.d :: acc, o.bout))
  in
  (ctx, { o0 = List.rev o })

let op_shl (ctx : Context.t) (input : input_int) : Context.t * output_1 =
  let zeros = List.init input.i1 ~f:(fun _ -> Context.bFalse) in
  let ls, _ = List.split_n (zeros @ input.i0) 16 in
  (ctx, { o0 = ls })

let op_mul (ctx : Context.t) (input : input_int) : Context.t * output_1 =
  let rec aux (ctx : Context.t) (acc : Bitvec.t list) (n : int) (bit : int) :
      Context.t * Bitvec.t list =
    if n = 0 then (ctx, acc)
    else if n mod 2 = 0 then aux ctx acc (n / 2) (bit + 1)
    else
      let ctx, o = op_shl ctx { i0 = input.i0; i1 = bit } in
      aux ctx (o.o0 :: acc) (n / 2) (bit + 1)
  in
  let ctx, ls = aux ctx [] input.i1 0 in
  match ls with
  | [] ->
      failwith "Should not happen: Multiplied by constant zero" [@coverage off]
  | hd :: [] -> (ctx, { o0 = hd })
  | hd :: tl ->
      let ctx, bv =
        List.fold_left tl ~init:(ctx, hd) ~f:(fun (ctx, acc) i ->
            let ctx, o = op_add ctx { i0 = acc; i1 = i } in
            (ctx, o.o0))
      in
      (ctx, { o0 = bv })
