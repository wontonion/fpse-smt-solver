type var = int
type t = { variable : var; negation : bool }

let create (v : var) (p : bool) : t = { variable = v; negation = p }

let string_of_t (l : t) : string =
  let negation = if l.negation then "-" else "" in
  negation ^ string_of_int l.variable

let neg (l : t) : t = { l with negation = not l.negation }

let equal (l1 : t) (l2 : t) : bool =
  l1.variable = l2.variable && l1.negation = l2.negation

let variable (l : t) : var = l.variable

let compare (l1 : t) (l2 : t) : int =
  let i1 =
    match l1.negation with true -> -l1.variable | false -> l1.variable
  in
  let i2 =
    match l2.negation with true -> -l2.variable | false -> l2.variable
  in
  Int.compare i1 i2
