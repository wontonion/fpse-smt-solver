type response
type fetchOptions = {
  method?: string,
  headers?: Dict.t<string>,
  body?: string,
}

@val external fetch: (string, fetchOptions) => promise<response> = "fetch"
@send external json: response => promise<Js.Json.t> = "json"
@get external ok: response => bool = "ok"

// create an empty grid
let createEmptyGrid = size => {
  Belt.Array.makeBy(size, _ => 
    Belt.Array.make(size, {
      value: "",
      isInitial: false,
      isValid: true
    }: Types.cellState)
  )
}

// process the grid response from the backend
let processGridResponse = (json: Js.Json.t): array<array<Types.cellState>> => {
  let response = json->Js.Json.decodeObject->Belt.Option.getExn
  let data = response->Js.Dict.get("data")->Belt.Option.getExn
  let grid = data->Js.Json.decodeObject->Belt.Option.getExn
    ->Js.Dict.get("grid")->Belt.Option.getExn
    ->Js.Json.decodeArray->Belt.Option.getExn

  grid->Belt.Array.map(row => {
    row->Js.Json.decodeArray->Belt.Option.getExn
    ->Belt.Array.map(cell => {
      let cellObj = cell->Js.Json.decodeObject->Belt.Option.getExn
      {
        Types.value: cellObj
          ->Js.Dict.get("value")
          ->Belt.Option.getExn
          ->Js.Json.decodeString
          ->Belt.Option.getWithDefault(""),
        Types.isInitial: cellObj
          ->Js.Dict.get("is_initial")
          ->Belt.Option.getExn
          ->Js.Json.decodeBoolean
          ->Belt.Option.getWithDefault(false),
        Types.isValid: cellObj
          ->Js.Dict.get("is_valid")
          ->Belt.Option.getExn
          ->Js.Json.decodeBoolean
          ->Belt.Option.getWithDefault(true),
      }
    })
  })
}

// generate a sudoku grid
let sudokuGenerate = () => {
  fetch("/api/sudoku/generate", {method: "GET"})
  ->Promise.then(response => {
    if ok(response) {
      response->json
    } else {
      Promise.reject(Js.Exn.raiseError("Network response was not ok"))
    }
  })
}

let sudokuSolve = (gridValues: array<array<Types.cellState>>) => {
  let requestBody = {
    Types.size: Belt.Array.length(gridValues),
    Types.grid: gridValues,
  }

  let jsonRequestBody = Js.Json.object_(
    Js.Dict.fromArray([
      ("size", Js.Json.number(float_of_int(requestBody.size))),
      ("grid", Js.Json.array(
        requestBody.grid->Belt.Array.map(row =>
          Js.Json.array(
            row->Belt.Array.map(cell =>
              Js.Json.object_(
                Js.Dict.fromArray([
                  ("value", Js.Json.string(cell.value)),
                  ("isInitial", Js.Json.boolean(cell.isInitial)),
                  ("isValid", Js.Json.boolean(cell.isValid)),
                ])
              )
            )
          )
        )
      ))
    ])
  )

  fetch("/api/sudoku/solve", {
    method: "POST",
    headers: Dict.fromArray([("Content-Type", "application/json")]),
    body: Js.Json.stringify(jsonRequestBody),
  })
  ->Promise.then(response => {
    if ok(response) {
      response->json
    } else {
      Promise.reject(Js.Exn.raiseError("Network response was not ok"))
    }
  })
}


