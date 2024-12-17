open Utils

let postFormula = async (type_, content) => {
  try {
    let response = await fetch("/api/solver/solve", {
      method: "POST",
      headers: Dict.fromArray([("Content-Type", "application/json")]),
      body: Js.Json.stringify(
        Js.Dict.fromArray([
          ("type", Js.Json.string(type_)),
          ("content", Js.Json.string(content)),
        ])->Js.Json.object_,
      ),
    })

    if !ok(response) {
      Error("Network response was not ok")
    } else {
      let json = await response->json
      let result = json->Js.Json.decodeObject->Belt.Option.getExn

      let solution = result
        ->Js.Dict.get("data")
        ->Belt.Option.getExn
        ->Js.Json.decodeString
        ->Belt.Option.getExn
        
      Ok(solution)
    }
  } catch {
  | err => Error("Failed to solve formula: " ++ err->Js.String2.make)
  }
}
