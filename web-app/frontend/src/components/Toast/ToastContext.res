type dispatch = Types.toastAction => unit
type context = {
  toasts: array<Types.toast>,
  dispatch: dispatch,
}

let context = React.createContext({
  toasts: [],
  dispatch: _ => (),
})

module Provider = {
  let make = React.Context.provider(context)
}

@react.component
let make = (~children) => {
  let (toasts, dispatch) = React.useReducer((state, action) => {
    switch action {
    | Types.AddToast(toast) => Js.Array2.concat(state, [toast])
    | Types.RemoveToast(id) => Js.Array.filter((t: Types.toast) => t.id != id, state)
    }
  }, [])

  let value = {
    toasts: toasts,
    dispatch: dispatch,
  }

  <Provider value=value>
    {children}
    <div className="fixed bottom-4 right-4 flex flex-col gap-2">
      {React.array(
        Js.Array.map(
          (toast: Types.toast) =>
            <Toast
              key={toast.id}
              message={toast.message}
              toastType={toast.toastType}
              onClose={() => dispatch(Types.RemoveToast(toast.id))}
            />,
          toasts,
        ),
      )}
    </div>
  </Provider>
} 