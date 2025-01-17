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

function getBlockIndex(rowIndex, colIndex, subGridSize) {
  var blockRow = Caml_int32.div(rowIndex, subGridSize);
  var blockCol = Caml_int32.div(colIndex, subGridSize);
  return Math.imul(blockRow, subGridSize) + blockCol | 0;
}

function hasRowConflict(rowIndex, grid) {
  var row = Core__Option.getOr(Belt_Array.get(grid, rowIndex), []);
  var numbers = Belt_Array.map(Belt_Array.keep(row, (function (cell) {
              return cell.value !== "";
            })), (function (cell) {
          return cell.value;
        }));
  return numbers.length > Belt_SetString.size(Belt_SetString.fromArray(numbers));
}

function hasColConflict(colIndex, grid) {
  var numbers = Belt_Array.keepMap(grid, (function (row) {
          return Core__Option.filter(Core__Option.map(Belt_Array.get(row, colIndex), (function (cell) {
                            return cell.value;
                          })), (function (value) {
                        return value !== "";
                      }));
        }));
  return numbers.length > Belt_SetString.size(Belt_SetString.fromArray(numbers));
}

function hasBlockConflict(blockIndex, grid) {
  var match = grid.length;
  var subGridSize;
  switch (match) {
    case 4 :
    case 6 :
        subGridSize = 2;
        break;
    default:
      subGridSize = 3;
  }
  var blockRow = Caml_int32.div(blockIndex, subGridSize);
  var blockCol = Caml_int32.mod_(blockIndex, subGridSize);
  var startRow = Math.imul(blockRow, subGridSize);
  var startCol = Math.imul(blockCol, subGridSize);
  var numbers = [];
  for(var rowOffset = 0; rowOffset < subGridSize; ++rowOffset){
    for(var colOffset = 0; colOffset < subGridSize; ++colOffset){
      var row = startRow + rowOffset | 0;
      var col = startCol + colOffset | 0;
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
}

function Grid(props) {
  var onCellChange = props.onCellChange;
  var values = props.values;
  var size = props.size;
  var subGridSize = size !== 4 ? 3 : 2;
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
    var blockRow = Caml_int32.div(blockIndex, subGridSize);
    var blockCol = Caml_int32.mod_(blockIndex, subGridSize);
    var startRow = Math.imul(blockRow, subGridSize);
    var startCol = Math.imul(blockCol, subGridSize);
    var numbers = [];
    for(var rowOffset = 0; rowOffset < subGridSize; ++rowOffset){
      for(var colOffset = 0; colOffset < subGridSize; ++colOffset){
        var row = startRow + rowOffset | 0;
        var col = startCol + colOffset | 0;
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
  var validateCell = function (row, col, value, grid) {
    var rowValid = !hasRowConflict(row, grid) && isRowComplete(row, grid);
    var colValid = !hasColConflict(col, grid) && isColComplete(col, grid);
    var blockIndex = getBlockIndex(row, col, subGridSize);
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
                                          var blockIndex = getBlockIndex(rowIndex, colIndex, subGridSize);
                                          var blockConflict = hasBlockConflict(blockIndex, values);
                                          var blockComplete = isBlockComplete(blockIndex, values);
                                          var cellBackgroundClass = blockConflict ? "bg-red-200/50" : (
                                              hasColError || hasRowError ? "bg-red-100/50" : (
                                                  blockComplete ? "bg-green-100/50" : ""
                                                )
                                            );
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
                                                      className: cellBackgroundClass,
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
                                  className: "flex flex-nowrap"
                                }, rowIndex.toString());
                    })),
              className: "inline-block"
            });
}

var make = Grid;

export {
  getUniqueNumbers ,
  isUniqueNumbers ,
  isAllFilled ,
  getBlockIndex ,
  hasRowConflict ,
  hasColConflict ,
  hasBlockConflict ,
  make ,
}
/* Cell Not a pure module */
