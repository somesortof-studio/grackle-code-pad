module LocalStorage = {
  @val @scope("localStorage")
  external removeItem: string => unit = "removeItem"

  @val @scope("localStorage") @return(nullable)
  external getItem: string => option<string> = "getItem"
}

let selectionKey = "__selection__"
let runProgram = (runner: string => string, _program: string): string => runner(_program)

@react.component
let make = () => {
  let (runner, setRunner) = React.useState(() => None)
  let (selection, setSelection) = React.useState(() =>
    LocalStorage.getItem(selectionKey)->(o => Option.getOr(o, ""))
  )
  let (program, setProgram) = React.useState(() => "")
  let (output, setOutput) = React.useState(() => "")

  React.useEffect0(() => {
    let loadRuby = () =>
      RubyWasm.makeRuby()->Promise.then(vmr => {
        setRunner(_ => Some(vmr))
        Promise.resolve(None)
      })
    loadRuby()
    ->Promise.catch(e => {
      Console.warn(e)
      Promise.resolve(None)
    })
    ->ignore
    None
  })

  <div className="p-6">
    // Selection context
    // -----------------
    <h2 className="text-xl font-semibold"> {"Selection"->React.string} </h2>
    <SelectionView selection={selection} />
    <Button
      onClick={_ => {
        LocalStorage.removeItem(selectionKey)
        setSelection(_ => "")
      }}>
      {"Clear"->React.string}
    </Button>
    // Code panel
    // ----------
    <Separator />
    <h2 className="text-xl font-semibold"> {"Editor"->React.string} </h2>
    // TODO: add documentation widget
    <CodeEditor
      _value={program}
      _onChange={program' => setProgram(_ => program')}
      _highlightGrammar={"ruby"}
      _highlightLanguage={"ruby"}
    />
    <Button
      onClick={_ =>
        setOutput(_ => Option.getOr(Option.map(runner, r => runProgram(r.eval, program)), ""))}>
      {"Run"->React.string}
    </Button>
    // Outputs
    // -------
    <Separator />
    <h2 className="text-xl font-semibold"> {"Output"->React.string} </h2>
    <ResultView result={output} />
  </div>
}
