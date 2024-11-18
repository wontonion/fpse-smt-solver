type response
@val external fetch: string => promise<response> = "fetch"
@send external json: response => promise<'a> = "json"

let makeRequest = async url => {
  let response = await fetch(url)
  // let json = await response->json
  let msg = await response->msg
  Js.log(msg)
}
let connectToBackend = () => {
  // let _ = makeRequest("http://localhost:8080/backend/hello")
  // ->Promise.then(response => {
  //   Js.log(response)
  //   Promise.resolve()
  // })
  // ->Promise.catch(error => {
  //   Js.log2("Error:", error)
  //   Promise.resolve()
  // })
  // ()
  Js.log("triggered")
}
