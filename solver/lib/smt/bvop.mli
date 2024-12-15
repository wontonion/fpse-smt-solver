type input_1 = { i0 : Bitvec.t }
type input_int = { i0 : Bitvec.t; i1 : int }
type input_2 = { i0 : Bitvec.t; i1 : Bitvec.t }
type output_1 = { o0 : Bitvec.t }

val op_xor : Context.t -> input_2 -> Context.t * output_1
val op_and : Context.t -> input_2 -> Context.t * output_1
val op_or : Context.t -> input_2 -> Context.t * output_1
val op_not : Context.t -> input_1 -> Context.t * output_1
val constraint_eq : Context.t -> input_2 -> Context.t
val constraint_neq0 : Context.t -> input_1 -> Context.t
val op_add : Context.t -> input_2 -> Context.t * output_1
val op_sub : Context.t -> input_2 -> Context.t * output_1
val op_shl : Context.t -> input_int -> Context.t * output_1
val op_mul : Context.t -> input_int -> Context.t * output_1
