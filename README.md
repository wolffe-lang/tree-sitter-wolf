# tree-sitter-wolf

The tree-sitter grammar for wolf (`.lu` files, lupus), for editor and
GitHub syntax highlighting. Written by sprint le02 as an **independent
reading of the spec** — `spec/01-grammar.md` and its `[gram.*]` anchors in
[wolf-lang](https://github.com/wolffe-lang/wolf-lang) are the authority;
the compiler's parser was deliberately not consulted (the wolf-interp
doctrine applied to grammar). The port is scoped to highlighting and
nothing more: the parsers that matter are the compiler's and the
interpreter's.

What's here:

- `grammar.js` — the full surface: items, expressions with the §3.2
  precedence climb, `[]` generics, regions, traits and `dyn`, closures,
  `match` row patterns and struct patterns (`[gram.pat.struct]`), char
  literals (`[gram.lex.char]`, D58), D63 binder comma groups, postfix
  `?` and `!T` error rows, call-site `f(mut x)`, and Go-adapted newline
  termination (`[gram.lex.newline]`).
- `src/scanner.c` — external scanner for `"""` multiline strings (a lone
  `"` or `""` is content; the literal ends exactly at the next `"""`) and
  raw-string `#`-fences.
- **F-strings are modelled, not faked**: every plain string literal is an
  f-string (`[gram.lex.str]`), so `{expr}` inside any string is a real
  expression subtree — nested strings, format specs, `{n:>{w}}` and all.
- `queries/` — `highlights.scm`, `locals.scm`, `injections.scm` with
  standard capture names (C is injected into `unsafe c` bodies, regex
  into `re"…"` literals).
- `test/corpus/` — the grammar's own reviewed test suite, and
  `script/parse-wolf-corpus.sh` — CI parses wolf-lang's full corpus tree
  and requires **zero ERROR nodes** (only the corpus's own parse-tier
  counter-examples are excluded, by directive).

`src/parser.c` is committed (ecosystem convention): Helix's `hx -g build`
and Zed's extension builder compile it straight from this repo and never
run `tree-sitter generate`. CI enforces that the committed parser matches
`grammar.js`.

The grammar is a deliberate *superset* where highlighting wants tolerance:
constructs the compiler rejects with diagnostics (comparison chaining,
E0003; detached moded receivers, E0210; empty statements, E0002) still
parse here. It is never narrower than the spec; a construct that will not
parse is a bug or a filed spec-silence finding, not an exclusion.

Licensed under GPL-3.0-or-later.
