type response
type fetchOptions = {
  method?: string,
  headers?: Dict.t<string>,
  body?: string,
}

@val external fetch: (string, fetchOptions) => promise<response> = "fetch"
@send external json: response => promise<Js.Json.t> = "json"
@get external ok: response => bool = "ok"


let logRequest = (api: Types.requestApi) => {
  Js.Console.log2(api.message ++ "\n", Js.Json.stringify(api.data))
}

let logResponse = (api: Types.responseApi) => {
  let status = switch (api.status) {
  | #success => "success"
  | #error => "error"
  }

  Js.Console.log2(api.message ++ "\n" ++ status ++ "\n", Js.Json.stringify(api.data))
}

