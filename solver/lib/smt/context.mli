type t

val empty : t
(** [empty] creates a new empty context. *)

val bTrue : Cdcl.Variable.t
(** [bTrue] returns a constant boolean variable representing the constant [true]. *)

val bFalse : Cdcl.Variable.t
(** [bFalse] returns a constant boolean variable representing the constant [false]. *)

val bConst : bool -> Cdcl.Variable.t
(** [bConst b] returns a constant boolean variable representing the constant [b]. *)

val bVar : t -> t * Cdcl.Variable.t
(** [bVar ctx] returns a fresh boolean variable and the updated context. *)

val bVars : t -> int -> t * Cdcl.Variable.t list
(** [bVars ctx n] returns [n] fresh boolean variables and the updated context. *)

val bvNew : t -> int -> t * Bitvec.t
(** [bvNew ctx n] returns a fresh bitvector of size [n] and the updated context. *)

val add_clause : t -> Cdcl.Clause.t -> t
(** [add_clause ctx c] adds the clause [c] to the context [ctx]. *)

val add_clauses : t -> Cdcl.Clause.t list -> t
(** [add_clauses ctx cs] adds the clauses [cs] to the context [ctx]. *)

val solve : t -> [ `SAT of Cdcl.Assignment.t | `UNSAT ]
(** [solve ctx] solves the context [ctx]. *)

val to_string : t -> Cdcl.Assignment.t -> string
(** [to_string ctx a] outputs thee bitvector assignment [a] as a string. *)
