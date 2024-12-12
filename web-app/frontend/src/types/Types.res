// Types for general use
type httpMethod = [
  | #GET
  | #POST
  | #PUT
  | #DELETE
]

type problemType = [
  | #sudoku
  | #sat
  | #smt
]

type status = [
  | #success
  | #error
]

type responseApi = {
  method: httpMethod,
  problemType: problemType,
  status: status,  // only in response
  message: string, // console message
  data: Js.Json.t, // should cantain all kinds of response json data types 
}

type requestApi = {
  method: httpMethod,
  problemType: problemType,
  message: string,
  data: Js.Json.t,
}

// Types for sudoku 
// state of a cell in the sudoku grid
type cellState = {
  value: string,
  isInitial: bool,
  isValid: bool,
  // notes: array<string>,
}

type sudokuGridResponseData = {
  size: int,
  // TODO must be array?
  grid: array<array<cellState>>,
}

type sudokuResponseApi = {
  method: httpMethod,
  problemType: problemType,
  status: status,
  message: string,
  data: sudokuGridResponseData,
}

// Types for solver
type problemSetItem = {
  problem: string,
  solution: string,
}

type solverData = {
  problemMeta: string,
  // TODO must be array?
  problemSet: array<problemSetItem>,
}
