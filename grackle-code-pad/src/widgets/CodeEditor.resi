type codeEditorProps = {
  ...JsxDOM.domProps,
  _value: string,
  _onChange: string => unit,
  _onExecute: unit => unit,
  _highlightGrammar: string,
  _highlightLanguage: string,
}

let make: codeEditorProps => Jsx.element
