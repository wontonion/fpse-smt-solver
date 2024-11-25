open Cell

@react.component
let make = (~size: int, ~values: array<array<cellState>>, ~onCellChange: ((int, int, string)) => unit) => {
  let subGridSize = switch size {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3
  }

  // 检查某行是否已完成（所有数字都填入且无重复）
  let isRowComplete = (rowIndex, grid) => {
    let row = Belt.Array.get(grid, rowIndex)->Option.getOr([])
    let numbers = row->Belt.Array.map(cell => cell.value)
    
    let allFilled = Belt.Array.every(numbers, value => value !== "")
    let uniqueNumbers = numbers->Belt.Set.String.fromArray->Belt.Set.String.size
    
    allFilled && uniqueNumbers === size
  }

  // 检查某列是否已完成
  let isColComplete = (colIndex, grid) => {
    let numbers = Belt.Array.keepMap(grid, row => {
      Belt.Array.get(row, colIndex)
      ->Option.map(cell => cell.value)
    })
    
    let allFilled = Belt.Array.every(numbers, value => value !== "")
    let uniqueNumbers = numbers->Belt.Set.String.fromArray->Belt.Set.String.size
    
    allFilled && uniqueNumbers === size
  }

  // 检查某行是否有重复数字
  let hasRowConflict = (rowIndex, grid) => {
    let row = Belt.Array.get(grid, rowIndex)->Option.getOr([])
    let numbers = row
      ->Belt.Array.keep(cell => cell.value !== "")
      ->Belt.Array.map(cell => cell.value)
    
    let uniqueNumbers = numbers->Belt.Set.String.fromArray->Belt.Set.String.size
    numbers->Belt.Array.length > uniqueNumbers
  }

  // 检查某列是否有重复数字
  let hasColConflict = (colIndex, grid) => {
    let numbers = Belt.Array.keepMap(grid, row => {
      Belt.Array.get(row, colIndex)
      ->Option.map(cell => cell.value)
      ->Option.filter(value => value !== "")
    })
    
    let uniqueNumbers = numbers->Belt.Set.String.fromArray->Belt.Set.String.size
    numbers->Belt.Array.length > uniqueNumbers
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
      let hasRowError = hasRowConflict(rowIndex, values)
      let rowComplete = isRowComplete(rowIndex, values)
      
      <div 
        key={rowIndex->Int.toString} 
        className={`flex ${switch (hasRowError, rowComplete) {
        | (true, _) => "bg-red-100"
        | (false, true) => "bg-green-100"
        | _ => ""
        }}`}>
        {row
        ->Belt.Array.mapWithIndex((colIndex, cell) => {
          let isRightBorder = mod(colIndex + 1, subGridSize) == 0 && colIndex != size - 1
          let isBottomBorder = mod(rowIndex + 1, subGridSize) == 0 && rowIndex != size - 1
          let hasColError = hasColConflict(colIndex, values)
          let colComplete = isColComplete(colIndex, values)

          <Cell
            key={`${rowIndex->Int.toString}-${colIndex->Int.toString}`}
            cell
            size
            rowIndex
            colIndex
            isRightBorder
            isBottomBorder
            hasRowError
            hasColError
            isRowComplete=rowComplete
            isColComplete=colComplete
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
