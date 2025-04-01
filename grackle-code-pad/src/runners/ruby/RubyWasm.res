%%raw(
  "import { DefaultRubyVM } from 'https://cdn.jsdelivr.net/npm/@ruby/wasm-wasi@2.7.1/dist/browser/+esm';"
)

type wasmBinary = unit
type wasmRunnable = unit
type rubyResult = {output: string}
type rubyVm = {eval: string => rubyResult}
type rubyRunner = {vm: rubyVm}
type vmRunner = {eval: string => string}

@val external fetchWasm: string => promise<wasmBinary> = "fetch"
@scope("WebAssembly") @val
external compileStreaming: wasmBinary => promise<wasmRunnable> = "compileStreaming"

@val external getRubyRunner: wasmRunnable => promise<rubyRunner> = "DefaultRubyVM"

let rubySource = "https://cdn.jsdelivr.net/npm/@ruby/3.4-wasm-wasi@2.7.1/dist/ruby+stdlib.wasm"

let makeRuby = async () => {
  let binary: wasmBinary = await fetchWasm(rubySource)
  let wasmVm: wasmRunnable = await compileStreaming(binary)
  let runner = await getRubyRunner(wasmVm)
  let executor: vmRunner = {eval: s => runner.vm.eval(s).output}
  executor
}
