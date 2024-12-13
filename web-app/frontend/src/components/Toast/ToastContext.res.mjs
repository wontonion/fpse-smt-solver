// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Toast from "./Toast.res.mjs";
import * as React from "react";
import * as Js_array from "rescript/lib/es6/js_array.js";
import * as JsxRuntime from "react/jsx-runtime";

var context = React.createContext({
      toasts: [],
      dispatch: (function (param) {
          
        })
    });

var make = context.Provider;

var Provider = {
  make: make
};

function ToastContext(props) {
  var match = React.useReducer((function (state, action) {
          if (action.TAG === "AddToast") {
            return state.concat([action._0]);
          }
          var id = action._0;
          return Js_array.filter((function (t) {
                        return t.id !== id;
                      }), state);
        }), []);
  var dispatch = match[1];
  var toasts = match[0];
  var value = {
    toasts: toasts,
    dispatch: dispatch
  };
  return JsxRuntime.jsxs(make, {
              value: value,
              children: [
                props.children,
                JsxRuntime.jsx("div", {
                      children: Js_array.map((function (toast) {
                              return JsxRuntime.jsx(Toast.make, {
                                          message: toast.message,
                                          toastType: toast.toastType,
                                          onClose: (function () {
                                              dispatch({
                                                    TAG: "RemoveToast",
                                                    _0: toast.id
                                                  });
                                            })
                                        }, toast.id);
                            }), toasts),
                      className: "fixed bottom-4 right-4 flex flex-col gap-2"
                    })
              ]
            });
}

var make$1 = ToastContext;

export {
  context ,
  Provider ,
  make$1 as make,
}
/* context Not a pure module */
