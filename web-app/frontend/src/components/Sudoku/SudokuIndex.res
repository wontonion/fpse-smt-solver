open SudokuUtils

@react.component
let make = () => {
  let (blockSize, setBlockSize) = React.useState(() => 3)
  let (gridSize, setGridSize) = React.useState(() => blockSize * blockSize)
  let (gridValues, setGridValues) = React.useState(() => createEmptyGrid(gridSize))

  // Reset grid when size changes
  React.useEffect1(() => {
    setGridValues(_ => createEmptyGrid(gridSize))
    None
  }, [gridSize])

  let handleCellChange = ((row, col, value)) => {
    setGridValues(prev => {
      Belt.Array.mapWithIndex(prev, (i, rowArr) => {
        if (i === row) {
          Belt.Array.mapWithIndex(rowArr, (j, cell) => {
            if (j === col) {
              {...cell, value: value, isValid: true}
            } else {
              cell
            }
          })
        } else {
          rowArr
        }
      })
    })
  }

  let handleClearGrid = () => {
    setGridValues(_ => createEmptyGrid(gridSize))
  }

  let handleGenerateGrid = () => {
    open Promise
    sudokuGenerate(~blockSize)
    ->then(json => {
      let newGrid = processGridResponse(json)
      setGridValues(_ => newGrid)
      Promise.resolve()
    })
    ->catch(error => {
      Js.Console.error2("Error generating grid:", error)
      Promise.resolve()
    })
    ->ignore
  }

  let handleSolveGrid = () => {
    // 创建一个新的grid，只保留isInitial为true的数字，其他设为空
    let gridForSolving = Belt.Array.map(gridValues, row => {
      Belt.Array.map(row, cell => {
        if cell.isInitial {
          cell
        } else {
          {...cell, value: ""}
        }
      })
    })

    open Promise
    sudokuSolve(gridForSolving)
    ->then(json => {
      let solvedGrid = processGridResponse(json)
      setGridValues(_ => solvedGrid)
      Promise.resolve()
    })
    ->catch(error => {
      Js.Console.error2("Error solving grid:", error)
      Promise.resolve()
    })
    ->ignore
  }

  let handleSetAsInitial = () => {
    setGridValues(prev => {
      Belt.Array.map(prev, row => {
        Belt.Array.map(row, cell => {
          if cell.value !== "" {
            {...cell, isInitial: true}
          } else {
            cell
          }
        })
      })
    })
  }

  let handleResetInitial = () => {
    setGridValues(prev => {
      Belt.Array.map(prev, row => {
        Belt.Array.map(row, cell => {
          {...cell, isInitial: false}
        })
      })
    })
  }

  <div className="grid grid-cols-2 gap-6">
    <div>
      <div className="text-xl font-semibold mb-4 justify-start flex items-center">
        <h2> {React.string("Sudoku Grid")} </h2>
        <div className="flex items-center gap-2 ml-2">
          <select
            className="border border-gray-300 rounded px-2 py-1"
            value={blockSize->Int.toString}
            onChange={event => {
              let newBlockSize = ReactEvent.Form.target(event)["value"]->Int.fromString->Option.getOr(3)
              setBlockSize(_ => newBlockSize)
              setGridSize(_ => newBlockSize * newBlockSize)
              setGridValues(_ => createEmptyGrid(newBlockSize * newBlockSize))
            }}>
            <option value="2"> {React.string("4x4 (2x2 blocks)")} </option>
            <option value="3"> {React.string("9x9 (3x3 blocks)")} </option>
          </select>
        </div>
      </div>
      <div className="border-2 border-gray-300 p-4 justify-center flex ">
        <Grid size={gridSize} values={gridValues} onCellChange={handleCellChange} />
      </div>
    </div>
    <div>
      <h2 className="text-xl font-semibold mb-4"> {React.string("Controls")} </h2>
      <div className="space-y-4 flex justify-start flex-col">
        <Button onClick={_ => handleSolveGrid()}>
          {React.string("Solve Puzzle")}
        </Button>
        
        <Button onClick={_ => handleGenerateGrid()}>
          {React.string("Generate New Puzzle")}
        </Button>
        
        <Button onClick={_ => handleClearGrid()}>
          {React.string("Clear Grid")}
        </Button>

        <div className="border-t pt-4 mt-4">
          <h3 className="text-lg font-medium mb-2"> 
            {React.string("Custom Puzzle")} 
          </h3>
          <div className="space-y-2">
            <Button 
              onClick={_ => handleSetAsInitial()}
              className="bg-indigo-600 hover:bg-indigo-700">
              {React.string("Set Current Numbers as Initial")}
            </Button>
            
            <Button 
              onClick={_ => handleResetInitial()}
              className="bg-gray-600 hover:bg-gray-700">
              {React.string("Reset Initial Status")}
            </Button>
          </div>
          <p className="text-sm text-gray-600 mt-2">
            {React.string("Input your puzzle and click 'Set as Initial' before solving")}
          </p>
        </div>
      </div>
    </div>
  </div>
}
