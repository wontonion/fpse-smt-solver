type response
type fetchOptions = {
  method?: string,
  headers?: Dict.t<string>,
  body?: string,
}

@val external fetch: (string, fetchOptions) => promise<response> = "fetch"
@send external json: response => promise<Js.Json.t> = "json"
@get external ok: response => bool = "ok"
