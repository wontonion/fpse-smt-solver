@react.component
let make = (~size: int, ~values: array<array<Cell.cellState>>, ~onCellChange: ((int, int, string)) => unit) => {
  // Calculate sub-grid size (e.g., 3 for 9x9, 2 for 4x4)
  let subGridSize = switch size {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3 // default to 3x3 sub-grids
  }

  <div className="grid gap-0">
    {Array.make(~length=size, 0)
    ->Array.mapWithIndex((rowIndex, _) => {
      <div key={rowIndex->Int.toString} className="flex">
        {Array.make(~length=size, 0)
        ->Array.mapWithIndex((colIndex, _) => {
          let isRightBorder = mod(colIndex + 1, subGridSize) == 0 && colIndex != size - 1
          let isBottomBorder = mod(rowIndex + 1, subGridSize) == 0 && rowIndex != size - 1
          
          let cell = Belt.Array.get(values, rowIndex)
            ->Option.flatMap(row => Belt.Array.get(row, colIndex))
            ->Option.getOr({value: "", isInitial: false, isValid: true})

          <Cell
            key={`${rowIndex->Int.toString}-${colIndex->Int.toString}`}
            cell
            rowIndex
            colIndex
            isRightBorder
            isBottomBorder
            onCellChange
          />
        })
        ->React.array}
      </div>
    })
    ->React.array}
  </div>
}
