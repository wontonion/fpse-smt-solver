open Core

type t [@@deriving sexp]

type comparator_witness
(** A witness type for the comparator *)

val comparator : (t, comparator_witness) Comparator.t
(** A comparator for literals *)

val create : Literal.t list -> t
(** [create l] creates a clause from a list of literals *)

val string_of_t : t -> string
(** [string_of_t c] returns a string representation of clause [c] *)

val literals : t -> Literal.t list
(** [literals c] returns the list of literals of clause [c] *)

val variables : t -> Core.Set.M(Variable).t
(** [variables c] returns the set of variables in clause [c] *)

val equal : t -> t -> bool
(** [equal c1 c2] returns [true] if [c1] and [c2] are equal, [false] otherwise *)

val compare : t -> t -> int
(** [compare c1 c2] compares clauses [c1] and [c2] *)

val hash : t -> int
(** [hash c] returns the hash of clause [c] *)

val hash_fold_t : Hash.state -> t -> Hash.state
(** [hash_fold_t state v] folds the hash of variable [v] into the state [state] *)
