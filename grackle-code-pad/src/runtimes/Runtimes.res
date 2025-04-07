type hintMetadata = {homepage: string}
type prismJsMetadata = {grammar: string, language: string}
type runtimeMetadata = {title: string, hint: option<hintMetadata>, prismJs: option<prismJsMetadata>}

type runtime = {
  eval: string => promise<result<string, string>>,
  metadata: runtimeMetadata,
}
