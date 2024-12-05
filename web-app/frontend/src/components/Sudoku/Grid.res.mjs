// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Cell from "./Cell.res.mjs";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_int32 from "rescript/lib/es6/caml_int32.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Belt_SetString from "rescript/lib/es6/belt_SetString.js";
import * as JsxRuntime from "react/jsx-runtime";

function getUniqueNumbers(numbers) {
  return Belt_SetString.size(Belt_SetString.fromArray(numbers));
}

function isUniqueNumbers(numbers) {
  return numbers.length === Belt_SetString.size(Belt_SetString.fromArray(numbers));
}

function isAllFilled(numbers) {
  return Belt_Array.every(numbers, (function (value) {
                return value !== "";
              }));
}

function Grid(props) {
  var onCellChange = props.onCellChange;
  var values = props.values;
  var size = props.size;
  var subGridSize;
  switch (size) {
    case 4 :
    case 6 :
        subGridSize = 2;
        break;
    default:
      subGridSize = 3;
  }
  var isRowComplete = function (rowIndex, grid) {
    var row = Core__Option.getOr(Belt_Array.get(grid, rowIndex), []);
    var numbers = Belt_Array.map(row, (function (cell) {
            return cell.value;
          }));
    if (isUniqueNumbers(numbers)) {
      return isAllFilled(numbers);
    } else {
      return false;
    }
  };
  var isColComplete = function (colIndex, grid) {
    var numbers = Belt_Array.keepMap(grid, (function (row) {
            return Core__Option.map(Belt_Array.get(row, colIndex), (function (cell) {
                          return cell.value;
                        }));
          }));
    if (isUniqueNumbers(numbers)) {
      return isAllFilled(numbers);
    } else {
      return false;
    }
  };
  var isBlockComplete = function (blockIndex, grid) {
    var startRow = Caml_int32.div(blockIndex, subGridSize);
    var startCol = Caml_int32.mod_(blockIndex, subGridSize);
    var numbers = [];
    for(var rowOffset = 0; rowOffset < subGridSize; ++rowOffset){
      for(var colOffset = 0; colOffset < subGridSize; ++colOffset){
        var row = Math.imul(startRow, subGridSize) + rowOffset | 0;
        var col = Math.imul(startCol, subGridSize) + colOffset | 0;
        var cell = Core__Option.flatMap(Belt_Array.get(grid, row), (function(col){
            return function (row) {
              return Belt_Array.get(row, col);
            }
            }(col)));
        if (cell !== undefined) {
          numbers.push(cell.value);
        }
        
      }
    }
    if (isUniqueNumbers(numbers)) {
      return isAllFilled(numbers);
    } else {
      return false;
    }
  };
  var hasRowConflict = function (rowIndex, grid) {
    var row = Core__Option.getOr(Belt_Array.get(grid, rowIndex), []);
    var numbers = Belt_Array.map(Belt_Array.keep(row, (function (cell) {
                return cell.value !== "";
              })), (function (cell) {
            return cell.value;
          }));
    return numbers.length > Belt_SetString.size(Belt_SetString.fromArray(numbers));
  };
  var hasColConflict = function (colIndex, grid) {
    var numbers = Belt_Array.keepMap(grid, (function (row) {
            return Core__Option.filter(Core__Option.map(Belt_Array.get(row, colIndex), (function (cell) {
                              return cell.value;
                            })), (function (value) {
                          return value !== "";
                        }));
          }));
    return numbers.length > Belt_SetString.size(Belt_SetString.fromArray(numbers));
  };
  var hasBlockConflict = function (blockIndex, grid) {
    var startRow = Caml_int32.div(blockIndex, subGridSize);
    var startCol = Caml_int32.mod_(blockIndex, subGridSize);
    var numbers = [];
    for(var rowOffset = 0; rowOffset < subGridSize; ++rowOffset){
      for(var colOffset = 0; colOffset < subGridSize; ++colOffset){
        var row = Math.imul(startRow, subGridSize) + rowOffset | 0;
        var col = Math.imul(startCol, subGridSize) + colOffset | 0;
        var cell = Core__Option.flatMap(Belt_Array.get(grid, row), (function(col){
            return function (row) {
              return Belt_Array.get(row, col);
            }
            }(col)));
        if (cell !== undefined && cell.value !== "") {
          numbers.push(cell.value);
        }
        
      }
    }
    return numbers.length > Belt_SetString.size(Belt_SetString.fromArray(numbers));
  };
  var validateCell = function (row, col, value, grid) {
    var rowValid = !hasRowConflict(row, grid) && isRowComplete(row, grid);
    var colValid = !hasColConflict(col, grid) && isColComplete(col, grid);
    var blockIndex = Math.imul(Caml_int32.div(row, subGridSize), subGridSize) + Caml_int32.div(col, subGridSize) | 0;
    var blockValid = !hasBlockConflict(blockIndex, grid) && isBlockComplete(blockIndex, grid);
    if (rowValid && colValid) {
      return blockValid;
    } else {
      return false;
    }
  };
  return JsxRuntime.jsx("div", {
              children: Belt_Array.mapWithIndex(values, (function (rowIndex, row) {
                      var hasRowError = hasRowConflict(rowIndex, values);
                      var rowComplete = isRowComplete(rowIndex, values);
                      return JsxRuntime.jsx("div", {
                                  children: Belt_Array.mapWithIndex(row, (function (colIndex, cell) {
                                          var isRightBorder = Caml_int32.mod_(colIndex + 1 | 0, subGridSize) === 0 && colIndex !== (size - 1 | 0);
                                          var isBottomBorder = Caml_int32.mod_(rowIndex + 1 | 0, subGridSize) === 0 && rowIndex !== (size - 1 | 0);
                                          var hasColError = hasColConflict(colIndex, values);
                                          var colComplete = isColComplete(colIndex, values);
                                          var blockIndex = Math.imul(Caml_int32.div(rowIndex, subGridSize), subGridSize) + Caml_int32.div(colIndex, subGridSize) | 0;
                                          var blockConflict = hasBlockConflict(blockIndex, values);
                                          var blockComplete = isBlockComplete(blockIndex, values);
                                          return JsxRuntime.jsx(Cell.make, {
                                                      cell: cell,
                                                      size: size,
                                                      rowIndex: rowIndex,
                                                      colIndex: colIndex,
                                                      isRightBorder: isRightBorder,
                                                      isBottomBorder: isBottomBorder,
                                                      hasRowError: hasRowError,
                                                      hasColError: hasColError,
                                                      isRowComplete: rowComplete,
                                                      isColComplete: colComplete,
                                                      hasBlockConflict: blockConflict,
                                                      isBlockComplete: blockComplete,
                                                      onCellChange: (function (param) {
                                                          var value = param[2];
                                                          var col = param[1];
                                                          var row = param[0];
                                                          validateCell(row, col, value, values);
                                                          onCellChange([
                                                                row,
                                                                col,
                                                                value
                                                              ]);
                                                        })
                                                    }, rowIndex.toString() + "-" + colIndex.toString());
                                        })),
                                  className: "flex " + (
                                    hasRowError ? "bg-red-100 opacity-85" : (
                                        rowComplete ? "bg-green-100 opacity-80" : ""
                                      )
                                  )
                                }, rowIndex.toString());
                    })),
              className: "grid gap-0"
            });
}

var make = Grid;

export {
  getUniqueNumbers ,
  isUniqueNumbers ,
  isAllFilled ,
  make ,
}
/* Cell Not a pure module */
