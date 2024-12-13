type toastPosition = [
  | #topRight
  | #topLeft
  | #topCenter
  | #bottomRight
  | #bottomLeft
  | #bottomCenter
]

let positionToString = (position: toastPosition) => {
  switch position {
  | #topRight => "top-right"
  | #topLeft => "top-left"
  | #topCenter => "top-center"
  | #bottomRight => "bottom-right"
  | #bottomLeft => "bottom-left"
  | #bottomCenter => "bottom-center"
  }
}

type theme = [
  | #light
  | #dark
  | #colored
]

type toastType = [
  | #success
  | #error
  | #info
  | #warning
]

type toastOptions = {
  "type": string,
  "position": toastPosition,
  "autoClose": int,
  "hideProgressBar": bool,
  "closeOnClick": bool,
  "pauseOnHover": bool,
  "draggable": bool,
  "progress": Js.undefined<float>,
}

@module("react-toastify") external toast: string => unit = "toast"
@module("react-toastify") @scope("toast") external error: string => unit = "error"
@module("react-toastify") @scope("toast") external success: string => unit = "success"
@module("react-toastify") @scope("toast") external info: string => unit = "info"
@module("react-toastify") @scope("toast") external warning: string => unit = "warning"

@module("react-toastify") external toastContainer: React.component<{..}> = "ToastContainer"

@send external makeToastContainerProps: {..} => {
  "position": string,
  "autoClose": int,
  "hideProgressBar": bool,
  "newestOnTop": bool,
  "closeOnClick": bool,
  "rtl": bool,
  "pauseOnFocusLoss": bool,
  "draggable": bool,
  "pauseOnHover": bool,
  "theme": string,
} = "%identity"

@module("react-toastify/dist/ReactToastify.css") external css: unit = "default" 