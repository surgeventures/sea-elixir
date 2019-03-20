[
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
  line_length: 100,
  locals_without_parens: [emit_to: 1],
  export: [
    locals_without_parens: [emit_to: 1]
  ]
]
