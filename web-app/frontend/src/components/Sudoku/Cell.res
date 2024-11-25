type cellState = {
  value: string,
  isInitial: bool,
  isValid: bool,
  notes: array<string>,
}

@react.component
let make = (
  ~cell: cellState,
  ~rowIndex: int,
  ~colIndex: int,
  ~isRightBorder: bool,
  ~isBottomBorder: bool,
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
    let initialStyle = cell.isInitial ? " bg-gray-100" : ""

    baseStyle ++ borderStyle ++ validityStyle ++ initialStyle
  }

  <div className={getCellClassName()}>
    <input
      type_="text"
      className="w-full h-full text-center focus:outline-none bg-transparent"
      maxLength=1
      value={cell.value}
      disabled={cell.isInitial}
      onChange={event => {
        let newValue = ReactEvent.Form.target(event)["value"]
        if (newValue === "" || Js.Re.test_(%re("/^[1-9]$/"), newValue)) {
          onCellChange((rowIndex, colIndex, newValue))
        }
      }}
    />
  </div>
}
