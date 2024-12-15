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
      "Enter SMT formula",
      "VAR 1 MUL 3 CONST 4 ADD VAR 1 CONST 14 XOR EQ END\n\nThe SMT module supports a limited set of operations: \nXOR, AND, OR, NOT, EQ, NEQ0, GEQ0, LT0, ADD, SHL, and MUL. \n\nIt operates on int16_t, but the length can be easily \nadjusted to higher types (e.g., int32_t, int64_t)."
    )
  | _ => ("", "")
  }
  description ++ "\n\nExample:\n" ++ example
}

let handleDownloadTemplate = (tabName) => {
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
    ToastService.success("Template downloaded successfully, please check your download folder")
  } catch {
  | err => Js.Console.error2("Error downloading template:", err)
  ToastService.error("Error downloading template")
  }
}

module TabState = {
  type t = {
    content: string,
    solution: string,
  }
  
  let make = () => {
    content: "",
    solution: "Solution will appear here",
  }
}

@react.component
let make = (~tabName: string) => {
  let textareaRef: textareaRef = React.useRef(Js.Nullable.null)
  let (isLoading, setIsLoading) = React.useState(() => false)
  
  // Use Belt.Map.String instead of Map.String
  let (tabStates, setTabStates) = React.useState(() => 
    Belt.Map.String.fromArray([
      ("sat", TabState.make()),
      ("smt", TabState.make()),
    ])
  )
  
  
  let currentState = Belt.Map.String.get(tabStates, tabName->String.toLowerCase)
    ->Belt.Option.getWithDefault(TabState.make())
  
  React.useEffect1(() => {
    // Update textarea content when tab changes
    textareaRef.current
    ->Js.Nullable.toOption
    ->Belt.Option.forEach(textarea => {
      let textArea = textarea->domElementToTextArea
      textArea->setValue(currentState.content)
    })
    None
  }, [tabName])
  
  let updateTabState = (newState: TabState.t) => {
    setTabStates(prev => 
      Belt.Map.String.set(prev, tabName->String.toLowerCase, newState)
    )
  }

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
        updateTabState({...currentState, content: content})
        switch textareaRef.current->Js.Nullable.toOption {
        | Some(textarea) => {
            let textArea = textarea->domElementToTextArea
            textArea->setValue(content)
          }
        | None => ()
        }
      })
      
      readAsText(reader, file)
      ToastService.success("File uploaded successfully")
    }
  }

  let handleSolveProblems = _ => {
    switch textareaRef.current->Js.Nullable.toOption {
    | Some(textarea) => {
        let textArea = textarea->domElementToTextArea
        let content = textArea->getValue
        if content->String.length === 0 {
          ToastService.error("Nothing to solve")
        } else {
          setIsLoading(_ => true)
          updateTabState({...currentState, solution: "Solving..."})
          
          SolverUtils.postFormula(tabName->String.toLowerCase, content)
          ->Promise.then(result => {
            switch result {
            | Ok(solution) => {
                updateTabState({...currentState, solution: solution})
                ToastService.success("Solved successfully")
              }
            | Error(err) => {
                updateTabState({...currentState, solution: "Error: " ++ err})
                ToastService.error("Failed to solve")
              }
            }
            setIsLoading(_ => false)
            Promise.resolve()
          })
          ->Promise.catch(err => {
            // Handle unexpected errors (network errors, etc.)
            let errorMessage = switch err {
            | Js.Exn.Error(e) => 
                switch Js.Exn.message(e) {
                | Some(msg) => msg
                | None => "An unknown error occurred"
                }
            | _ => "An unknown error occurred"
            }
            
            updateTabState({...currentState, solution: "Error: " ++ errorMessage})
            setIsLoading(_ => false)
            ToastService.error("An error occurred while solving")
            Promise.resolve()
          })
          ->ignore
        }
      }
    | None => ()
    }
  }

  // handle clear textarea
  let handleClearTextarea = () => {
    if currentState.content->String.length === 0 {
      ToastService.error("Nothing to clear")
    } else {
      let newState = {...currentState, content: "", solution: "Solution will appear here"}
      updateTabState(newState)
      textareaRef.current
      ->Js.Nullable.toOption
      ->Belt.Option.forEach(textarea => {
      let textArea = textarea->domElementToTextArea
      textArea->setValue("")
    })
    ToastService.success("Cleared successfully")
    }
  }

  <div className="grid grid-cols-2 gap-6">
    <div className="flex flex-col">
      <h2 className="text-xl font-semibold mb-4">
        {React.string(tabName->String.toUpperCase ++ " Formula Input")}
      </h2>
      <textarea
        ref={ReactDOM.Ref.domRef(textareaRef)}
        className="w-full h-64 p-2 border rounded font-mono whitespace-pre"
        placeholder={getSolverExample(tabName)}
        value={currentState.content}
        onChange={e => {
          let newContent = ReactEvent.Form.target(e)["value"]
          updateTabState({...currentState, content: newContent})
        }}
      />
      <input
        type_="file"
        accept=".txt"
        className="hidden"
        id="fileInput"
        onChange={handleFileUpload}
      />
      <div className="mt-4 flex gap-4 justify-between">
        <Button onClick={_ => handleDownloadTemplate(tabName)}>
          {React.string("Download Template")}
        </Button>
        <Button onClick={_ => {
          getElementById("fileInput")->Js.Nullable.toOption->Belt.Option.forEach(click)
        }}>
          {React.string("Upload problem batch")}
        </Button>
        <Button onClick={_ => handleClearTextarea()}>
          {React.string("Clear")}
        </Button>
        <Button 
          disabled=isLoading
          onClick={handleSolveProblems}> 
          {React.string(isLoading ? "Solving..." : "Solve")} 
        </Button>
      </div>
    </div>
    <div>
      <h2 className="text-xl font-semibold mb-4"> {React.string("Solution")} </h2>
      <pre className="border p-4 h-64 overflow-auto font-mono whitespace-pre-wrap">
        {React.string(currentState.solution)}
      </pre>
    </div>
  </div>
}
