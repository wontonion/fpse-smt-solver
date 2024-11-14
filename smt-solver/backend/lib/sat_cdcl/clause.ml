type t

let create : Literal.t list -> t = failwith "Not implemented"

let literals : t -> Literal.t list = failwith "Not implemented"

let bcp : t -> Assignment.t -> Assignment.t option = failwith "Not implemented"

let is_satisfied : t -> Assignment.t -> bool = failwith "Not implemented"

let next_free_literal : t -> Assignment.t -> Literal.t option = failwith "Not implemented"