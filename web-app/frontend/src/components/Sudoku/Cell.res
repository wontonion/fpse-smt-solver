open Types

@react.component
let make = (
  ~cell: cellState,
  ~size: int,
  ~rowIndex: int,
  ~colIndex: int,
  ~isRightBorder: bool,
  ~isBottomBorder: bool,
  ~hasRowError: bool,
  ~hasColError: bool,
  ~isRowComplete: bool,
  ~isColComplete: bool,
  ~hasBlockConflict: bool,
  ~isBlockComplete: bool,
  ~onCellChange: ((int, int, string)) => unit,
) => {
  let getCellClassName = () => {
    let baseStyle = "w-10 h-10 border border-gray-300 flex items-center justify-center relative"

    // make block border thicker
    let borderStyle = switch (isRightBorder, isBottomBorder) {
    | (true, true) => " border-r-2 border-b-2 border-r-gray-800 border-b-gray-800"
    | (true, false) => " border-r-2 border-r-gray-800"
    | (false, true) => " border-b-2 border-b-gray-800"
    | (false, false) => ""
    }

    if (cell.isInitial) {
      baseStyle ++ borderStyle ++ " bg-gray-500 text-white"
    } else {
      let validityStyle = switch (cell.isValid, cell.value !== "", hasBlockConflict) {
      | (false, true, true) => " bg-red-200"
      | (false, true, false) => " bg-red-100"
      | _ => ""
      }
      let completionStyle = switch (isRowComplete, isColComplete, isBlockComplete, hasRowError, hasColError, hasBlockConflict) {
      | (_, _, _, true, _, _) | (_, _, _, _, true, _) | (_, _, _, _, _, true) => " bg-red-100 opacity-50"
      | (true, true, true, false, false, false) => " bg-green-200 opacity-50"
      | (true, _, _, false, false, false) | (_, true, _, false, false, false) | (_, _, true, false, false, false) => " bg-green-100 opacity-50"
      | _ => ""
      }

      baseStyle ++ borderStyle ++ validityStyle ++ completionStyle
    }
  }

  <div className={getCellClassName()}>
    <input
      type_="text"
      className={`w-full h-full text-center focus:outline-none bg-transparent
        ${(hasRowError || hasColError) ? "text-red-600 font-bold" :
          (isRowComplete || isColComplete) ? "text-green-600 font-bold" : ""}`}
      maxLength=1
      value={cell.value}
      disabled={cell.isInitial}
      onChange={event => {
        let newValue = ReactEvent.Form.target(event)["value"]
        let validNumberPattern = switch size {
        | 4 => %re("/^[1-4]$/")
        | 6 => %re("/^[1-6]$/")
        | 9 => %re("/^[1-9]$/")
        | _ => %re("/^$/")}
        
        if (newValue === "" || Js.Re.test_(validNumberPattern, newValue)) {
          onCellChange((rowIndex, colIndex, newValue))
        }
      }}
    />
  </div>
}
