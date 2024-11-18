@react.component
let make = (~size: int) => {
  // Calculate sub-grid size (e.g., 3 for 9x9, 2 for 4x4)
  let subGridSize = switch size {
  | 9 => 3
  | 6 => 2
  | 4 => 2
  | _ => 3 // default to 3x3 sub-grids
  }

  let cellStyle = "w-10 h-10 border border-gray-300 flex items-center justify-center"
  let thickBorderStyle = "border-2 border-gray-800"

  <div className="grid gap-0">
    {Array.make(~length=size, 0)
    ->Array.mapWithIndex((rowIndex, _) => {
      <div key={rowIndex->Int.toString} className="flex">
        {Array.make(~length=size, 0)
        ->Array.mapWithIndex((colIndex, _) => {
          let isRightBorder = mod(colIndex + 1, subGridSize) == 0 && colIndex != size - 1
          let isBottomBorder = mod(rowIndex + 1, subGridSize) == 0 && rowIndex != size - 1

          let borderStyles = switch (isRightBorder, isBottomBorder) {
          | (true, true) =>
            cellStyle ++ " border-r-" ++ thickBorderStyle ++ " border-b-" ++ thickBorderStyle
          | (true, false) => cellStyle ++ " border-r-" ++ thickBorderStyle
          | (false, true) => cellStyle ++ " border-b-" ++ thickBorderStyle
          | (false, false) => cellStyle
          }

          <div key={`${rowIndex->Int.toString}-${colIndex->Int.toString}`} className=borderStyles>
            <input
              type_="text"
              className="w-full h-full text-center focus:outline-none"
              maxLength=1
              pattern="[1-9]*"
              onInput={_ => ()} // TODO: Add input handling
            />
          </div>
        })
        ->React.array}
      </div>
    })
    ->React.array}
  </div>
}
