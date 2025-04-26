module LocalStorage = {
  @val @scope("localStorage")
  external removeItem: string => unit = "removeItem"

  @val @scope("localStorage") @return(nullable)
  external getItem: string => option<string> = "getItem"
}

let getAllKeys: (dict<'a>, array<string>) => array<'a> = (dict, keys) =>
  keys
  ->Js.Array2.map(Js.Dict.get(dict))
  ->Js.Array2.filter(Option.isSome)
  ->Js.Array2.map(o => Option.getExn(o))

module Keybindings = {
  type keyboardKey = string
  type keyboardKeysMap = dict<keyboardKey>
  type keybindingProps = {cmd: array<keyboardKey>, callback: unit => unit}

  @module("@harshsinghatz/react-key-bindings")
  external keys: keyboardKeysMap = "keyboardKeys"

  @module("@harshsinghatz/react-key-bindings")
  external use: array<keybindingProps> => unit = "useKeybindings"
}

let selectionKey = "__selection__"

let formatOutput = (r: result<string, string>): string => {
  switch r {
  | Ok(o) => o
  | Error(e) => String.concat("Error!: ", e)
  }
}

let loadRuby = (recordRunner: Runtimes.runtime => unit) => {
  RubyWasm.loadRubyVm()
  ->Promise.then(vm => Promise.resolve(RubyWasm.wrapRubyVm(vm)))
  ->Promise.then(runner => {
    recordRunner(runner)
    Promise.resolve(None)
  })
}

let evaluate = (runner: Runtimes.runtime, _program: string): promise<result<string, string>> =>
  runner.eval(_program)

let runProgram = (
  runner: option<Runtimes.runtime>,
  program: string,
  handle: result<string, string> => unit,
) =>
  Option.map(runner, r =>
    evaluate(r, program)->Promise.then(output => Promise.resolve(handle(output)))
  )->ignore

@react.component
let make = () => {
  let (runner, setRunner) = React.useState(() => None)
  let (selection, setSelection) = React.useState(() =>
    LocalStorage.getItem(selectionKey)->(o => Option.getOr(o, ""))
  )
  let (program, setProgram) = React.useState(() => "")
  let (output, setOutput) = React.useState(() => "")

  React.useEffect0(() => {
    loadRuby(runner => setRunner(_ => Some(runner)))
    ->Promise.catch(e => {
      Console.warn(e)
      Promise.resolve(None)
    })
    ->ignore
    None
  })

  let execute = _ => runProgram(runner, program, o => setOutput(_ => formatOutput(o)))

  Keybindings.use([
    {
      cmd: getAllKeys(Keybindings.keys, ["Control", "Shift", "Slash"]),
      callback: execute,
    },
  ])

  <div className="p-6">
    <h1 className="text-xl font-bold"> {"🐦‍⬛ Grackle"->React.string} </h1>
    <Separator />
    // Selection context
    // -----------------
    // TODO: make selection only work on Chrome extensions
    <details>
      <summary>
        <span className="text-l italic font-semibold"> {"Context"->React.string} </span>
      </summary>
      <SelectionView selection={selection} />
      <Button
        onClick={_ => {
          LocalStorage.removeItem(selectionKey)
          setSelection(_ => "")
        }}>
        {"Clear"->React.string}
      </Button>
    </details>
    // Code panel
    // ----------
    // TODO: make runtimes selectable
    <Separator />
    <h2 className="text-xl font-semibold"> {"Editor"->React.string} </h2>
    <div className="cm-tooltipped group-hover:*:bg-gray-100">
      // TODO: add a tooltip on running with hotkeys
      <p className="font-mono text-xs italic text-gray-400">
        {String.concat(
          ">> ",
          runner->Option.mapOr("loading ...", r => r.metadata.title),
        )->React.string}
      </p>
      <span className="cm-tooltip">
        {runner->Option.mapOr(<p />, someRunner =>
          <a target="_blank" href={someRunner.metadata.hint->Option.mapOr("...", h => h.homepage)}>
            <p className="font-mono text-xs italic text-gray-200">
              {":- homepage"->React.string}
            </p>
          </a>
        )}
      </span>
    </div>
    // TODO: add documentation widget
    <CodeEditor
      _value={program}
      _onChange={program' => setProgram(_ => program')}
      _highlightGrammar={runner
      ->Option.flatMap(r => r.metadata.prismJs)
      ->Option.mapOr("clike", p => p.grammar)}
      _highlightLanguage={runner
      ->Option.flatMap(r => r.metadata.prismJs)
      ->Option.mapOr("clike", p => p.language)}
    />
    <Button onClick={execute}> {"Run"->React.string} </Button>
    // Outputs
    // -------
    // TODO: make prettier and better output styling
    <Separator />
    <h2 className="text-xl font-semibold"> {"Output"->React.string} </h2>
    <ResultView result={output} />
    <Button
      onClick={_ => {
        setOutput(_ => "")
      }}>
      {"Clear"->React.string}
    </Button>
  </div>
}
