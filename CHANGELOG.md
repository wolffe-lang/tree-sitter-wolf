# Changelog

## tl09 — 2026-09-17 — the floor at v0.2.15, and the dispatch that fired for real

**The floor ratchets 584 → 640.** Two numbers exist at this bump and the
floor takes the larger. The tag `v0.2.15` (`2e4ca769`) carries 666 `.lu`
files, 32 of them parse-tier counter-examples, and the gate parses the
other **634** at zero ERROR nodes; current trunk (`6d2aa72`) is six files
further on, 672 `.lu`, the same 32 excluded, and gates **640**. The gate
checks out wolf-lang's DEFAULT BRANCH, so trunk is the number it will meet
and 640 is the floor; 634 is recorded beside it in
`script/parse-wolf-corpus.sh` because 634 is what the release-day run
actually printed. Witnessed at both boundaries locally: FLOOR=634 passes
and FLOOR=635 fails "checkout suspect" at the tag, FLOOR=640 passes and
FLOOR=641 fails at trunk.

**The grammar moved and cost this repository nothing, measured.** Unlike
`v0.2.14`, this release DOES move `spec/grammar.ebnf`: +5 −2 in one hunk,
where s163 paid wolf-lang#28's debt and wrote `FORMAT_SPEC` out as a real
production — `FMT_FILL`, `FMT_ALIGN` and `FMT_TYPE` under the new
`[type.interp.spec]` anchor — replacing a comment that cited a `spec §7.4`
which never existed. `grammar.js` already models the whole of it
permissively (`format_spec: ':' repeat1(choice(…))`, with
`[gram.amb.fmtcolon]`'s first-top-level-colon rule and nested
interpolations), so the written-out EBNF names what this mirror already
accepted: zero productions changed, zero external-scanner work,
`tree-sitter generate` reproduces `src/` byte-identically. Measured
directly as well as through the corpus, on a fixture spelling every
`FMT_TYPE` letter and every `FMT_ALIGN` form plus fill, sign, zero-pad,
width, precision, a nested `{n:>{w}}` and a bare `{n:}` — zero ERROR
nodes, against a negative control (`"{n:>8"`, unterminated) that does
produce them, so the check can still red.

**#13's dispatch fired for real, and the log is the evidence — not the
colour.** tl08 wired the sender into wolf-lang's `release.yml` and proved
the receiver wakes by dispatching one by hand (run 35021950744,
2026-09-15, 584 files, 3m13s). At `v0.2.15` it fired on its own: the
`grammar-mirror` job started 12 s after the release workflow, logged
`since v0.2.14: 73 file(s) moved under spec/grammar.ebnf,
spec/01-grammar.md, corpus/`, then `dispatched wolf-lang-corpus to
wolffe-lang/tree-sitter-wolf for v0.2.15 (2e4ca769…)`, then `receiver run:
…/actions/runs/35213581814` — POST accepted and the receiver visible to
the sender within 20 s. Run 35213581814 here ran all four gates green in
3m23s: `PASS: zero ERROR nodes across the corpus (634 files, floor 584)`.

The token is alive and is `TREE_SITTER_WOLF_DISPATCH_TOKEN` — a
fine-grained token scoped to this repository alone, Contents read+write
for the dispatches endpoint and Actions read so the sender can name the
run it started. Both scopes are proven by the log rather than assumed: the
`dispatched …` line requires the write half, and the `receiver run: …`
line requires the read half. **The sender SKIPS LOUDLY AND STAYS GREEN
when the secret is absent**, so a green `grammar-mirror` job is not
evidence that anything was dispatched; `ci.yml`'s receiver comment now
says so, together with the reminder that a `gate` job returning in seconds
has not run the corpus — #9 measured 122–340 s, median 170 s, and both
dispatch-triggered runs sit inside that band.

## tl08 — 2026-09-15 — the floor at v0.2.14, and the alarm before the schedule sleeps

**#14, the ratchet.** wolf-lang `v0.2.14` (`30731a6`, trunk at the time)
moves no grammar: `git diff c1e62fa v0.2.14 -- spec/grammar.ebnf
spec/01-grammar.md` is empty, so the external scanner pays nothing. The
corpus grew seven files (s159/s160's witnesses) to 615 `.lu`, of which 31
are parse-tier counter-examples, and the gate parses the other 584 at zero
ERROR nodes. The floor ratchets 577 → 584. Witnessed at the boundary
locally (FLOOR=584 passes, FLOOR=585 fails "checkout suspect") and in CI
at run 35021366541: `PASS: zero ERROR nodes across the corpus (584 files,
floor 584)`.

**#12, the schedule that sleeps.** GitHub disables a public repository's
scheduled workflows after 60 days without activity, and a schedule that
never runs never goes red. The two keepalive shapes, a bot commit and a
scheduled call to the REST `enable` endpoint, both exist to defeat that
timer. The second was the default mode of gautamkrishnar/keepalive-workflow
v2, which GitHub Staff disabled for a terms-of-service violation. So
`ci.yml` gains `sleep-alarm` instead. On every scheduled or manual run it
reads the default branch's last commit date and each workflow's `state`
from the API. At 45 days it goes red and opens one issue (marker `scheduled
gate will sleep`) naming the date the schedule sleeps. It changes no
workflow state and writes nothing to git. Proven on branch `tl08`: run
35021366541 is quiet at 45 (`3 day(s) ago … quiet: 42 day(s) before the
alarm`), and run 35021377856, planted at `sleep_warn_days=0`, is red at
`sleep-alarm` alone and opened #15, closed by hand as planted.

**#13's receiver meets a sender.** wolf-lang's `release.yml` gains the
`wolf-lang-corpus` dispatch on tags that move the grammar or corpus
(wolf-lang PR, branch `tl08-dispatch`). A local run of that step at
`v0.2.14` started run 35021950744 here, event `repository_dispatch`.

Also: eight double-encoded UTF-8 sequences (em dashes, one ellipsis) in
tl04's comments in `grammar.js` and `script/parse-wolf-corpus.sh` are
repaired. `tree-sitter generate` leaves `src/` byte-identical.

## tl04 — 2026-09-12 — s158's three productions, and the gate that was already red

The wolf-lang corpus gate reads wolf-lang's DEFAULT BRANCH, so s157 and
s158 turned it red here with no push to this repository at all. The
last recorded green (run 34633743874, 2026-09-11) simply predates them.
Opening tl04, `script/parse-wolf-corpus.sh` against `c1e62fa` exited 1
on 13 files: eight `list_lit_*`, four `error_alias_*`, and one nobody
had filed. It now gates 577 files at zero ERROR nodes, floor ratcheted
546 → 577.

`primary` gained the list literal (s158, wolf-lang#154):
`list_lit ::= '[' (expr (',' expr)* ','?)? ']'`. The upstream issue says
a tree-sitter grammar gets the bracket clash for free because
`list_lit` lives in `primary` and `index_args` in the postfix chain —
which is true of the ebnf and not of this grammar, where there is no
`primary` node and `index_expression` is
`field('value', $._expression)`. What separates them here is the
TERMINATOR: `index_expression` can only shift its `[` with an
expression already on the stack, and a block admits a following
statement only after a `_terminator`. So `[10, 20, 30][1]` is a literal
indexed, `xs\n[9]` is two statements, and no conflict is declared —
the right answer for the wrong stated reason.

`bare_item` gained the error-set alias (s158, wolf-lang#36):
`error_item ::= 'error' IDENT '=' error_row TERM?`, and because
`source_file` repeats `_statement` directly, module and statement
position are one rule here — four `error_item` nodes in the witness,
three at module level and one in a block, matching wolfc's own
`error_set_alias_parses_in_a_block_too`.

`error` is contextual, and this is where it parts company with `then`.
tl01 recorded that `then` needs nothing beyond `word: $ =>
$.identifier`, because keyword extraction only yields a keyword in
states that admit it and the one state admitting `then` — after a
complete `if` condition — admits no identifier at all. Statement start
admits both `error` and an `expression_statement`'s leading identifier,
so extraction takes the keyword and the identifier reading dies.
Measured with a plain `'error'` literal in the rule: `error = 4`,
`error(error)` and `error.field` each produced an ERROR node, while
`corpus/rows/error_alias_ident.lu` still passed — that witness puts
`error` in a field, a function name, a binding and a member, but never
at statement start, so it cannot catch this. The fix is an external
token spelling wolfc's own predicate, `Ident("error") Ident '='` and
nothing shorter. `[gram.inv.kw]`'s fifty are unchanged; the internal
lexer never learns the word.

`type` gained the brace-less alias tail, `type '!' path` — `T !
IoErrors` beside `T ! {row}`. Its own node rather than wolfc's shape
(which lowers both to one `ErrorRow`), because this grammar mirrors the
ebnf and because the highlighter needs the distinction: the path is a
type reference in type position, not one of the tags a braced row
spells.

`closed_pattern` gained the bare dotted path (s157, wolf-lang#162,
`[gram.pat.nullary]`) — `Color.Red` without the parens, so a `match`
over a closed set of names can be spelled. Not s158's and not what
tree-sitter-wolf#7 asked for, but `match_nullary_variant.lu` was the
gate's last ERROR and no s158 work could go green around it.
`Color.Blue(shade)` is still `constructor_pattern`, a lone `none` is
still `identifier`.

`range` needed no production at all: `range[int]` already parsed as
`path type_args?`. It did NOT join the closed builtin-scalar list, and
that is upstream's own distinction — wolfc leaves `BUILTIN_TYPES` at
the same seventeen prims and puts `range` in `PRELUDE` beside `List`
and `channel`, because it takes an argument, then adds
`PRELUDE_TYPE_ONLY` whose entire contents is `range`, because the name
resolves in type position only. The scoping is load-bearing, not tidy:
that `#any-of?` list matches a bare `(identifier)` in ANY position,
which is why `var int = 5` paints its own binding `@type.builtin`
today. `int` is a name almost nobody binds; `range` is one wolf-lang's
corpus binds twice. Measured across the seven files: the 6 `range`
identifier nodes in type position across `range_type_{param,return,
inclusive,char,overflow}.lu` all paint `@type.builtin`, and the 7 in
`random_differs.lu` and `random_edges.lu` — `var range = true` — paint
none.

One bug the corpus tests could not have caught. The keyword's first
capture came back zero-width, `(0,5)`–`(0,5)` with empty text:
`ts_lexer__advance` assigns `token_start_position` on every skip=true
call, unconditionally and after `mark_end` has already run, so skipping
the trailing whitespace dragged the token's start to its end. The
corpus s-expression format prints neither anonymous nodes nor extents,
so `tree-sitter test` was green throughout; only `tree-sitter query`
showed it. The lookahead now advances with skip=false.

## tl01 — 2026-09-11 — the v0.2.11 re-vendor: four syntax deltas, one of them not in the ebnf

Five releases since the last vendor (`v0.2.6..v0.2.11`): 1183 added
spec lines across ten files, and six changed lines in
`spec/grammar.ebnf` — three productions.

`trait_item` gained the alias bound (s155): `trait Num = Add + Sub +
Mul` names every trait in its list. The right-hand side is the same
`bound ::= path ('+' path)*` a generic parameter takes, so it is the
same `trait_bound` node, and `(trait_bound (path (identifier) @type))`
already painted it.

`if_expr` gained a second alternative (s151, wolf-lang#307): `then` is
optional before a block and required before a bare branch, and `then`
is contextual, never reserved. Nothing enforces the contextuality here
and nothing needs to: `word: $ => $.identifier` means an extracted
keyword is only produced in states that admit it, and the one state
that admits `then` is the one after a complete `if` condition. Measured
over the twelve `corpus/grammar/if_then_*.lu` witnesses at `v0.2.11`:
16 `then` tokens paint `@keyword.control.conditional`, and the other 6
— three `identifier` bindings, two `.then(` member calls, one `fn then`
declaration — do not. The braced alternative outranks the bare one so
`consequence` stays a `block` wherever braces are written; the bare one
outranks `PREC.ELSE` so the `if`'s own `else` binds before
`else_expression`'s defaulting one (`[gram.amb.else]`).

`closed_pattern` gained literal ranges (s147, wolf-lang#287): `lo..hi`
and `lo..=hi`, both endpoints required. Open ends are the slice
spellings and the compiler refuses them in pattern position, so nothing
admits them here either.

The fourth delta is not in the ebnf at all. `[gram.lex.newline]` gained
an exception at `v0.2.9` (wolf-lang#276, retiring E0005): no terminator
is inserted at a newline whose next token is `else`, past blank lines
and comments. Terminator insertion is a lexer rule and the extracted
grammar writes it as the opaque `TERM`, so a re-vendor from
`spec/grammar.ebnf` alone would have shipped a grammar that ERRORs on
two gated corpus files. It lives in `src/scanner.c` as
`NEWLINE_BEFORE_ELSE`. The grammar-level spelling was written and
measured first and is wrong twice: tree-sitter resolves the
shift/reduce statically in favour of the shift, so every newline after
an expression became an ERROR, and had it forked instead it would have
forked on every line of every file.

s154's `fn_body?` asked for nothing. `fn_item ::= … (block | TERM)` is
unchanged across the window and `grammar.js` has carried
`optional(field('body', $.block))` since the extern-function work;
`corpus/traits/op_eq_inverting.lu` parsed at zero ERROR nodes before
this lane touched anything. It is now pinned by a test of its own,
because the pre-existing trait test covered a bodiless member followed
by a provided one, which is a different shape.

One finding filed against wolf-lang: `[gram.inv.ctx]` §6.2, the
inventory of contextual keywords, is byte-identical at `v0.2.6` and
`v0.2.11` and does not list `then`, although `[gram.expr.if]` states
twice that `then` is contextual and `[gram.inv.kw]`'s closed set
correctly stays at 50. Every other contextual word is in §6.2. The
measurement is in `docs/spec-findings-tl01.md`.

The suite grows 112 → 121 (seven `then` tests, the alias bound, the
bodiless member at the brace). All four gates are green: the committed
parser matches `grammar.js`, the suite is 121/121, the three query
files load, and wolf-lang's corpus parses at zero ERROR nodes over 546
`.lu` files at trunk `be348b9` (541 of 570 at the tag), 29 parse-tier
counter-examples excluded by directive. The floor ratchets 483 → 546.

## le08 — 2026-09-05 — five calls, and the grammar does nothing again

The `v0.2.4..v0.2.5` spec diff is two files, 168 added lines, zero
removed: `spec/11-os.md` (+163) and `spec/anchors.json` (+5). It asks
`grammar.js` for nothing. The sprint contract predicted that, and
`docs/spec-findings-le08.md` is the measurement that confirms it, taken
three ways.

s137's five clauses are five builtin functions:
`[os.net.listen.opts]` (`net_listen_with`), `[os.net.wait]`
(`net_wait`), `[os.proc.inherit]` (`os_spawn_with`,
`net_adopt_listener`) and `[os.cpus]` (`os_cpus`). `[os.proc]` is a
section header that declares no call. No new type name, keyword,
operator or literal form. Three independent limbs say so:
`spec/01-grammar.md` is absent from the diff, so `[gram.inv.kw]`'s
closed set stays at 50 and every production is byte-identical; the
reference compiler's `wolf_lex` and `wolf_parse` crates changed in
eight files, all `tests/snapshots/*.snap`, the four new witnesses'
snapshots, with no `src/` file in either crate, which a
release that added a token could not have done; and
`crates/wolf_sema/src/prelude.rs`'s `BUILTIN_TYPES` is byte-identical at
seventeen names. What grew is `PRELUDE`, the builtin function list.

This repo keeps no builtin-function list.
`queries/highlights.scm` paints calls structurally
(`(call_expression function: (identifier) @function)`), never by name, so
all five of s137's calls highlight correctly the moment they are written.
This is the second release running where the OS tier grew and this repo
did nothing. `grammar.js` unchanged, `queries/*.scm` unchanged.

le07's `char` finding is retired; it was measured through a path that
does not exist. le07 §2 recorded that `char` is "in NEITHER limb of the
compiler", citing `grep -rn '"char"' compiler` as empty. wolf-lang has no
`compiler/` directory at trunk, at `v0.2.4`, or at `v0.2.5`; the crates
live at `crates/`. A recursive grep of a nonexistent path returns nothing,
and that nothing was read as an absence. Measured correctly at both
pins: `char` is in `BUILTIN_TYPES` (fourth name in the literal) and
`Prim::Char` does exist (`crates/wolf_mem/src/ubcheck.rs`, three match
arms). le07's conclusion, keep `char` in `@type.builtin`, was right; its
reason was wrong, and "the mid-end has not landed `char`" is the
sentence a later sprint would have acted on. The two-limb test was re-run
correctly across the whole set: seventeen names in, seventeen out;
`usize`/`isize` still fail both limbs and stay struck.

All four gates are green at the v0.2.5 corpus: the committed parser
matches `grammar.js`, the suite holds at 112, the three query files
load, and wolf-lang's corpus parses at zero ERROR nodes over 507 `.lu`
files at trunk `6263ffa` (byte-identical at the tag), with the same 25
parse-tier counter-examples excluded by directive and 482 gated.
The floor ratchets 478 → 482. The four added files are
s137's four witnesses, all `phase: run`, so the exclusion count did not
move.

Known gap carried forward, unchanged: le07 §3's leading-BOM tolerance is
a tree-sitter RUNTIME behaviour this CI cannot assert through the
harness, and the harness disagrees with it. Do not "fix"
`grammar.js` to satisfy a harness failure on a leading BOM.

## le07 — 2026-09-03 — the byte asks nothing, the BOM asks once

The `v0.2.3..v0.2.4` spec diff is 158 added lines across five files and
asks `grammar.js` for nothing. That answer is measured;
`docs/spec-findings-le07.md` is the reading.

`[type.byte]` adds no syntax, and says so itself. spec §4b is 70
lines of typing (layout, casts, the widening operator rule, the
interpolation rule) and closes the grammar question in its own clause:
`byte` is a builtin type NAME, not a keyword, and `[gram.inv.kw]`'s
closed set stays at 50 (checked: the production is byte-identical across
the diff). Every spelling the clause rules is syntax this grammar has
parsed since le02: `List[byte]` is a generic type path, `65 as byte` a
cast, `b + 1` a binary expression whose parse never saw the operand
types, `{b:x}` the ordinary format spec. §4b writes "there is
no suffix inventory", so the one byte-tier shape that would have been a
lexer change (`65byte`) did not arrive. That was the thing le06 flagged
as possibly owed to le07 (`spec-findings-le06.md` §2), and it is owed no
longer. `byte` was already in `@type.builtin`; it stays.

The builtin list was re-checked, and `char` is the interesting one. The
le06 pass struck `usize`/`isize` on a two-limb conjunction: no
`spec/*.md` names them AND they are absent from the compiler's closed
set. Both limbs were re-run at v0.2.4. `byte` now passes both (it has
entered `wolf_sema`'s `BUILTIN_TYPES` and has a `Prim::Byte`) where le06
could only rest it on the spec. But `char` passes neither compiler limb:
`grep -rn '"char"' compiler` is empty at v0.2.4, no `Prim::Char`, not in
`BUILTIN_TYPES`. It stays in `@type.builtin` regardless, because the test
is a conjunction and `char` owns a whole spec section (`[type.char]`,
D58, 51 mentions). Recorded so a later sprint reading the compiler table
alone does not strike a type the language has: the mid-end has
not landed `char`; the language has it. `i16` and `uint` are the mirror
case (absent from the spec prose, present in the compiler) and stay for
the same reason.

D74's BOM rule is satisfied, and the harness reports a failure anyway.
`[gram.lex.source]` gained the one new sentence in the diff that reaches
the grammar's file start: a byte order mark at the very start is stripped
and never a diagnostic; anywhere else it is a stray character (E0107).
Those are two opposite behaviours for the same three bytes, and which one
you measure depends on the door:

- `tree-sitter parse <file>` (the CLI, Gate 4's door): leading BOM
  clean, root at `[0, 3]`; mid-file BOM `ERROR`. Correct.
- the C library over a buffer: leading BOM clean, mid-file
  `(ERROR (UNEXPECTED 65279))`. Correct, and this is the door that
  matters: nvim, helix and zed hand the parser a buffer, never a path,
  and D74 has the formatter keep the mark, so the buffer really does
  still start `EF BB BF`. Taken by compiling the committed
  `src/parser.c` + `src/scanner.c` against the `tree-sitter` crate.
- `tree-sitter test`: reports the leading BOM as
  `(ERROR (UNEXPECTED 65279))`. Wrong, because the harness does not
  perform the runtime's position-0 skip that both other doors do.

Three tests written to pin the leading-BOM tolerance therefore failed,
and the obvious fix (U+FEFF into `extras`, or an optional BOM token
opening `source_file`) would go green in the harness and break the
editors, because `extras` cannot distinguish position 0 and would make
a mid-file BOM trivia too, retiring E0107's half of D74 outright.
`grammar.js` is unchanged on purpose. What is pinned instead: the
mid-file half in the suite (a new `test/corpus/items.txt` case asserting
`(ERROR (UNEXPECTED 65279))`, beside the shebang tests, where all three
doors agree on that half), and the leading half by Gate 4, since
wolf-lang's `corpus/grammar/bom_at_start.lu` is a `phase: run` file with
a real `EF BB BF` prefix and is one of the gated 478.

`[os.net.unix]` adds no syntax either. `net_listen_unix` and
`net_connect_unix` are calls over plain identifiers, and this repo keeps
no builtin-FUNCTION list: `highlights.scm` paints calls structurally,
never by name, so the net tier's growth reaches it for free. The nine
`corpus/net/` files, `unix_echo.lu` included, parse clean.
`02-memory-model.md`'s edits are `List[int]` → `List[byte]` in prose.

All four gates are green at the v0.2.4 corpus: the committed parser
matches `grammar.js`, the suite holds at 112 (111 plus the mid-file BOM
case), the three query files load, and wolf-lang's corpus parses at zero
ERROR nodes over 503 `.lu` files at trunk `1323c4e`, with 25 parse-tier
counter-examples excluded by directive and 478 gated. The
floor ratchets 466 → 478. (The sprint contract predicted 511 `.lu`
files; the tree holds 503 at the tag and at trunk both, and the floor
follows the measurement.)

Known gap carried forward: the leading-BOM tolerance is a tree-sitter
RUNTIME behaviour this CI cannot assert through the harness, and the
harness disagrees with it. Do not "fix" `grammar.js` to satisfy
a harness failure on a leading BOM; see `docs/spec-findings-le07.md` §3.

## le06 — 2026-09-02 — two types wolf does not have

The `v0.2.2..v0.2.3` spec diff asks nothing of `grammar.js`, and the
re-reading found something in the query files instead.

`usize` and `isize` are gone from `@type.builtin`. They have been in
`queries/highlights.scm` since the first queries commit (le02,
`743b592`), unjustified there and unjustifiable now: no `spec/*.md` file
names either one at v0.2.3 (`grep -rn 'usize\|isize' spec/` is empty),
and neither is in the compiler's closed builtin set. Painting a name
`@type.builtin` tells a reader the language has that type, so this list
was teaching two types that do not exist, the same class of error
wolf-lsp#4 was, pointed the other way. `wrapping` takes their place:
D56's wrapping-arithmetic constructor (`wrapping[u32]`,
`[type.numlit.cast.wrap]`) is a real builtin type name and was the one
name in that set this list had never carried.

`byte` needed nothing, and waits on nothing. le06's contract asked
whether `byte` should join the list if wolf-lang s135 had merged by the
grammar step. Measured: s135 has not merged (trunk tops out at `5241ab7`,
the r06 release merge; there is no `origin/s135`), and `byte` has been in
this list since le02 and is a builtin at v0.2.3 regardless. There is
nothing to add and nothing to defer to le07; `docs/spec-findings-le06.md`
§2 has what le07 may owe if s135 lands byte-tier *syntax*.

wolf-lang#215 is closed, and the grammar was already right. The le05
findings filed `MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` as
named-and-undefined; v0.2.3 defines all three plus `SCALAR`, `NL`,
`MULTI_PART`, `MULTI_TEXT`, `HASH_FENCE`, `RAW_TEXT`,
`GENERALIZED_STRING`, `GEN_TEXT` and `CHAR_TEXT`. No grammar change
follows: `raw_string_literal` has had no `$.interpolation` child and
`generalized_string_literal` a flat immediate body since le02, read off
the prose, and `RAW_TEXT ::= SCALAR*` / `GEN_TEXT ::= (SCALAR - ('"' |
NL))*` say the same. The productions are now the vendored proof of
which reading was right, and wolf-lsp le06 used them to fix its
tmLanguage (wolf-lsp#4/#5).

All four gates are green at the v0.2.3 corpus: the committed parser
matches `grammar.js`, the suite holds at 111, the three query files
load, and wolf-lang's corpus parses at zero ERROR nodes over 486 `.lu`
files, with 20 parse-tier counter-examples excluded by directive and 466
gated. The floor ratchets 463 → 466. It tracks trunk rather than a tag,
because that is what the gate checks out; a floor left at a v0.2.2
measurement would let the gate lose three files' worth of coverage
without failing.

No known gaps carried forward.

## le05 — 2026-09-02 — the separator is the law

wolf-lang v0.2.2's grammar deltas reach the grammar, and le04's two
open items close with them.

D67 rules the pattern family. `closed_pattern`'s struct arm writes its
tail as `(',' '..'?)?`: `..` follows a separator like one more member.
`Point { x, .. }` and `Point { x, }` parse; `Point { x .. }` does not.
That last spelling was le04's whole known-gaps line. wolfgang accepted
it as an unlicensed recovery-loop accident, D67 ruled the production the
law, s131 landed the tightening, and the grammar follows at the pin.
`Point { x y }`, `(a b)` and `Some(a b)`, D67's other named laxities,
already ERRORed here; they get corpus cases now so the refusal shape is
pinned.

D69 covers literals, closures and captures. Three of the four already
held: `field_initializer_list`, `closure_parameters` and `capture_list`
have demanded the separator since le02. The fourth had an escape hatch,
and closing it is this entry's one structural change. `Point { x: 1 y: 2 }`
ERRORed, but the shorthand-only `Point { x y }` did not: it cannot be a
`struct_expression`, so GLR re-read `let p = Point { x y }` as
`let p = Point` followed by a bare block statement `{ x y }` holding two
unterminated expression statements, a clean tree where wolfc
reports E0201. So `block` now takes `[gram.lex.newline]` literally, which
is the spec's own letter: `block ::= '{' stmt*
expr? '}'` with `expr_stmt ::= expr TERM` and `let_item ::= … TERM`, so a
statement is terminated and the block's trailing expression is not. The
rescue dies at its second statement and the ERROR lands on the missing
separator. `source_file` needed nothing, because the rescue always goes
through a `block`. Measured against a 21-spelling battery of legal
one-liners, tail expressions, `;`-separated bodies, nested items
first/middle/last, `if`/`match`/`for` in both positions, bare block
statements and interleaved comments: all still parse.

STR_ESC arrives, and le04's flagged node with it. v0.2.2 closes le04's
own finding (wolf-lang#198) with le04's suggested fix verbatim:
`STR_PART` gains a `STR_ESC` alternative, and
`CHAR_ESC ::= STR_ESC | '\' "'"` derives the char set from the string
set instead of restating it. That makes the string escape set a
*production* rather than a prose bullet ("and nothing else; any other
`\` is E0101 at the escape"), which is what le04 was waiting for. So
`escape_sequence` narrows to `STR_ESC`, and everything it no longer
derives lexes as a new `invalid_escape` node, painted `@error`. The le04
findings measured why it has to be a node: bounding
the old permissive token yielded no ERROR at all (its `.` catch-all made
`"\u{0000041}"` lex as `\u`, after which `{0000041}` re-entered
interpolation mode and grew a fake `(interpolation (integer_literal))`
where an escape stood), and an ERROR node would throw away the rest of an
otherwise fine literal while `locals.scm`/`injections.scm` read tree
shape. `invalid_escape` keeps the shape (one escape token where one
escape stands) and covers the over-long and zero-digit
`\u{…}`, `\xH`, `\q`, and `\'`, which is a char literal's escape alone.
`char_literal` needed no change; its token already carried
`STR_ESC` plus `\'`. This is a new node in the public surface, and
wolf-lsp's inventory takes it at this same pin.

`region_cap` is a fourth delta, and the gate is what found it. It was
not in this sprint's brief; the corpus gate refused to go green without
it. v0.2.2 splits `region_expr`'s sugar in two and adds a creation-time
byte budget (`region_cap ::= 'cap' ':' expr`, s132,
`[mem.region.cap.1]`), making `cap` a third contextual keyword beside
`rc` and `pool`. The spec says why the sugar is split: on the sugar form
the cap parenthesis follows the NAME, so an anonymous sugar block takes
no cap, because `region (cap: n)` is already the value form. Three
corpus files exercise it (`conc/proc_cap_fault_join.lu`,
`faults/region_cap_breach.lu`, `memory/region_cap_boundary.lu`), and
they were the entire ERROR set before the rule landed.

The corpus suite grows 104 → 111 cases (the four D67/D69
refusal shapes, the region-cap forms, and the string-escape set rewritten
now that the bound binds inside `"…"` too). The wolf-lang trunk-corpus
gate was re-measured at v0.2.2, where the corpus is byte-identical at the
tag and at trunk `4d9683d`, 482 `.lu` files: 463 files gated, 19
parse-tier counter-examples excluded by directive, zero ERROR nodes. The
pass-count floor ratchets 454 → 463.

One finding in `docs/spec-findings-le05.md`, filed as wolf-lang#215:
`MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` are named in
`spec/grammar.ebnf` and defined nowhere in it, the same class of gap
#198 just closed, one literal over. It bit immediately: deciding whether
`invalid_escape` belongs inside a `"""` literal had to be read off a
contrast between three prose bullets, because `[gram.lex.str.raw]` and
`[gram.lex.str.gen]` exclude escapes outright while `[gram.lex.str.multi]`
says only that interpolation works. The silence is read as "escapes
work", since the forms that exclude them say so, and `invalid_escape`
joins `escape_sequence` there, as it has been since le02.

Known gaps: none carried forward. le04's D67 line closes here.

## le04 — 2026-09-01 — the escape gets a bound

A small catch-up: wolf-lang v0.2.1's grammar deltas reach the
grammar. The spec diff `83f83bb..v0.2.1` is three files and one
substantive change: r04 closed le03's own finding (wolf-lang#189) at
the measured letter, so `CHAR_ESC`'s `HEX_DIGIT+` is gone and a named
`UNI_ESC` bounds the `\u{…}` escape at one to six hex digits. The
bound is on the escape's SHAPE rather than the value it names: leading
zeros count, so `'\u{000041}'` is `'A'` and `'\u{0000041}'` is E0101
before anything asks what it spells.

`char_literal` takes the bound. A tree-sitter grammar has no refusal,
but here it has the next best thing: nothing else starts with `'`, so
seven digits leave an ERROR node where wolfc reports, and
`test/corpus/chars.txt` pins that shape alongside the in-bounds
one-through-six sweep. (The zero-digit half, `'\u{}'`, was already
outside the token.)

The string half is noted and not encoded. v0.2.1's prose says
the bound binds inside `"…"` too, and measured at le04, bounding the
`escape_sequence` token there produces no ERROR: its last alternative is
a `.` catch-all, so `"\u{0000041}"` would lex as `\u` and then re-enter
interpolation mode on `{0000041}`, growing a plausible-looking
`(interpolation (integer_literal))` where an escape stood. Changing the
tree's SHAPE is a worse lie than a permissive token, since `locals.scm`
and `injections.scm` read shape, so the digit count stays unbounded
inside a string and `test/corpus/strings.txt` records what the grammar
does. Encoding it wants a distinct `invalid_escape` node
painted `@error`, which is a new public node and a downstream change in
wolf-lsp. It is flagged and not taken.

The wolf-lang trunk-corpus gate was re-measured at v0.2.1 (trunk
`e6548a9`; the corpus grew to 467 `.lu` files): 454 files gated, 13
parse-tier counter-examples excluded by directive, zero ERROR nodes. The
pass-count floor ratchets 443 → 454. The one over-long escape in the
whole corpus lives in `corpus/grammar/char_uni_seven_digits.lu`, which
is a `check: fail(E0101)` counter-example and therefore excluded, so the
bound costs the gate nothing.

Two findings in `docs/spec-findings-le04.md`: `UNI_ESC` is named but
wired only into `CHAR_ESC`, so `STR_PART` still derives no escapes at
all while the prose asserts the bound binds there (suggested fix: a
`STR_ESC` alternative); and the recorded limit above, so the next reader
does not "fix" the string half. `[mem.model.order]`'s D66 amendment (the
third file in the diff) is purely semantic and needs nothing here.

Known gaps: D67 (ruled 2026-09-01) makes pattern separators
required, with `','` separating fields and `'..'` following a separator
like one more member, and wolf-lang's s131 lands the wolfgang tightening
on trunk this wave. This grammar is not changed for it:
the editors take it at their next pin (le05-era), so until then
`Point { x .. }` still parses here and will start refusing under a
future `wolfc`. The exposure is that one spelling, `struct_pattern`'s
`optional(',')` before `rest_pattern`; `Point { x y z }` and `(a b)`,
the other wolfgang laxities D67 names, already ERROR here. D67 names
wolf-lang#190 as its tracker, but that issue is CLOSED (`COMPLETED`,
2026-09-01, seconds after the v0.2.1 release draft, most likely a merge
message), so the tracker D67 points at is not open. Flagged on
the issue, which stays closed.

## le03 — 2026-08-31 — the grammar catches up

The le02 known-gaps line closes: re-read at wolf-lang `83f83bb`
(v0.2.0+s129), the grammar gains char literals (`[gram.lex.char]`,
D58: one scalar or escape between single quotes, the `'\u{…}'`
unprintable spellings included; `@constant.character`), D63 binder
comma groups (`[gram.item.let]`: let/var take `binder (',' binder)*`;
the tree gains a `binder` node and the locals queries follow), and
struct patterns (`[gram.pat.struct]`: `Point { x, y: p, .. }` with
shorthand, nesting, and a `rest_pattern` node). str-`+` (D62) needed
nothing: the expression rules never typed `+`. Twelve corpus cases
across three files; every recorded tree re-checked under the binder
reshape.

The wolf-lang trunk-corpus gate goes 17 failures → 0 (the
contract's 8 char-era files had grown by s129's D63 and
struct-pattern witnesses): 443 files parse at zero ERROR nodes, and
the gate gains a pass-count floor (443) so a shrunken checkout cannot
go green by parsing nothing. One gate fix rode along: a deliberately
unparseable *member* of a directory-module counter-example
(`resolve/broken_sibling/mangled.lu`) is now excluded by its
`entry.lu`'s own parse-tier directive; still by directive, never by
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
an independent reading of wolf-lang's `spec/01-grammar.md`, with the
compiler's parser left unread. The full surface: items,
the §3.2 precedence climb, `[]` generics, regions, traits and `dyn`,
row patterns, call-site `f(mut x)`, newline termination per
`[gram.lex.newline]`; an external scanner owns `"""` multiline strings
and raw `#`-fences; f-strings are modelled, so `{expr}` in
any string literal is a real expression subtree. `queries/` ships
highlights, locals and injections (C into `unsafe c` bodies, regex
into `re"…"`); an 84-case corpus suite and a CI gate that parses
wolf-lang's whole corpus at zero ERROR nodes. Four spec-silence
findings drafted for upstream (`docs/spec-findings-le02.md`).

Known gaps: char literals (`[gram.lex.char]`, D58) postdate the
grammar's spec reading, so `'a'` is not a token here yet and the
grammar has no `char` type keyword; the corpus gate's pin predates the
char-era witnesses.

## The scaffold — 2026-08-09 → 08-12

A seed with the port to follow opportunistically: a scaffold
gate in CI that arms itself when `grammar.js` arrives (r01 audit row
10; the grammar then lived vendored in wolf-lsp), the license settled
to GPL-3.0-or-later (D41 as amended), and a prose pass correcting
stale claims. No grammar shipped in this span, and the README said so.
