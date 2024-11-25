open Cell

@react.component
let make = (~size: int, ~values: array<array<cellState>>, ~onCellChange: ((int, int, string)) => unit) => {
  let subGridSize = switch size {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3
  }

  let validateCell = (row, col, value, grid) => {
    let rowValid = Belt.Array.get(grid, row)
    ->Option.map(rowArr => 
      Belt.Array.every(rowArr, cell => 
        cell.value !== value || cell.value === ""
      )
    )
    ->Option.getOr(true)
    
    let colValid = Belt.Array.every(grid, row => {
      Belt.Array.get(row, col)
      ->Option.map(cell => cell.value)
      ->Option.getOr("")
      ->value => value !== value || value === ""
    })

    rowValid && colValid
  }

  <div className="grid gap-0">
    {values
    ->Belt.Array.mapWithIndex((rowIndex, row) => {
      <div key={rowIndex->Int.toString} className="flex">
        {row
        ->Belt.Array.mapWithIndex((colIndex, cell) => {
          let isRightBorder = mod(colIndex + 1, subGridSize) == 0 && colIndex != size - 1
          let isBottomBorder = mod(rowIndex + 1, subGridSize) == 0 && rowIndex != size - 1

          <Cell
            key={`${rowIndex->Int.toString}-${colIndex->Int.toString}`}
            cell
            rowIndex
            colIndex
            isRightBorder
            isBottomBorder
            onCellChange={((row, col, value)) => {
              let isValid = validateCell(row, col, value, values)
              onCellChange((row, col, value))
            }}
          />
        })
        ->React.array}
      </div>
    })
    ->React.array}
  </div>
}
