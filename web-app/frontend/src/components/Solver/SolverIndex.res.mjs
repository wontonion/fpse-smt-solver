// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Button from "../Button/Button.res.mjs";
import * as Belt_Option from "rescript/lib/es6/belt_Option.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as JsxRuntime from "react/jsx-runtime";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";

var $$Blob = {};

function getSolverExample(tabName) {
  var match;
  switch (tabName) {
    case "sat" :
        match = [
          "Enter CNF formula in DIMACS format",
          "p cnf 3 2\n1 2 -3 0\n-2 3 0"
        ];
        break;
    case "smt" :
        match = [
          "Enter SMT formula",
          "placeholder for SMT formula example"
        ];
        break;
    default:
      match = [
        "",
        ""
      ];
  }
  return match[0] + "\n\nExample:\n" + match[1];
}

function downloadTemplate(tabName) {
  try {
    var content = getSolverExample(tabName) + "\n\nDelete all template text before entering your formula";
    var element = document.createElement("a");
    var file = new Blob([content], {
          type: "text/plain"
        });
    var url = URL.createObjectURL(file);
    element.setAttribute("href", url);
    element.setAttribute("download", tabName.toLowerCase() + "_template.txt");
    document.body.appendChild(element);
    element.click();
    document.body.removeChild(element);
    URL.revokeObjectURL(url);
    return ;
  }
  catch (raw_err){
    var err = Caml_js_exceptions.internalToOCamlException(raw_err);
    console.error("Error downloading template:", err);
    return ;
  }
}

function clearTextarea(textareaRef) {
  Belt_Option.forEach(Caml_option.nullable_to_opt(textareaRef.current), (function (textarea) {
          textarea.value = "";
        }));
}

function SolverIndex(props) {
  var tabName = props.tabName;
  var textareaRef = React.useRef(null);
  var handleFileUpload = function (e) {
    var fileInput = e.target;
    var files = fileInput.files;
    if (files.length <= 0) {
      return ;
    }
    var file = files.item(0);
    var reader = new FileReader();
    reader.onerror = (function (_err) {
        console.error("Error reading file");
      });
    reader.onload = (function ($$event) {
        var content = $$event.target.result;
        var textarea = textareaRef.current;
        if (!(textarea == null)) {
          textarea.value = content;
          return ;
        }
        
      });
    reader.readAsText(file);
  };
  return JsxRuntime.jsxs("div", {
              children: [
                JsxRuntime.jsxs("div", {
                      children: [
                        JsxRuntime.jsx("h2", {
                              children: tabName.toUpperCase() + " Formula Input",
                              className: "text-xl font-semibold mb-4"
                            }),
                        JsxRuntime.jsx("textarea", {
                              ref: Caml_option.some(textareaRef),
                              className: "w-full h-64 p-2 border rounded font-mono whitespace-pre",
                              placeholder: getSolverExample(tabName)
                            }),
                        JsxRuntime.jsx("input", {
                              className: "hidden",
                              id: "fileInput",
                              accept: ".txt",
                              type: "file",
                              onChange: handleFileUpload
                            }),
                        JsxRuntime.jsxs("div", {
                              children: [
                                JsxRuntime.jsxs("div", {
                                      children: [
                                        JsxRuntime.jsx(Button.make, {
                                              children: "Download Template",
                                              onClick: (function (param) {
                                                  downloadTemplate(tabName);
                                                })
                                            }),
                                        JsxRuntime.jsx(Button.make, {
                                              children: "Upload problem batch",
                                              onClick: (function (param) {
                                                  Belt_Option.forEach(Caml_option.nullable_to_opt(document.getElementById("fileInput")), (function (prim) {
                                                          prim.click();
                                                        }));
                                                })
                                            }),
                                        JsxRuntime.jsx(Button.make, {
                                              children: "Clear",
                                              onClick: (function (param) {
                                                  clearTextarea(textareaRef);
                                                })
                                            })
                                      ],
                                      className: "flex gap-4"
                                    }),
                                JsxRuntime.jsx(Button.make, {
                                      children: "Solve",
                                      className: "mt-6",
                                      onClick: (function (param) {
                                          
                                        })
                                    })
                              ],
                              className: "flex mt-4 gap-4 justify-between"
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
                            })
                      ]
                    })
              ],
              className: "grid grid-cols-2 gap-6"
            });
}

var make = SolverIndex;

export {
  $$Blob ,
  getSolverExample ,
  downloadTemplate ,
  clearTextarea ,
  make ,
}
/* react Not a pure module */
