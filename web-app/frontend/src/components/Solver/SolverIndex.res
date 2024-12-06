type element
@send external setAttribute: (element, string, string) => unit = "setAttribute"
@send external click: element => unit = "click"
@send external appendChild: (element, element) => unit = "appendChild"
@send external removeChild: (element, element) => unit = "removeChild"

type fileReader
type progressEvent = {
  "target": {
    "result": string
  }
}

@new external createFileReader: unit => fileReader = "FileReader"
@set external setOnLoad: (fileReader, progressEvent => unit) => unit = "onload"
@set external setOnError: (fileReader, exn => unit) => unit = "onerror"
@send external readAsText: (fileReader, Js.File.t) => unit = "readAsText"

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

@val @scope("document")
external getElementById: string => Js.Nullable.t<element> = "getElementById"

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

type files = {
  "length": int,
  "item": int => Js.File.t
}

type fileInput = {
  "files": files
}

type htmlTextAreaElement
@get external getValue: htmlTextAreaElement => string = "value"
@set external setValue: (htmlTextAreaElement, string) => unit = "value"

external domElementToTextArea: Dom.element => htmlTextAreaElement = "%identity"
external textAreaToDomElement: htmlTextAreaElement => Dom.element = "%identity"

type textareaRef = React.ref<Js.Nullable.t<Dom.element>>

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
  try {
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
  } catch {
  | err => Js.Console.error2("Error downloading template:", err)
  }
}

let clearTextarea = (textareaRef: textareaRef) => {
  textareaRef.current
  ->Js.Nullable.toOption
  ->Belt.Option.forEach(textarea => {
    let textArea = textarea->domElementToTextArea
    textArea->setValue("")
  })
}

@react.component
let make = (~tabName: string) => {
  let textareaRef: textareaRef = React.useRef(Js.Nullable.null)
  
  let handleFileUpload = e => {
    let fileInput = (e->ReactEvent.Form.target :> fileInput)
    let files = fileInput["files"]
    
    if files["length"] > 0 {
      let file = files["item"](0)
      let reader = createFileReader()
      
      setOnError(reader, _err => {
        Js.Console.error("Error reading file")
      })
      
      setOnLoad(reader, event => {
        let content = event["target"]["result"]
        switch textareaRef.current->Js.Nullable.toOption {
        | Some(textarea) => {
            let textArea = textarea->domElementToTextArea
            textArea->setValue(content)
          }
        | None => ()
        }
      })
      
      readAsText(reader, file)
    }
  }

  <div className="grid grid-cols-2 gap-6">
    <div>
      <h2 className="text-xl font-semibold mb-4">
        {React.string(tabName->String.toUpperCase ++ " Formula Input")}
      </h2>
      <textarea
        ref={ReactDOM.Ref.domRef(textareaRef)}
        className="w-full h-64 p-2 border rounded font-mono whitespace-pre"
        placeholder={getSolverExample(tabName)}
      />
      <input
        type_="file"
        accept=".txt"
        className="hidden"
        id="fileInput"
        onChange={handleFileUpload}
      />
      <div className="flex mt-4 gap-4">
        <Button onClick={_ => downloadTemplate(tabName)}>
          {React.string("Download Template")}
        </Button>
        <Button onClick={_ => getElementById("fileInput")->Js.Nullable.toOption->Belt.Option.forEach(click)}>
          {React.string("Upload problem batch")}
        </Button>
        <Button onClick={_ => clearTextarea(textareaRef)}>
          {React.string("Clear")}
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