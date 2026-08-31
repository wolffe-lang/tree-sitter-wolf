# Changelog

## le03 — 2026-08-31 — the grammar catches up

The le02 known-gaps line closes: re-read at wolf-lang `83f83bb`
(v0.2.0+s129), the grammar gains char literals (`[gram.lex.char]`,
D58 — one scalar or escape between single quotes, the `'\u{…}'`
unprintable spellings included; `@constant.character`), D63 binder
comma groups (`[gram.item.let]` — let/var take `binder (',' binder)*`;
the tree gains a `binder` node and the locals queries follow), and
struct patterns (`[gram.pat.struct]` — `Point { x, y: p, .. }` with
shorthand, nesting, and a `rest_pattern` node). str-`+` (D62) needed
nothing: the expression rules never typed `+`. Twelve corpus cases
across three files; every recorded tree re-checked under the binder
reshape.

The wolf-lang trunk-corpus gate goes **17 failures → 0** (the
contract's 8 char-era files had grown by s129's D63 and
struct-pattern witnesses): 443 files parse at zero ERROR nodes, and
the gate gains a pass-count floor (443) so a shrunken checkout cannot
go green by parsing nothing. One gate fix rode along: a deliberately
unparseable *member* of a directory-module counter-example
(`resolve/broken_sibling/mangled.lu`) is now excluded by its
`entry.lu`'s own parse-tier directive — still by directive, never by
construct. Two new spec silences recorded in
`docs/spec-findings-le03.md` and filed (wolf-lang#189: `'\u{…}'`
EBNF/prose digit-count disagreement; wolf-lang#190: the comma before
`..` in a struct pattern).

## s126 — 2026-08-28 — the file-wide origin marker

The grammar learns `#![…]` as an inner attribute (`[gram.attr.index]`,
the D61 origin marker), and the shebang rule narrows to `#!` not
followed by `[` so the two constructs cannot shadow each other. Parser
regenerated and committed, with a highlight query and corpus test for
the new node.

## le02 — 2026-08-27 — the grammar that belonged to nobody

The scaffold posture ends: the repo gains a real grammar, written as
an independent reading of wolf-lang's `spec/01-grammar.md` — the
compiler's parser deliberately not consulted. The full surface: items,
the §3.2 precedence climb, `[]` generics, regions, traits and `dyn`,
row patterns, call-site `f(mut x)`, newline termination per
`[gram.lex.newline]`; an external scanner owns `"""` multiline strings
and raw `#`-fences; f-strings are modelled, not faked — `{expr}` in
any string literal is a real expression subtree. `queries/` ships
highlights, locals and injections (C into `unsafe c` bodies, regex
into `re"…"`); an 84-case corpus suite and a CI gate that parses
wolf-lang's whole corpus at zero ERROR nodes. Four spec-silence
findings drafted for upstream rather than settled by peeking
(`docs/spec-findings-le02.md`).

**Known gaps:** char literals (`[gram.lex.char]`, D58) postdate the
grammar's spec reading — `'a'` is not a token here yet, and the
grammar has no `char` type keyword; the corpus gate's pin predates the
char-era witnesses.

## The scaffold — 2026-08-09 → 08-12

A seed with the port to follow opportunistically: an honest scaffold
gate in CI that arms itself when `grammar.js` arrives (r01 audit row
10 — the grammar then lived vendored in wolf-lsp), the license settled
to GPL-3.0-or-later (D41 as amended), and a prose pass correcting
stale claims. No grammar shipped in this span, and the README said so.
