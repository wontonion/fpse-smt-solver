@val external toast: {..} = "window.toast"

let success = (message: string) => {
  ReactToastify.success(message)
}

let error = (message: string) => {
  ReactToastify.error(message)
}

let info = (message: string) => {
  ReactToastify.info(message)
}

let warning = (message: string) => {
  ReactToastify.warning(message)
} 