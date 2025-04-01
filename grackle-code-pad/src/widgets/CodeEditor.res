%%raw("import 'prismjs/themes/prism.css'")

module PrismJs = {
  type grammar = unit
  type languageMap = dict<grammar>
  type defaultLanguages = {clike: grammar}

  @module("prismjs")
  external highlight: (string, grammar, string) => string = "highlight"

  @module("prismjs")
  external languages: languageMap = "languages"

  @module("prismjs")
  external defaultLanguages: defaultLanguages = "languages"
}

module Editor = {
  type editorProps = {
    ...JsxDOM.domProps,
    onValueChange: string => unit,
    highlight: string => string,
    padding: option<int>,
  }

  @module("react-simple-code-editor") @react.component(: editorProps)
  external make: editorProps => Jsx.element = "default"
}

type codeEditorProps = {
  ...JsxDOM.domProps,
  _value: string,
  _onChange: string => unit,
  _highlightGrammar: string,
  _highlightLanguage: string,
}

@react.component(: codeEditorProps)
let make = (~_value, ~_onChange, ~_highlightGrammar, ~_highlightLanguage) => {
  <Editor
    className="w-full h-64 resize:vertical rounded-md border-2 border-gray-600 mb-2 mt-1"
    value={_value}
    onValueChange={_onChange}
    highlight={_ =>
      PrismJs.highlight(
        _value,
        Option.getOr(
          Js.Dict.get(PrismJs.languages, _highlightGrammar),
          PrismJs.defaultLanguages.clike,
        ),
        _highlightLanguage,
      )}
    padding={Some(8)}
  />
}
