type t = { variable : int; negation : bool }

let create (v : int) (p : bool) : t = { variable = v; negation = p }

let string_of_t (l : t) : string =
  let negation = if l.negation then "¬" else "" in
  negation ^ string_of_int l.variable

let neg (l : t) : t = { l with negation = not l.negation }

let equal (l1 : t) (l2 : t) : bool = l1.variable = l2.variable && l1.negation = l2.negation

let variable (l : t) : int = l.variable