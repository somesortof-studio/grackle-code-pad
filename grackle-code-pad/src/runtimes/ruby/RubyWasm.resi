open Runtimes

type wasmModule = unit
type rubyResult = {toString: unit => string}
type rubyVm = {eval: string => rubyResult, evalAsync: string => promise<rubyResult>}
type rubyRunner = {vm: rubyVm}

let loadRubyVm: unit => promise<rubyRunner>
let wrapRubyVm: rubyRunner => runtime
