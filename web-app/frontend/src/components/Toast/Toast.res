@react.component
let make = (~message: string, ~toastType: Types.toastType, ~onClose: unit => unit) => {
  let bgColor = switch toastType {
  | #success => "bg-green-500"
  | #error => "bg-red-500"
  | #info => "bg-blue-500"
  }

  let icon = switch toastType {
  | #success => "✓"
  | #error => "✕"
  | #info => "ℹ"
  }

  React.useEffect(() => {
    let timeoutId = Js.Global.setTimeout(() => {
      onClose()
    }, 3000)
    Some(() => Js.Global.clearTimeout(timeoutId))
  }, [])

  <div
    className={`fixed bottom-4 right-4 flex items-center p-4 text-white rounded-lg shadow-lg ${bgColor}`}>
    <span className="mr-2"> {React.string(icon)} </span>
    <span> {React.string(message)} </span>
  </div>
} 