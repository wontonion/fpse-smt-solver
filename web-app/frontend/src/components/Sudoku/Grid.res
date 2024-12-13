open Types

// get the unique numbers of row or col
let getUniqueNumbers = (numbers: array<string>) => {
  numbers->Belt.Set.String.fromArray->Belt.Set.String.size
}

// check whether the numbers are unique
let isUniqueNumbers = (numbers: array<string>) => {
  numbers->Belt.Array.length == getUniqueNumbers(numbers)
}

// check whether all the numbers are filleds
let isAllFilled = (numbers: array<string>) => {
  Belt.Array.every(numbers, value => value !== "")
}

// 在现有的类型定义和函数之后，添加这个新的辅助函数
let getBlockIndex = (rowIndex, colIndex, subGridSize) => {
  let blockRow = rowIndex / subGridSize
  let blockCol = colIndex / subGridSize
  blockRow * subGridSize + blockCol
}

// check whether the row has conflict
let hasRowConflict = (rowIndex, grid) => {
  let row = Belt.Array.get(grid, rowIndex)->Option.getOr([])
  let numbers = row
    ->Belt.Array.keep(cell => cell.value !== "")
    ->Belt.Array.map(cell => cell.value)
  
  numbers->Belt.Array.length > getUniqueNumbers(numbers)
}

// check whether the col has conflict
let hasColConflict = (colIndex, grid) => {
  let numbers = Belt.Array.keepMap(grid, row => {
    Belt.Array.get(row, colIndex)
    ->Option.map(cell => cell.value)
    ->Option.filter(value => value !== "")
  })
  
  numbers->Belt.Array.length > getUniqueNumbers(numbers)
}

// check whether the block has conflict
let hasBlockConflict = (blockIndex, grid) => {
  let subGridSize = switch Belt.Array.length(grid) {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3
  }
  let blockRow = blockIndex / subGridSize
  let blockCol = mod(blockIndex, subGridSize)
  let startRow = blockRow * subGridSize
  let startCol = blockCol * subGridSize
  let numbers = []
  
  for rowOffset in 0 to subGridSize - 1 {
    for colOffset in 0 to subGridSize - 1 {
      let row = startRow + rowOffset
      let col = startCol + colOffset
      switch Belt.Array.get(grid, row)->Option.flatMap(row => Belt.Array.get(row, col)) {
      | Some(cell) if cell.value !== "" => Belt.Array.push(numbers, cell.value)
      | _ => ()
      }
    }
  }
  
  numbers->Belt.Array.length > getUniqueNumbers(numbers)
}

@react.component
let make = (
  ~size: int,
  ~values: array<array<Types.cellState>>,
  ~onCellChange: ((int, int, string)) => unit
) => {
  let subGridSize = switch size {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3 // default to 9x9
  }

  // check whether the row is complete
  let isRowComplete = (rowIndex, grid) => {
    let row = Belt.Array.get(grid, rowIndex)->Option.getOr([])
    let numbers = row->Belt.Array.map(cell => cell.value)
    
    isUniqueNumbers(numbers) && isAllFilled(numbers)
  }

  // check whether the col is complete
  let isColComplete = (colIndex, grid) => {
    let numbers = Belt.Array.keepMap(grid, row => {
      Belt.Array.get(row, colIndex)
      ->Option.map(cell => cell.value)
    })
    
    isUniqueNumbers(numbers) && isAllFilled(numbers)
  }

  // 修改现有的 isBlockComplete 函数
  let isBlockComplete = (blockIndex, grid) => {
    let blockRow = blockIndex / subGridSize
    let blockCol = mod(blockIndex, subGridSize)
    let startRow = blockRow * subGridSize
    let startCol = blockCol * subGridSize
    let numbers = []
    
    for rowOffset in 0 to subGridSize - 1 {
      for colOffset in 0 to subGridSize - 1 {
        let row = startRow + rowOffset
        let col = startCol + colOffset
        switch Belt.Array.get(grid, row)->Option.flatMap(row => Belt.Array.get(row, col)) {
        | Some(cell) => Belt.Array.push(numbers, cell.value)
        | None => ()
        }
      }
    }
    
    isUniqueNumbers(numbers) && isAllFilled(numbers)
  }

  // check whether the cell is valid
  let validateCell = (row, col, value, grid) => {
    let rowValid = !hasRowConflict(row, grid) && isRowComplete(row, grid)
    let colValid = !hasColConflict(col, grid) && isColComplete(col, grid)
    
    let blockIndex = getBlockIndex(row, col, subGridSize)
    let blockValid = !hasBlockConflict(blockIndex, grid) && isBlockComplete(blockIndex, grid)

    rowValid && colValid && blockValid
  }

  <div className="grid gap-0 border-2 border-black">
    {values
    ->Belt.Array.mapWithIndex((rowIndex, row) => {
      let hasRowError = hasRowConflict(rowIndex, values)
      let rowComplete = isRowComplete(rowIndex, values)
      
      <div 
        key={rowIndex->Int.toString} 
        className={`flex`}>
        {row
        ->Belt.Array.mapWithIndex((colIndex, cell) => {
          let isRightBorder = mod(colIndex + 1, subGridSize) == 0 && colIndex != size - 1
          let isBottomBorder = mod(rowIndex + 1, subGridSize) == 0 && rowIndex != size - 1
          let hasColError = hasColConflict(colIndex, values)
          let colComplete = isColComplete(colIndex, values)

          let blockIndex = getBlockIndex(rowIndex, colIndex, subGridSize)
          let blockConflict = hasBlockConflict(blockIndex, values)
          let blockComplete = isBlockComplete(blockIndex, values)

          let cellBackgroundClass = switch (hasRowError, hasColError, blockConflict, rowComplete, colComplete, blockComplete) {
          | (_, _, true, _, _, _) => "bg-red-200/50"
          | (true, _, _, _, _, _) | (_, true, _, _, _, _) => "bg-red-100/50"
          | (false, false, false, _, _, true) => "bg-green-100/50"
          | _ => ""
          }

          <Cell
            key={`${rowIndex->Int.toString}-${colIndex->Int.toString}`}
            cell={cell}
            size
            rowIndex
            colIndex
            isRightBorder
            isBottomBorder
            hasRowError
            hasColError
            isRowComplete=rowComplete
            isColComplete=colComplete
            hasBlockConflict=blockConflict
            isBlockComplete=blockComplete
            className=cellBackgroundClass
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
