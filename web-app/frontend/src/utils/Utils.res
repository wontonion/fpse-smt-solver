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

let generateId = () => {
  Js.Date.now()->Js.Float.toString
}

type toastApi = {
  success: string => unit,
  error: string => unit,
  info: string => unit,
}

let useToast = () => {
  let context = React.useContext(ToastContext.context)
  let showToast = (message, toastType) => {
    context.dispatch(
      Types.AddToast({
        id: generateId(),
        message: message,
        toastType: toastType,
      }),
    )
  }

  ({
    success: message => showToast(message, #success),
    error: message => showToast(message, #error),
    info: message => showToast(message, #info),
  }: toastApi)
}

