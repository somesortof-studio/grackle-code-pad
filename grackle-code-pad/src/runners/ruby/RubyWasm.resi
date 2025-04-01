type vmRunner = {eval: string => string}

let makeRuby: unit => promise<vmRunner>
