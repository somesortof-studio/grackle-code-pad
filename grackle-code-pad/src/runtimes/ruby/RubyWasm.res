open Runtimes

%%raw(
  "import { DefaultRubyVM } from 'https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.7.1/dist/browser/+esm';"
)

let rubySourceUrl = "https://cdn.jsdelivr.net/npm/@ruby/3.4-wasm-wasi@2.7.1/dist/ruby+stdlib.wasm"

type wasmModule = unit
type rubyResult = {toString: unit => string}
type rubyVm = {eval: string => rubyResult, evalAsync: string => promise<rubyResult>}
type rubyRunner = {vm: rubyVm}

let formatRubyError = exn => {
  switch exn {
  | Exn.Error(obj) =>
    switch Exn.message(obj) {
    | Some(msg) => "Ruby error occurred: " ++ msg
    | None => "Unparsable error captured!"
    }
  | _ => "Unexpected error thrown!"
  }
}

@scope("WebAssembly") @val
external compileStreaming: Fetch.Response.t => promise<wasmModule> = "compileStreaming"

@val external makeRubyVm: wasmModule => promise<rubyRunner> = "DefaultRubyVM"

let loadRubyVm = (): promise<rubyRunner> => {
  Fetch.fetch(rubySourceUrl, {})->Promise.then(compileStreaming)->Promise.then(makeRubyVm)
}

let wrapRubyVm = (rubyRunner): runtime => {
  eval: source =>
    rubyRunner.vm.evalAsync(source)
    ->Promise.then(result => Promise.resolve(result.toString()->Ok))
    ->Promise.catch(exn => Promise.resolve(exn->formatRubyError->Error)),
  metadata: {
    title: "Ruby WASM",
    hint: Some({homepage: "https://github.com/ruby/ruby.wasm"}),
    prismJs: Some({language: "ruby", grammar: "ruby"}),
  },
}
