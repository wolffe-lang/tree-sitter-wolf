# Changelog

## le06 — 2026-09-02 — two types wolf does not have

The `v0.2.2..v0.2.3` spec diff asks nothing of `grammar.js`, and the
re-reading found something in the query files instead.

**`usize` and `isize` are gone from `@type.builtin`.** They have been in
`queries/highlights.scm` since the first queries commit (le02,
`743b592`), unjustified there and unjustifiable now: no `spec/*.md` file
names either one at v0.2.3 (`grep -rn 'usize\|isize' spec/` is empty),
and neither is in the compiler's closed builtin set. Painting a name
`@type.builtin` tells a reader the language HAS that type, so this list
was teaching two types that do not exist — the same class of error
wolf-lsp#4 was, pointed the other way. `wrapping` takes their place:
D56's wrapping-arithmetic constructor (`wrapping[u32]`,
`[type.numlit.cast.wrap]`) is a real builtin type name and was the one
name in that set this list had never carried.

**`byte` needed nothing, and waits on nothing.** le06's contract asked
whether `byte` should join the list if wolf-lang s135 had merged by the
grammar step. Measured: s135 has NOT merged (trunk tops out at `5241ab7`,
the r06 release merge; there is no `origin/s135`), and `byte` has been in
this list since le02 and is a builtin at v0.2.3 regardless. Nothing to
add, nothing to defer to le07 — see `docs/spec-findings-le06.md` §2 for
what le07 may owe instead if s135 lands byte-tier *syntax*.

**wolf-lang#215 is closed, and the grammar was already right.** le05
filed `MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` as named-and-
undefined; v0.2.3 defines all three plus `SCALAR`, `NL`, `MULTI_PART`,
`MULTI_TEXT`, `HASH_FENCE`, `RAW_TEXT`, `GENERALIZED_STRING`, `GEN_TEXT`
and `CHAR_TEXT`. No grammar change follows, and that is the point:
`raw_string_literal` has had no `$.interpolation` child and
`generalized_string_literal` a flat immediate body since le02, read off
the prose — and `RAW_TEXT ::= SCALAR*` / `GEN_TEXT ::= (SCALAR - ('"' |
NL))*` say exactly that. The productions are now the vendored proof of
which reading was right, which is what wolf-lsp le06 needed to fix its
tmLanguage (wolf-lsp#4/#5).

**Gates and the floor.** All four green at the v0.2.3 corpus: the
committed parser matches `grammar.js`, the suite holds at **111**, the
three query files load, and wolf-lang's corpus parses at zero ERROR
nodes — 486 `.lu` files, 20 parse-tier counter-examples excluded by
directive, **466** gated. The floor ratchets **463 → 466**. It tracks
trunk rather than a tag, because that is what the gate checks out; a
floor left at a v0.2.2 measurement would let the gate lose three files'
worth of coverage silently.

No known gaps carried forward.

## le05 — 2026-09-02 — the separator is the law

wolf-lang **v0.2.2**'s grammar deltas reach the grammar, and le04's two
open items close with them.

**D67 — the pattern family.** `closed_pattern`'s struct arm writes its
tail as `(',' '..'?)?`: `..` follows a separator like one more member.
`Point { x, .. }` and `Point { x, }` parse; `Point { x .. }` does not.
That last spelling was le04's whole known-gaps line — wolfgang accepted
it as an unlicensed recovery-loop accident, D67 ruled the production the
law, s131 landed the tightening, and the grammar follows at the pin.
`Point { x y }`, `(a b)` and `Some(a b)` — D67's other named laxities —
already ERRORed here; they get corpus cases now so the refusal shape is
pinned rather than assumed.

**D69 — literals, closures, captures.** Three of the four already held:
`field_initializer_list`, `closure_parameters` and `capture_list` have
demanded the separator since le02. The fourth had an escape hatch, and
closing it is this entry's one structural change. `Point { x: 1 y: 2 }`
ERRORed, but the shorthand-only `Point { x y }` did not: it cannot be a
`struct_expression`, so GLR re-read `let p = Point { x y }` as
`let p = Point` followed by a bare block statement `{ x y }` holding two
unterminated expression statements — a clean tree exactly where wolfc
reports E0201. So `block` now takes `[gram.lex.newline]` literally, which
is the spec's own letter and not a special case: `block ::= '{' stmt*
expr? '}'` with `expr_stmt ::= expr TERM` and `let_item ::= … TERM`, so a
statement is terminated and the block's trailing expression is not. The
rescue dies at its second statement and the ERROR lands on the missing
separator. `source_file` needed nothing — the rescue always goes through
a `block`. Measured against a 21-spelling battery of legal one-liners,
tail expressions, `;`-separated bodies, nested items first/middle/last,
`if`/`match`/`for` in both positions, bare block statements and
interleaved comments: all still parse.

**STR_ESC — and le04's flagged node, taken.** v0.2.2 closes le04's own
finding (wolf-lang#198) with le04's suggested fix verbatim: `STR_PART`
gains a `STR_ESC` alternative, and `CHAR_ESC ::= STR_ESC | '\' "'"`
derives the char set from the string set instead of restating it. That
makes the string escape set a *production* rather than a prose bullet —
"and nothing else; any other `\` is E0101 at the escape" — which is what
le04 was waiting for. So `escape_sequence` narrows to exactly `STR_ESC`,
and everything it no longer derives lexes as a new **`invalid_escape`**
node, painted `@error`. le04 measured why it has to be a node: bounding
the old permissive token yielded no ERROR at all (its `.` catch-all made
`"\u{0000041}"` lex as `\u`, after which `{0000041}` re-entered
interpolation mode and grew a fake `(interpolation (integer_literal))`
where an escape stood), and an ERROR node would throw away the rest of an
otherwise fine literal while `locals.scm`/`injections.scm` read tree
shape. `invalid_escape` keeps the shape — one escape token where one
escape stands — and names the refusal: the over-long and zero-digit
`\u{…}`, `\xH`, `\q`, and `\'`, which is a char literal's escape alone.
`char_literal` needed no change; its token already carried exactly
`STR_ESC` plus `\'`. **This is a new node in the public surface**, and
wolf-lsp's inventory takes it at this same pin.

**`region_cap` — a fourth delta, and the gate is what found it.** Not in
this sprint's brief; the corpus gate refused to go green without it.
v0.2.2 splits `region_expr`'s sugar in two and adds a creation-time byte
budget (`region_cap ::= 'cap' ':' expr`, s132, `[mem.region.cap.1]`),
making `cap` a third contextual keyword beside `rc` and `pool`. The split
is load-bearing and the spec says why: on the sugar form the cap
parenthesis follows the NAME, so an anonymous sugar block takes no cap,
because `region (cap: n)` is already the value form. Three corpus files
exercise it — `conc/proc_cap_fault_join.lu`, `faults/region_cap_breach.lu`,
`memory/region_cap_boundary.lu` — and they were the entire ERROR set
before the rule landed.

**Gates.** The corpus suite grows 104 → 111 cases (the four D67/D69
refusal shapes, the region-cap forms, and the string-escape set rewritten
now that the bound binds inside `"…"` too). The wolf-lang trunk-corpus
gate re-measured at v0.2.2 — the corpus is byte-identical at the tag and
at trunk `4d9683d`, 482 `.lu` files: **463 files gated**, 19 parse-tier
counter-examples excluded by directive, zero ERROR nodes. The pass-count
floor ratchets **454 → 463**.

One finding in `docs/spec-findings-le05.md`, filed as **wolf-lang#215**:
`MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` are named in
`spec/grammar.ebnf` and defined nowhere in it — the same class of gap
#198 just closed, one literal over. It bit immediately: deciding whether
`invalid_escape` belongs inside a `"""` literal had to be read off a
contrast between three prose bullets, because `[gram.lex.str.raw]` and
`[gram.lex.str.gen]` exclude escapes outright while `[gram.lex.str.multi]`
says only that interpolation works. The silence is read as "escapes work"
— the forms that exclude them say so — and `invalid_escape` joins
`escape_sequence` there, as it has been since le02.

**Known gaps:** none carried forward. le04's D67 line closes here.

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
the other wolfgang laxities D67 names, already ERROR here. D67 names
wolf-lang#190 as its tracker, but that issue is CLOSED (`COMPLETED`,
2026-09-01, seconds after the v0.2.1 release draft — a merge message, most
likely, not intent), so the tracker D67 points at is not open. Flagged on
the issue, not reopened.

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
