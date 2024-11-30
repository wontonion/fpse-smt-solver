type response
type fetchOptions = {
  method?: string,
  headers?: Dict.t<string>,
  body?: string,
}

@val external fetch: (string, fetchOptions) => promise<response> = "fetch"
@send external json: response => promise<Js.Json.t> = "json"
@get external ok: response => bool = "ok"

// 用于处理 Sudoku API 的函数
let fetchSudokuGrid = () => {
  fetch("/api/sudoku/generate", {method: "GET"})
  ->Promise.then(response => {
    if ok(response) {
      response->json
    } else {
      Promise.reject(Js.Exn.raiseError("Network response was not ok"))
    }
  })
}
