# Changelog

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
