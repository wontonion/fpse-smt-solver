@react.component
let make = () => {
  let (activeTab, setActiveTab) = React.useState(() => "sudoku")
  let (backendMessage, setBackendMessage) = React.useState(() => "")

  let testBackendConnection = () => {
    open Promise
    Fetch.fetch("/api/backend/hello")
    ->then(response => {
      Fetch.Response.text(response)
      })
    ->then(message => {
  setBackendMessage(_ =>                      message)
      resolve()
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
            {React.string(backendMessage)}
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
