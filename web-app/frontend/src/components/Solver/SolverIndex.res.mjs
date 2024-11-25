// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Button from "../Button/Button.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";

function SolverIndex(props) {
  var tabName = props.tabName;
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("h2", {
                              children: tabName.toUpperCase() + " Formula Input",
                              className: "text-xl font-semibold mb-4"
                            }),
                        JsxRuntime.jsx("textarea", {
                              className: "w-full h-64 p-2 border rounded",
                              placeholder: "Enter " + tabName.toUpperCase() + " formula..."
                            }),
                        JsxRuntime.jsx(Button.make, {
                              children: "Download Template",
                              onClick: (function (param) {
                                  
                                })
                            }),
                        JsxRuntime.jsx(Button.make, {
                              children: "Upload problme batch",
                              onClick: (function (param) {
                                  
                                })
                            })
                      ]
                    }),
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("h2", {
                              children: "Solution",
                              className: "text-xl font-semibold mb-4"
                            }),
                        JsxRuntime.jsx("div", {
                              children: "Solution will appear here",
                              className: "border p-4 h-64 overflow-auto"
                            }),
                        JsxRuntime.jsx(Button.make, {
                              children: "Solve",
                              className: "mt-6",
                              onClick: (function (param) {
                                  
                                })
                            })
                      ]
                    })
              ],
              className: "grid grid-cols-2 gap-6"
            });
}

var make = SolverIndex;

export {
  make ,
}
/* Button Not a pure module */