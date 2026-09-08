# tree-sitter-wolf

The tree-sitter grammar for wolf (`.lu` files), for editor and GitHub
syntax highlighting. It was written from the specification alone:
`spec/01-grammar.md` and its `[gram.*]` anchors in
[wolf-lang](https://github.com/wolffe-lang/wolf-lang) are the source of
truth, and the compiler's parser was deliberately not consulted. The
grammar exists for highlighting. The parsers that decide what a wolf
program means are the compiler's and the interpreter's.

What's here:

- `grammar.js`: items, expressions with the §3.2 precedence climb, `[]`
  generics, regions, traits and `dyn`, closures, `match` row patterns
  and struct patterns (`[gram.pat.struct]`), char literals
  (`[gram.lex.char]`, D58), D63 binder comma groups, postfix `?` and
  `!T` error rows, call-site `f(mut x)`, region caps
  (`[mem.region.cap.1]`), and Go-style newline termination
  (`[gram.lex.newline]`). Blocks take newline termination literally,
  because `expr_stmt ::= expr TERM` is what stops D69's refused struct
  literal from being re-read as a bare block.
- `src/scanner.c`: an external scanner for `"""` multiline strings (a
  lone `"` or `""` is content, and the literal ends at the next `"""`)
  and for raw-string `#` fences.
- Every plain string literal is an f-string (`[gram.lex.str]`), so
  `{expr}` inside any string is a real expression subtree, including
  nested strings, format specs and `{n:>{w}}`.
- `queries/`: `highlights.scm`, `locals.scm` and `injections.scm` with
  standard capture names. C is injected into `unsafe c` bodies and
  regex into `re"…"` literals.
- `test/corpus/`: the grammar's own reviewed test suite.
  `script/parse-wolf-corpus.sh` parses wolf-lang's full corpus in CI and
  requires zero ERROR nodes; the corpus's own parse-tier
  counter-examples are excluded by directive.

`src/parser.c` is committed, following ecosystem convention: Helix's
`hx -g build` and Zed's extension builder compile it from this repo
without running `tree-sitter generate`. CI checks that the committed
parser matches `grammar.js`.

Where highlighting benefits from tolerance, the grammar accepts a
superset of the language. Constructs the compiler rejects with a
diagnostic (comparison chaining, E0003; detached moded receivers,
E0210; empty statements, E0002) still parse here. The grammar accepts
everything the spec accepts; if a valid construct fails to parse, that
is a grammar bug or a filed spec finding.

A tree-sitter grammar cannot refuse input, so lexer-level rules are
encoded only where the token boundary happens to expose them. `\u{…}`
is the worked example. `UNI_ESC` bounds the escape at one to six hex
digits, and because nothing else starts with `'`, seven digits leave an
ERROR in a char literal exactly where wolfc reports E0101. Inside `"…"`
there is no such boundary, so the refusal becomes a node: since v0.2.2
made the string escape set a production of its own (`STR_ESC`),
everything outside that set lexes as `invalid_escape`, painted
`@error`. That keeps the tree's shape (one escape token where one
escape stands) where the alternatives would not. A bounded permissive
token made `"\u{0000041}"` re-enter interpolation mode and grow a fake
`(interpolation (integer_literal))`, and an ERROR node would discard
the rest of an otherwise valid literal. `docs/spec-findings-le04.md`
records the measurement and `docs/spec-findings-le05.md` the node.

The parser-level separator rule is encoded the same way, and there the
boundary is visible. D67 and D69 require the comma between pattern
members, struct-literal fields, closure parameters and capture-list
names, so `Point { x .. }`, `Point { x y }`, `fn(a b)` and
`unsafe c [a b]` each leave an ERROR node at the missing separator with
the enclosing node intact.

Licensed under GPL-3.0-or-later.
