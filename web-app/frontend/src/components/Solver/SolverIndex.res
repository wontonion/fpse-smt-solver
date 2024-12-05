type element
@send external setAttribute: (element, string, string) => unit = "setAttribute"
@send external click: element => unit = "click"
@send external appendChild: (element, element) => unit = "appendChild"
@send external removeChild: (element, element) => unit = "removeChild"

module Blob = {
  type t
}

@val external document: {
  "createElement": string => element,
  "body": {
    "appendChild": element => unit,
    "removeChild": element => unit
  }
} = "document"

@val external window: {..} = "window"
@scope("URL") @val
external createObjectURL: Blob.t => string = "createObjectURL"
@scope("URL") @val
external revokeObjectURL: string => unit = "revokeObjectURL"
@new external createBlob: (array<string>, {"type": string}) => Blob.t = "Blob"
@scope("document") @val
external createElement: string => element = "createElement"
@scope("document") @val
external body: element = "body"

let getSolverExample = tabName => {
  let (description, example) = switch tabName {
  | "sat" => (
      "Enter CNF formula in DIMACS format",
      "p cnf 3 2\n1 2 -3 0\n-2 3 0"
    )
  | "smt" => (
      "Enter SMT-LIB2 formula",
      "(declare-const x Int)\n(assert (> x 0))\n(check-sat)\n(get-model)"
    )
  | _ => ("", "")
  }
  description ++ "\n\nExample:\n" ++ example
}

let downloadTemplate = (tabName) => {
  let content = getSolverExample(tabName) ++ "\n\n" ++ "Delete all template text before entering your formula"
  let element = createElement("a")
  let file = createBlob([content], {"type": "text/plain"})
  let url = createObjectURL(file)
  
  element->setAttribute("href", url)
  setAttribute(element, "download", tabName->String.toLowerCase ++ "_template.txt")
  appendChild(body, element)
  click(element)
  removeChild(body, element)
  revokeObjectURL(url)
}

@react.component
let make = (~tabName: string) => {
  <div className="grid grid-cols-2 gap-6">
    <div>
      <h2 className="text-xl font-semibold mb-4">
        {React.string(tabName->String.toUpperCase ++ " Formula Input")}
      </h2>
      <textarea
        className="w-full h-64 p-2 border rounded font-mono whitespace-pre"
        placeholder={getSolverExample(tabName)}
      />
      <div className="flex mt-4 gap-4">
        <Button onClick={_ => downloadTemplate(tabName)}>
          {React.string("Download Template")}
        </Button>
        <Button onClick={_ => ()}>
          {React.string("Upload problem batch")}
        </Button>
      </div>
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