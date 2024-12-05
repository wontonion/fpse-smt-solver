// Generated by ReScript, PLEASE EDIT WITH CARE

import * as JsxRuntime from "react/jsx-runtime";

function Cell(props) {
  var onCellChange = props.onCellChange;
  var isBlockComplete = props.isBlockComplete;
  var hasBlockConflict = props.hasBlockConflict;
  var isColComplete = props.isColComplete;
  var isRowComplete = props.isRowComplete;
  var hasColError = props.hasColError;
  var hasRowError = props.hasRowError;
  var isBottomBorder = props.isBottomBorder;
  var isRightBorder = props.isRightBorder;
  var colIndex = props.colIndex;
  var rowIndex = props.rowIndex;
  var size = props.size;
  var cell = props.cell;
  var getCellClassName = function () {
    var borderStyle = isRightBorder ? (
        isBottomBorder ? " border-r-2 border-b-2 border-r-gray-800 border-b-gray-800" : " border-r-2 border-r-gray-800"
      ) : (
        isBottomBorder ? " border-b-2 border-b-gray-800" : ""
      );
    var match = cell.isValid;
    var match$1 = cell.value !== "";
    var validityStyle = match || !match$1 ? "" : (
        hasBlockConflict ? " bg-red-200" : " bg-red-100"
      );
    var initialStyle = cell.isInitial ? " bg-gray-500 text-white" : "";
    var completionStyle;
    var exit = 0;
    var exit$1 = 0;
    if (isRowComplete) {
      var exit$2 = 0;
      if (isColComplete && isBlockComplete) {
        if (hasRowError) {
          exit$1 = 2;
        } else if (hasColError) {
          if (hasColError) {
            completionStyle = " bg-red-100 opacity-50";
          } else {
            exit = 1;
          }
        } else if (hasBlockConflict) {
          exit = 1;
        } else {
          completionStyle = " bg-green-200 opacity-50";
        }
      } else {
        exit$2 = 3;
      }
      if (exit$2 === 3) {
        if (hasRowError) {
          exit$1 = 2;
        } else if (hasColError) {
          if (hasColError) {
            completionStyle = " bg-red-100 opacity-50";
          } else {
            exit = 1;
          }
        } else if (hasBlockConflict) {
          exit = 1;
        } else {
          completionStyle = " bg-green-100 opacity-50";
        }
      }
      
    } else {
      exit$1 = 2;
    }
    if (exit$1 === 2) {
      if (hasRowError || hasColError) {
        completionStyle = " bg-red-100 opacity-50";
      } else {
        exit = 1;
      }
    }
    if (exit === 1) {
      completionStyle = hasBlockConflict ? " bg-red-100 opacity-50" : (
          isBlockComplete || isColComplete ? " bg-green-100 opacity-50" : ""
        );
    }
    return "w-10 h-10 border border-gray-300 flex items-center justify-center relative" + borderStyle + validityStyle + initialStyle + completionStyle;
  };
  return JsxRuntime.jsx("div", {
              children: JsxRuntime.jsx("input", {
                    className: "w-full h-full text-center focus:outline-none bg-transparent\n        " + (
                      hasRowError || hasColError ? "text-red-600 font-bold" : (
                          isRowComplete || isColComplete ? "text-green-600 font-bold" : ""
                        )
                    ),
                    disabled: cell.isInitial,
                    maxLength: 1,
                    type: "text",
                    value: cell.value,
                    onChange: (function ($$event) {
                        var newValue = $$event.target.value;
                        var validNumberPattern;
                        var exit = 0;
                        switch (size) {
                          case 4 :
                              validNumberPattern = /^[1-4]$/;
                              break;
                          case 6 :
                              validNumberPattern = /^[1-6]$/;
                              break;
                          case 9 :
                              validNumberPattern = /^[1-9]$/;
                              break;
                          default:
                            exit = 1;
                        }
                        if (exit === 1) {
                          validNumberPattern = /^$/;
                        }
                        if (newValue === "" || validNumberPattern.test(newValue)) {
                          return onCellChange([
                                      rowIndex,
                                      colIndex,
                                      newValue
                                    ]);
                        }
                        
                      })
                  }),
              className: getCellClassName()
            });
}

var make = Cell;

export {
  make ,
}
/* react/jsx-runtime Not a pure module */
