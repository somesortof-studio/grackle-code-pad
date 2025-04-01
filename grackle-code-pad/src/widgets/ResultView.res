@react.component
let make = (~result) =>
  <ViewboxLarge>
    <code className="w-full h-24 text-gray-600"> {React.string(result)} </code>
  </ViewboxLarge>
