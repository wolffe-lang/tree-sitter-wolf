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
  `?` and `!T` error rows, call-site `f(mut x)`, region caps
  (`[mem.region.cap.1]`), and Go-adapted newline termination
  (`[gram.lex.newline]`) — which blocks now take literally, because
  `expr_stmt ::= expr TERM` is what stops D69's refused struct literal
  from being re-read as a bare block.
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

A tree-sitter grammar has no refusal, only an ERROR node, so a lexer-tier
rule is encoded only where the token boundary happens to make it visible.
`\u{…}` is the worked case: `UNI_ESC` bounds the escape at one to six hex
digits, and because nothing else starts with `'`, seven digits leave an
ERROR in a char literal exactly where wolfc reports E0101. Inside `"…"`
there is no such boundary, so le05 gives the refusal a node instead: with
v0.2.2 making the string escape set a production of its own (`STR_ESC`),
everything that set does not derive lexes as **`invalid_escape`**, painted
`@error`. That keeps the tree's shape — one escape token where one escape
stands — where both alternatives lie: a bounded permissive token made
`"\u{0000041}"` re-enter interpolation mode and grow a fake
`(interpolation (integer_literal))`, and an ERROR node would throw away the
rest of an otherwise fine literal. `docs/spec-findings-le04.md` records the
measurement; `docs/spec-findings-le05.md` records the node.

The parser-tier separator law is encoded the same way, and there it *is*
visible: D67 and D69 make the comma required between pattern members,
struct-literal fields, closure parameters and capture-list names, so
`Point { x .. }`, `Point { x y }`, `fn(a b)` and `unsafe c [a b]` each
leave an ERROR node exactly at the missing separator, with the enclosing
node intact.

Licensed under GPL-3.0-or-later.
