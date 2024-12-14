open Cdcl
open Cdcl.Variable
open Core

type t = {
  next_var : int;
  clauses : Cdcl.Clause.t list;
  bvs : Bitvec.t Map.M(Int).t;
}

let empty =
  {
    next_var = 3;
    clauses =
      [
        Clause.create [ Literal.create (Var 1) Positive ];
        Clause.create [ Literal.create (Var 2) Negative ];
      ];
    bvs = Map.empty (module Int);
  }

let bTrue = Var 1
let bFalse = Var 2
let bConst (b : bool) = if b then Var 1 else Var 2
let bVar (ctx : t) = ({ ctx with next_var = ctx.next_var + 1 }, Var ctx.next_var)

let bVars (ctx : t) (n : int) =
  ( { ctx with next_var = ctx.next_var + n },
    List.init n ~f:(fun i -> Var (ctx.next_var + i)) )

let bvNew (ctx : t) (id : int) : t * Bitvec.t =
  if Map.mem ctx.bvs id then (ctx, Map.find_exn ctx.bvs id)
  else
    let ctx, bv = bVars ctx 16 in
    ({ ctx with bvs = Map.set ctx.bvs ~key:id ~data:bv }, bv)

let add_clause (ctx : t) (c : Cdcl.Clause.t) =
  { ctx with clauses = c :: ctx.clauses }

let add_clauses (ctx : t) (cs : Cdcl.Clause.t list) =
  { ctx with clauses = cs @ ctx.clauses }

module RandomSolver = Solver.Make (Cdcl.Heuristic.Randomized)

let solve (ctx : t) : [ `SAT of Cdcl.Assignment.t | `UNSAT ] =
  RandomSolver.cdcl_solve (Formula.create ctx.clauses)
