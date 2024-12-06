// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Js_exn from "rescript/lib/es6/js_exn.js";
import * as Js_dict from "rescript/lib/es6/js_dict.js";
import * as Js_json from "rescript/lib/es6/js_json.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";

function createEmptyGrid(size) {
  return Belt_Array.makeBy(size, (function (param) {
                return Belt_Array.make(size, {
                            value: "",
                            isInitial: false,
                            isValid: true,
                            notes: []
                          });
              }));
}

function processGridResponse(json) {
  var response = Belt_Option.getExn(Js_json.decodeObject(json));
  var data = Belt_Option.getExn(Js_dict.get(response, "data"));
  var grid = Belt_Option.getExn(Js_json.decodeArray(Belt_Option.getExn(Js_dict.get(Belt_Option.getExn(Js_json.decodeObject(data)), "grid"))));
  return Belt_Array.map(grid, (function (row) {
                return Belt_Array.map(Belt_Option.getExn(Js_json.decodeArray(row)), (function (cell) {
                              var cellObj = Belt_Option.getExn(Js_json.decodeObject(cell));
                              return {
                                      value: Belt_Option.getWithDefault(Js_json.decodeString(Belt_Option.getExn(Js_dict.get(cellObj, "value"))), ""),
                                      isInitial: Belt_Option.getWithDefault(Js_json.decodeBoolean(Belt_Option.getExn(Js_dict.get(cellObj, "is_initial"))), false),
                                      isValid: Belt_Option.getWithDefault(Js_json.decodeBoolean(Belt_Option.getExn(Js_dict.get(cellObj, "is_valid"))), true),
                                      notes: []
                                    };
                            }));
              }));
}

function sudokuGenerate() {
  return fetch("/api/sudoku/generate", {
                method: "GET"
              }).then(function (response) {
              if (response.ok) {
                return response.json();
              } else {
                return Promise.reject(Js_exn.raiseError("Network response was not ok"));
              }
            });
}

export {
  createEmptyGrid ,
  processGridResponse ,
  sudokuGenerate ,
}
/* No side effect */