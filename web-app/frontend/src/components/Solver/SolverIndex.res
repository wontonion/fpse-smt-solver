@react.component

let satExample = "p cnf 3 2 \n 1 2 -3 0 \n -2 3 0"
let smtExample = ""

let make = (~tabName: string) => {
  let displayExample = if tabName == "SAT" {
    satExample
  }else{
    smtExample
  }
 <div className="grid grid-cols-2 gap-6">
          <div>
            <h2 className="text-xl font-semibold mb-4">
              {React.string(`${tabName->String.toUpperCase} Formula Input`)}
            </h2>
            <textarea
              className="w-full h-64 p-2 border rounded"
              placeholder={`Enter ${tabName->String.toUpperCase} formula... \n ${displayExample}` }
            />
            // <div className="flex mt-4">
              <Button onClick={_ => ()}> {React.string("Download Template")} </Button>
              <Button onClick={_ => ()}> {React.string("Upload problme batch")} </Button>
            // </div>
          </div>
          <div>
            <h2 className="text-xl font-semibold mb-4"> {React.string("Solution")} </h2>
            <div className="border p-4 h-64 overflow-auto">
              {React.string("Solution will appear here")}
            </div>
            <Button className="mt-6" onClick={_ => ()}> {React.string("Solve")} </Button>
          </div>
        </div> 
        
}
