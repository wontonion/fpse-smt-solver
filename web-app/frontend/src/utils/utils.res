// type httpMethod =
//   | @as("GET") Get
//   | @as("POST") Post
//   | @as("PUT") Put
//   | @as("DELETE") Delete

// type fetchOption = {
//   method: httpMethod,
//   headers?: {.},
//   body?: string,
// }
// type response
// @val external fetch: (~url: string, ~opts: fetchOption) => promise<response> = "fetch"
// @send external json: response => promise<'a> = "json"

// let makeRequest = async url => {
//   let response = await fetch(url)
//   // let json = await response->json
//   let json = await response->json
//   Js.log(json)
// }
// let connectToBackend = () => {
//   // let _ = makeRequest("http://localhost:8080/backend/hello")
//   // ->Promise.then(response => {
//   //   Js.log(response)
//   //   Promise.resolve()
//   // })
//   // ->Promise.catch(error => {
//   //   Js.log2("Error:", error)
//   //   Promise.resolve()
//   // })
//   // ()
//   Js.log("triggered")
// }
