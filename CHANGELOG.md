# Changelog

## le04 — 2026-09-01 — the escape gets a bound

A small catch-up: wolf-lang **v0.2.1**'s grammar deltas reach the
grammar. The spec diff `83f83bb..v0.2.1` is three files and one
substantive change — r04 closed le03's own finding (wolf-lang#189) at
the measured letter, so `CHAR_ESC`'s `HEX_DIGIT+` is gone and a named
`UNI_ESC` bounds the `\u{…}` escape at **one to six** hex digits. The
bound is on the escape's SHAPE, not the value it names: leading zeros
count, so `'\u{000041}'` is `'A'` and `'\u{0000041}'` is E0101 before
anything asks what it spells.

`char_literal` takes the bound. A tree-sitter grammar has no refusal,
but here it has the next best thing: nothing else starts with `'`, so
seven digits leave an ERROR node exactly where wolfc reports, and
`test/corpus/chars.txt` pins that shape alongside the in-bounds
one-through-six sweep. (The zero-digit half, `'\u{}'`, was already
outside the token.)

The string half is **honestly noted, not encoded**. v0.2.1's prose says
the bound binds inside `"…"` too, and measured at le04, bounding the
`escape_sequence` token there produces no ERROR: its last alternative is
a `.` catch-all, so `"\u{0000041}"` would lex as `\u` and then re-enter
interpolation mode on `{0000041}`, growing a plausible-looking
`(interpolation (integer_literal))` where an escape stood. Changing the
tree's SHAPE is a worse lie than a permissive token — `locals.scm` and
`injections.scm` read shape — so the digit count stays unbounded inside
a string and `test/corpus/strings.txt` records what the grammar actually
does. Encoding it honestly wants a distinct `invalid_escape` node
painted `@error`, which is a new public node and a downstream change in
wolf-lsp: **flagged, not taken.**

The wolf-lang trunk-corpus gate re-measured at v0.2.1 (trunk `e6548a9`;
the corpus grew to 467 `.lu` files): **454 files gated**, 13 parse-tier
counter-examples excluded by directive, zero ERROR nodes. The pass-count
floor ratchets **443 → 454**. The one over-long escape in the whole
corpus lives in `corpus/grammar/char_uni_seven_digits.lu`, which is a
`check: fail(E0101)` counter-example and therefore excluded — the bound
costs the gate nothing.

Two findings in `docs/spec-findings-le04.md`: `UNI_ESC` is named but
wired only into `CHAR_ESC`, so `STR_PART` still derives no escapes at
all while the prose asserts the bound binds there (suggested fix: a
`STR_ESC` alternative); and the recorded limit above, so the next reader
does not "fix" the string half. `[mem.model.order]`'s D66 amendment —
the third file in the diff — is purely semantic and needs nothing here.

**Known gaps:** **D67** (ruled 2026-09-01) makes pattern separators
required — `','` separates fields and `'..'` follows a separator like
one more member — and wolf-lang's s131 lands the wolfgang tightening on
trunk **this wave**. This grammar is deliberately NOT changed for it:
the editors take it at their next pin (le05-era), so until then
`Point { x .. }` still parses here and will start refusing under a
future `wolfc`. The exposure is exactly that one spelling — `struct_pattern`'s
`optional(',')` before `rest_pattern`; `Point { x y z }` and `(a b)`,
the other wolfgang laxities D67 names, already ERROR here. wolf-lang#190
stays open as D67's tracker.

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
