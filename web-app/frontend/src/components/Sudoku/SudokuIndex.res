@react.component
let make = () => {
  let (gridSize, setGridSize) = React.useState(() => 9)
  

  let createEmptyGrid = size => {
    Belt.Array.makeBy(size, _ => 
      Belt.Array.make(size, {Cell.value: "", isInitial: false, isValid: true})
    )
  }
  
  // Initialize grid with empty strings
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
              {...cell, value: value}
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

  <div className="grid grid-cols-2 gap-6">
    <div>
      <div className="text-xl font-semibold mb-4 justify-start flex items-center">
        <h2> {React.string("Sudoku Grid")} </h2>
        <div className="flex items-center gap-2 ml-2">
          <select
            className="border border-gray-300 rounded px-2 py-1"
            value={gridSize->Int.toString}
            onChange={event => {
              let newSize = ReactEvent.Form.target(event)["value"]->Int.fromString->Option.getOr(9)
              setGridSize(_ => newSize)
            }}>
            <option value="4"> {React.string("4x4")} </option>
            <option value="6"> {React.string("6x6")} </option>
            <option value="9"> {React.string("9x9")} </option>
          </select>
        </div>
      </div>
      <div className="border-2 border-gray-300 p-4 justify-center flex">
        <Grid size={gridSize} values={gridValues} onCellChange={handleCellChange} />
      </div>
    </div>
    <div>
      <h2 className="text-xl font-semibold mb-4"> {React.string("Controls")} </h2>
      <div className="space-y-4">
        <Button onClick={_ => ()}> {React.string("Solve Puzzle")} </Button>
        <Button onClick={_ => handleClearGrid()}> {React.string("Clear Grid")} </Button>
        <Button onClick={_ => ()}> {React.string("Generate New Puzzle")} </Button>
      </div>
    </div>
  </div>
}
