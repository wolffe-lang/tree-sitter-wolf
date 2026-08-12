# tree-sitter-wolf

The home of the tree-sitter grammar for wolf (`.lu` files), for editor and
GitHub syntax highlighting.

The grammar is not here yet. This repo is a scaffold: a README, a license,
and a CI job that arms the real gates the day `grammar.js` arrives. Today's
highlighting comes from the TextMate grammars in
[wolf-lsp](https://github.com/wolffe-lang/wolf-lsp) under
`clients/vscode/syntaxes/`. The port is filled in opportunistically between
compiler sprints and has no owner sprint.

The port is scoped to highlighting and nothing more. The source of truth
for wolf's syntax is `spec/01-grammar.md` and
`spec/grammar.ebnf` in
[wolf-lang](https://github.com/wolffe-lang/wolf-lang), and the parsers that
matter are the compiler's and the interpreter's.

Licensed under GPL-3.0-or-later.
