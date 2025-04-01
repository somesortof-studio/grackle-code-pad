@react.component
let make = (~selection) =>
  <Viewbox>
    <code className="w-full h-24 text-gray-600"> {React.string(selection)} </code>
  </Viewbox>
