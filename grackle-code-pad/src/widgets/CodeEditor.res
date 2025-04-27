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
  _onExecute: unit => unit,
  _highlightGrammar: string,
  _highlightLanguage: string,
}

module Keybinds = {
  type keyMapSequence = string
  type keyMapSpec = Instance({combo: keyMapSequence, event: string})
  type keyMap = dict<keyMapSpec>
  type keyHandlers = dict<unit => unit>

  type hotKeysProps = {
    ...JsxDOM.domProps,
    keyMap?: keyMap,
    handlers: keyHandlers,
  }

  // TODO: fix the legacy feature dependency
  // @see https://github.com/ruanyl/react-keyboard/issues/19
  // @see https://legacy.reactjs.org/blog/2018/03/27/update-on-async-rendering.html
  @module("react-keyboard") @react.component(: hotKeysProps)
  external make: hotKeysProps => Jsx.element = "HotKeys"
}

module Actions = {
  type t = Execute

  let toJs: t => string = v => {
    switch v {
    | Execute => "execute"
    }
  }
}

@react.component(: codeEditorProps)
let make = (~_value, ~_onChange, ~_onExecute, ~_highlightGrammar, ~_highlightLanguage) => {
  <Keybinds
    keyMap={[
      (Actions.Execute->Actions.toJs, Keybinds.Instance({combo: "ctrl+shift+/", event: "keyup"})),
    ]->Js.Dict.fromArray}
    handlers={[(Actions.Execute->Actions.toJs, _onExecute)]->Js.Dict.fromArray}>
    <Editor
      className="w-full min-h-64 rounded-md border-2 border-gray-600 mb-2 mt-1 text-mono"
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
  </Keybinds>
}
