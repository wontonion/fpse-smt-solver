@react.component
let make = () => {
  let (blockSize, setBlockSize) = React.useState(() => 3)
  let (gridSize, setGridSize) = React.useState(() => blockSize * blockSize)
  let (gridValues, setGridValues) = React.useState(() => SudokuUtils.createEmptyGrid(gridSize))

  let hasNoNumber = Belt.Array.reduce(gridValues, true, (acc, row) => {
    acc &&
    Belt.Array.reduce(row, true, (acc, cell) => {
      acc && cell.value === ""
    })
  })

  let hasNoInitial = Belt.Array.reduce(gridValues, true, (acc, row) => {
    acc &&
    Belt.Array.reduce(row, true, (acc, cell) => {
      acc && !cell.isInitial
    })
  })

  let hasAnyValidationError = grid => {
    let size = Belt.Array.length(grid)
    let blockSize = switch size {
    | 9 => 3
    | 4 => 2
    | _ => 3
    }

    // Check all rows
    let hasRowError = Belt.Array.reduceWithIndex(grid, false, (acc, _, rowIndex) => {
      acc || Grid.hasRowConflict(rowIndex, grid)
    })

    // Check all columns
    let hasColError = Belt.Array.makeBy(size, i => i)->Belt.Array.reduce(false, (acc, colIndex) => {
      acc || Grid.hasColConflict(colIndex, grid)
    })

    // Check all blocks
    let numBlocks = blockSize * blockSize
    let hasBlockError = Belt.Array.makeBy(numBlocks, i => i)->Belt.Array.reduce(false, (
      acc,
      blockIndex,
    ) => {
      acc || Grid.hasBlockConflict(blockIndex, grid)
    })

    hasRowError || hasColError || hasBlockError
  }

  // Reset grid when size changes
  React.useEffect1(() => {
    setGridValues(_ => SudokuUtils.createEmptyGrid(gridSize))
    None
  }, [gridSize])

  // handle cell change
  let handleCellChange = ((row, col, value)) => {
    setGridValues(prev => {
      Belt.Array.mapWithIndex(prev, (i, rowArr) => {
        if i === row {
          Belt.Array.mapWithIndex(
            rowArr,
            (j, cell) => {
              if j === col {
                {...cell, value, isValid: true}
              } else {
                cell
              }
            },
          )
        } else {
          rowArr
        }
      })
    })
  }

  // handle clear grid
  let handleClearGrid = () => {
    if hasNoNumber {
      ToastService.error("Nothing to clear")
    } else {
      setGridValues(_ => SudokuUtils.createEmptyGrid(gridSize))
      ToastService.success("Grid cleared successfully")
    }
  }

  // handle generate sudoku
  let handleGenerateSudoku = () => {
    open Promise
    SudokuUtils.sudokuGenerate(~blockSize)
    ->then(json => {
      let newGrid = SudokuUtils.processGridResponse(json)
      setGridValues(_ => newGrid)
      ToastService.success("Grid generated successfully")
      Promise.resolve()
    })
    ->catch(error => {
      Js.Console.error2("Error generating grid:", error)
      ToastService.error("Error generating grid: " ++ error->Js.String.make)
      Promise.resolve()
    })
    ->ignore
  }

  // handle sudoku solving
  let handleSolveSudoku = () => {
    if hasNoNumber {
      ToastService.error("Cannot solve sudoku: There are no numbers in the grid")
    } else if hasNoInitial {
      ToastService.error("Cannot solve sudoku: There are no initial numbers in the grid")
    } else {
      // create a new grid, only keep the numbers with isInitial set to true, others set to empty
      // this is for solving sudoku since numbers from player will not necessarily be correct
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
      SudokuUtils.sudokuSolve(gridForSolving)
      ->then(json => {
        let solvedGrid = SudokuUtils.processGridResponse(json)
        setGridValues(_ => solvedGrid)
        Promise.resolve()
      })
      ->catch(error => {
        Js.Console.error2("Error solving grid:", error)
        ToastService.error("Error solving grid: " ++ error->Js.String.make)
        Promise.resolve()
      })
      ->ignore
    }
  }

  // handle set as initial
  let handleSetAsInitial = () => {
    if hasNoNumber {
      ToastService.error("Cannot set as initial: There are no numbers in the grid")
    } else if hasAnyValidationError(gridValues) {
      ToastService.error("Cannot set as initial: There are validation errors in the grid")
    } else {
      setGridValues(prev => {
        Belt.Array.map(prev, row => {
          Belt.Array.map(
            row,
            cell => {
              if cell.value !== "" {
                {...cell, isInitial: true}
              } else {
                cell
              }
            },
          )
        })
      })
    }
  }

  // handle reset initial
  let handleResetInitial = () => {
    if hasNoNumber {
      ToastService.error("Cannot reset initial: There are no numbers in the grid")
    } else {
      setGridValues(prev => {
        Belt.Array.map(prev, row => {
          Belt.Array.map(
            row,
            cell => {
              {...cell, isInitial: false}
            },
          )
        })
      })
      ToastService.success("Initial status reset successfully")
    }
  }

  <div className="h-screen flex flex-col overflow-hidden">
    <div className="flex-1 flex gap-6 p-4 max-w-7xl mx-auto w-full">
      <div className="w-1/2 flex flex-col">
        <div className="text-xl font-semibold mb-2">
          <div className="flex items-center justify-start gap-2">
            <h2> {React.string("Sudoku Grid")} </h2>
            <select
              className="border border-gray-300 rounded px-2 py-1"
              value={blockSize->Int.toString}
              onChange={event => {
                let newBlockSize =
                  ReactEvent.Form.target(event)["value"]->Int.fromString->Option.getOr(3)
                setBlockSize(_ => newBlockSize)
                setGridSize(_ => newBlockSize * newBlockSize)
                setGridValues(_ => SudokuUtils.createEmptyGrid(newBlockSize * newBlockSize))
              }}>
              <option value="2"> {React.string("4x4 (2x2 blocks)")} </option>
              <option value="3"> {React.string("9x9 (3x3 blocks)")} </option>
            </select>
          </div>
        </div>
        <div className="border-2 border-gray-300 p-2 w-full max-w-[600px] flex justify-center items-center">
          <div className="aspect-square">
            <Grid 
              size={gridSize} 
              values={gridValues} 
              onCellChange={handleCellChange} 
            />
          </div>
        </div>
      </div>
      <div className="w-1/2">
        <h2 className="text-xl font-semibold mb-2"> {React.string("Controls")} </h2>
        <div className="space-y-2 flex justify-start flex-col">
          <Button onClick={_ => handleGenerateSudoku()}>
            {React.string("Generate New Sudoku")}
          </Button>
          <Button onClick={_ => handleSolveSudoku()}> {React.string("Solve Sudoku")} </Button>
          <Button onClick={_ => handleClearGrid()}> {React.string("Clear Grid")} </Button>
          <div className="border-t pt-4 mt-4">
            <h3 className="text-lg font-bold mb-2"> {React.string("Custom Sudoku")} </h3>
            <div className="flex flex-col sm:flex-row gap-2">
              <Button
                onClick={_ => handleSetAsInitial()} className="bg-indigo-600 hover:bg-indigo-700">
                {React.string("Set Current Numbers as Initial")}
              </Button>
              <Button onClick={_ => handleResetInitial()} className="bg-gray-600 hover:bg-gray-700">
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
  </div>
}
