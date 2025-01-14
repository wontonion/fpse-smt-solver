type input_1 = { i0 : Cdcl.Variable.t }
type input_2 = { i0 : Cdcl.Variable.t; i1 : Cdcl.Variable.t }
type output_1 = { o0 : Cdcl.Variable.t }

val op_xor : Context.t -> input_2 -> Context.t * output_1
val op_and : Context.t -> input_2 -> Context.t * output_1
val op_or : Context.t -> input_2 -> Context.t * output_1
val op_not : Context.t -> input_1 -> Context.t * output_1
val constraint_eq : Context.t -> input_2 -> Context.t
val constraint_neq : Context.t -> input_2 -> Context.t

type input_add = {
  i0 : Cdcl.Variable.t;
  i1 : Cdcl.Variable.t;
  cin : Cdcl.Variable.t;
}

type output_add = { s : Cdcl.Variable.t; cout : Cdcl.Variable.t }

val op_add : Context.t -> input_add -> Context.t * output_add

type input_sub = {
  i0 : Cdcl.Variable.t;
  i1 : Cdcl.Variable.t;
  bin : Cdcl.Variable.t;
}

type output_sub = { d : Cdcl.Variable.t; bout : Cdcl.Variable.t }

val op_sub : Context.t -> input_sub -> Context.t * output_sub
