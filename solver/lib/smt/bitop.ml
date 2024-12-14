open Cdcl

type input_1 = { i0 : Cdcl.Variable.t }
type input_2 = { i0 : Cdcl.Variable.t; i1 : Cdcl.Variable.t }
type output_1 = { o0 : Cdcl.Variable.t }

let op_xor (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o0 = Context.bVar ctx in
  let ctx =
    Context.add_clauses ctx
      [
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Negative;
            Literal.create o0 Negative;
          ];
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Positive;
            Literal.create o0 Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Negative;
            Literal.create o0 Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Positive;
            Literal.create o0 Negative;
          ];
      ]
  in
  (ctx, { o0 })

let op_and (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o0 = Context.bVar ctx in
  let ctx =
    Context.add_clauses ctx
      [
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Negative;
            Literal.create o0 Positive;
          ];
        Clause.create
          [ Literal.create input.i0 Positive; Literal.create o0 Negative ];
        Clause.create
          [ Literal.create input.i1 Positive; Literal.create o0 Negative ];
      ]
  in
  (ctx, { o0 })

let op_or (ctx : Context.t) (input : input_2) : Context.t * output_1 =
  let ctx, o0 = Context.bVar ctx in
  let ctx =
    Context.add_clauses ctx
      [
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Positive;
            Literal.create o0 Negative;
          ];
        Clause.create
          [ Literal.create input.i0 Negative; Literal.create o0 Positive ];
        Clause.create
          [ Literal.create input.i1 Negative; Literal.create o0 Positive ];
      ]
  in
  (ctx, { o0 })

let op_not (ctx : Context.t) (input : input_1) : Context.t * output_1 =
  let ctx, o0 = Context.bVar ctx in
  let ctx =
    Context.add_clauses ctx
      [
        Clause.create
          [ Literal.create input.i0 Negative; Literal.create o0 Negative ];
        Clause.create
          [ Literal.create input.i0 Positive; Literal.create o0 Positive ];
      ]
  in
  (ctx, { o0 })

let constraint_eq (ctx : Context.t) (input : input_2) : Context.t =
  Context.add_clauses ctx
    [
      Clause.create
        [ Literal.create input.i0 Negative; Literal.create input.i1 Positive ];
      Clause.create
        [ Literal.create input.i0 Positive; Literal.create input.i1 Negative ];
    ]

let constraint_neq (ctx : Context.t) (input : input_2) : Context.t =
  Context.add_clauses ctx
    [
      Clause.create
        [ Literal.create input.i0 Negative; Literal.create input.i1 Negative ];
      Clause.create
        [ Literal.create input.i0 Positive; Literal.create input.i1 Positive ];
    ]

type input_add = {
  i0 : Cdcl.Variable.t;
  i1 : Cdcl.Variable.t;
  cin : Cdcl.Variable.t;
}

type output_add = { s : Cdcl.Variable.t; cout : Cdcl.Variable.t }

let op_add (ctx : Context.t) (input : input_add) : Context.t * output_add =
  let ctx, s = Context.bVar ctx in
  let ctx, cout = Context.bVar ctx in
  let ctx =
    Context.add_clauses ctx
      [
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Negative;
            Literal.create input.cin Negative;
            Literal.create s Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Negative;
            Literal.create input.cin Positive;
            Literal.create s Negative;
          ];
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create input.i1 Positive;
            Literal.create input.cin Negative;
            Literal.create s Negative;
          ];
        Clause.create
          [
            Literal.create input.i0 Negative;
            Literal.create cout Positive;
            Literal.create s Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Negative;
            Literal.create input.cin Positive;
            Literal.create s Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Positive;
            Literal.create input.cin Negative;
            Literal.create s Positive;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create input.i1 Positive;
            Literal.create input.cin Positive;
            Literal.create s Negative;
          ];
        Clause.create
          [
            Literal.create input.i0 Positive;
            Literal.create cout Negative;
            Literal.create s Negative;
          ];
        Clause.create
          [
            Literal.create input.i1 Negative;
            Literal.create input.cin Negative;
            Literal.create cout Positive;
          ];
        Clause.create
          [
            Literal.create input.i1 Positive;
            Literal.create input.cin Positive;
            Literal.create cout Negative;
          ];
      ]
  in
  (ctx, { s; cout })
