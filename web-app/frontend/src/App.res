open Utils

// 首先定义类型来匹配后端的响应结构
type solution = {
  problem_type: string,
  assignments: option<array<(string, string)>>,
  time_taken: float
}

type _response = {
  status: string,
  message: string,
  data: option<solution>
}
@react.component
let make = () => {
  let (activeTab, setActiveTab) = React.useState(() => "sudoku")
  let (backendMessage, setBackendMessage) = React.useState(() => "")

  let testBackendConnection = () => {
    open Promise
    Utils.fetch("/api/hello", {method: "GET"})
    ->then(response => {
      if Utils.ok(response) {
        Utils.json(response)
      } else {
        Promise.reject(Js.Exn.raiseError("Network response was not ok"))
      }
    })
    ->then(json => {
      // Deserialize JSON 
      let response = json->Js.Json.decodeObject->Belt.Option.getExn
      let status = response->Js.Dict.get("status")->Belt.Option.getExn->Js.Json.decodeString->Belt.Option.getExn
      let message = response->Js.Dict.get("message")->Belt.Option.getExn->Js.Json.decodeString->Belt.Option.getExn
      
      // print to console
      Js.Console.log2("Response status:", status)
      Js.Console.log2("Response message:", message)
      Js.Console.log2("Full response:", json)
      
      setBackendMessage(_ => message)
      Promise.resolve()
    })
    ->catch(error => {
      Js.Console.error2("Error:", error)
      Promise.resolve()
    })
    ->ignore
  }

  <div className="p-6">
    <h1 className="text-3xl font-semibold mb-6"> {"Logic Solver Playground🛝"->React.string} </h1>
    // Test connection button
    <div className="mb-4">
      <button
        onClick={_ => testBackendConnection()}
        className="bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded">
        {React.string("Test Backend Connection")}
      </button>
      {backendMessage !== "" 
        ? <div className="mt-2 p-2 bg-gray-100 rounded">
            <pre className="whitespace-pre-wrap"> {React.string(backendMessage)} </pre>
          </div>
        : React.null}
    </div>
    // Tab navigation
    <div className="flex space-x-4 mb-6 border-b">
      <button
        onClick={_ => setActiveTab(_ => "sudoku")}
        className={`py-2 px-4 ${activeTab === "sudoku"
            ? "border-b-2 border-blue-500 font-semibold"
            : ""}`}>
        {React.string("Sudoku Solver")}
      </button>
      <button
        onClick={_ => setActiveTab(_ => "sat")}
        className={`py-2 px-4 ${activeTab === "sat"
            ? "border-b-2 border-blue-500 font-semibold"
            : ""}`}>
        {React.string("SAT Solver")}
      </button>
      <button
        onClick={_ => setActiveTab(_ => "smt")}
        className={`py-2 px-4 ${activeTab === "smt"
            ? "border-b-2 border-blue-500 font-semibold"
            : ""}`}>
        {React.string("SMT Solver")}
      </button>
    </div>
    // Content area
    <div className="mt-4">
      {switch activeTab {
      | "sudoku" => <SudokuIndex.make />
      | "sat" => <SolverIndex.make tabName="sat" />
      | "smt" => <SolverIndex.make tabName="smt" />
      | _ => React.null
      }}
    </div>
  </div>
}
