type cellState = {
  value: string,
  isInitial: bool,
  isValid: bool,
  notes: array<string>,
}

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
  ~onCellChange: ((int, int, string)) => unit,
) => {
  let getCellClassName = () => {
    let baseStyle = "w-10 h-10 border border-gray-300 flex items-center justify-center relative"
    let borderStyle = switch (isRightBorder, isBottomBorder) {
    | (true, true) => " border-r-2 border-b-2 border-r-gray-800 border-b-gray-800"
    | (true, false) => " border-r-2 border-r-gray-800"
    | (false, true) => " border-b-2 border-b-gray-800"
    | (false, false) => ""
    }
    let validityStyle = switch (cell.isValid, cell.value !== "") {
    | (false, true) => " bg-red-100"
    | _ => ""
    }
    let initialStyle = cell.isInitial ? " bg-gray-500 text-white" : ""
    let completionStyle = switch (isRowComplete, isColComplete, hasRowError, hasColError) {
    | (_, _, true, true) => " bg-red-200"  // 冲突优先级最高
    | (_, _, true, false) | (_, _, false, true) => " bg-red-100"
    | (true, true, false, false) => " bg-green-200"  // 行列都完成
    | (true, false, false, false) | (false, true, false, false) => " bg-green-100"  // 行或列完成
    | _ => ""
    }

    baseStyle ++ borderStyle ++ validityStyle ++ initialStyle ++ completionStyle
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
        | _ => %re("/^[1-9]$/")
        }
        if (newValue === "" || Js.Re.test_(validNumberPattern, newValue)) {
          onCellChange((rowIndex, colIndex, newValue))
        }
      }}
    />
  </div>
}
