# le05 spec findings — the separators, and the string literal's silence

le05 re-read the spec diff `v0.2.1..v0.2.2` (`spec/grammar.ebnf`,
`spec/01-grammar.md`). Per the le02/le03/le04 pattern, silences met
during the reading are recorded here rather than settled by peeking at
the compiler's parser.

## 0. Three earlier findings, closed at v0.2.2

**wolf-lang#198 — CLOSED, and the grammar follows.** le04 recorded that
`UNI_ESC` was named but wired only into `CHAR_ESC`, so a reader working
from `spec/grammar.ebnf` alone derived *no escapes at all* for `"…"`
while the prose asserted the one-to-six bound bound there. v0.2.2 takes
le04's suggested fix verbatim:

```ebnf
STR_PART   ::= STR_TEXT | STR_ESC | '{{' | '}}' | INTERP
STR_ESC    ::= '\' ('n' | 't' | 'r' | '0' | '\' | '"') | '\x' HEX_DIGIT HEX_DIGIT | UNI_ESC
CHAR_ESC   ::= STR_ESC | '\' "'"
```

`CHAR_ESC` now derives the char set from the string set instead of
restating it, which is exactly the claim `[gram.lex.char]` used to make
in prose. `grammar.js` takes both halves — see finding 1.

**D67 — taken.** le04's known-gaps line said `Point { x .. }` still
parsed here and would start refusing under a future `wolfc`. v0.2.2's
`closed_pattern` writes the tail as `(',' '..'?)?` and s131 landed the
wolfgang tightening, so the grammar follows: `..` follows a separator
like one more member.

**D69 — taken.** The separator is required between struct-literal
fields, closure parameters and capture-list names. Three of the four
already ERRORed here; the fourth needed a second change (finding 2).

## 1. `invalid_escape` — le04's flagged node, taken

le04 measured that bounding `escape_sequence` alone produces no ERROR
inside a string: the old token's last alternative was a `.` catch-all,
so `"\u{0000041}"` lexed as `\u` and `{0000041}` re-entered
interpolation mode, growing a plausible-looking
`(interpolation (integer_literal))` where an escape stood. le04 flagged
the honest encoding — a distinct node painted `@error` — and declined
to take it, because it adds a node to the public surface and a
downstream change in wolf-lsp.

le05 takes it, because v0.2.2 is the release that makes the string
escape set a *production* rather than a prose bullet: `STR_ESC` derives
it or it does not exist, and `[gram.lex.str.escape]` now says outright
"and nothing else; any other `\` is **E0101** at the escape". So the
grammar splits the token in two:

- `escape_sequence` — exactly `STR_ESC`: `\n \t \r \0 \\ \"`, `\xHH`,
  and `\u{…}` at one to six hex digits.
- `invalid_escape` — everything else, as one token: the over-long and
  zero-digit `\u{…}`, `\xH`, `\q`, and `\'` (a char literal's escape
  alone — the prose names it E0101 inside `"…"` like any other unknown
  escape).

The `u\{…\}` alternative is listed first on purpose so an over-long
escape is eaten whole and nothing re-enters interpolation mode.
`invalid_escape` is a NEW node in the public surface; wolf-lsp's node
inventory takes it at this same pin.

`char_literal` needed no change: its token already carried exactly
`STR_ESC` plus `\'`, which is what `CHAR_ESC` now says.

## 2. Where D69's struct literal had an escape hatch

Not a spec silence — a port note, and the reason `block` changed.

`field_initializer_list` has demanded the separator since le02, so
`Point { x: 1 y: 2 }` ERRORed here before D69 was written. But the
shorthand-only spelling did not. `let p = Point { x y }` cannot be a
`struct_expression`, so GLR re-read it as `let p = Point` followed by a
bare block statement `{ x y }` holding two unterminated expression
statements — a clean tree, no ERROR, exactly where wolfc reports E0201.
That is the same class of lie le04 refused for the string escape: a
plausible shape standing where a refusal belongs.

The fix is the spec's own letter, not a special case. `block ::= '{'
stmt* expr? '}'` with `expr_stmt ::= expr TERM`, `let_item ::= … TERM`,
`assign_stmt ::= … TERM`: a statement is terminated, the block's
trailing expression is not. `block` now requires the TERM, which kills
the rescue at its second statement and puts the ERROR on the missing
separator. Measured: 111/111 corpus cases, 463 wolf-lang corpus files at
zero ERROR nodes, and a 21-spelling battery (one-line bodies, tail
expressions, `;`-separated one-liners, nested items first/middle/last,
`if`/`match`/`for` as statement and as tail, bare block statements,
comments between statements) all still parse.

`source_file` was left alone: it needs no change, because the rescue
reading goes through a `block` wherever it appears.

## 3. `region_cap` — a v0.2.2 grammar delta, found by the gate

Not a silence either, but recorded because it was not in le05's brief
and the corpus gate is what surfaced it.

v0.2.2 splits `region_expr`'s sugar in two and adds a creation-time byte
budget (`region_cap ::= 'cap' ':' expr`, s132, `[mem.region.cap.1]`),
making `cap` a third contextual keyword alongside `rc` and `pool`. Three
corpus files exercise it — `conc/proc_cap_fault_join.lu`,
`faults/region_cap_breach.lu`, `memory/region_cap_boundary.lu` — and
they were the whole of the gate's ERROR set before the rule landed. The
sugar split is load-bearing and the spec says why: the cap parenthesis
follows the NAME, so an anonymous sugar block takes no cap, because
`region (cap: n)` is already the value form.

## 4. `MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` have no productions

Filed: wolf-lang#215.

The same class of gap #198 just closed, one literal over. In
`spec/grammar.ebnf`:

```ebnf
literal ::= INT | FLOAT | CHAR_LIT | STRING | MULTILINE_STRING | RAW_STRING
```

`MULTILINE_STRING` and `RAW_STRING` are named there and **defined
nowhere in the file**; `STR_TEXT`, one of `STR_PART`'s four
alternatives, is likewise never defined. A reader working from the
grammar file alone — which is what this port is — derives nothing at all
for two of the six literal forms.

This matters now rather than in the abstract, because le05 had to decide
where `invalid_escape` goes. `[gram.lex.str.raw]` says raw literals take
"no escapes, no interpolation" and `[gram.lex.str.gen]` says generalized
literals have a "raw-mode body (no escapes/interpolation)" — both
outright. `[gram.lex.str.multi]` says the dedent rule, the delimiter
rule, and "Interpolation works inside", and says **nothing about
escapes**. Read against the two neighbours that do say it, the silence
reads as "escapes work" — the two forms that exclude them say so, and
this one does not. That is the reading taken: `escape_sequence` has been
inside `multiline_string_literal` since le02, and `invalid_escape` joins
it there.

Suggested fix: give `MULTILINE_STRING` a production in terms of
`STR_PART` (which would state the escape answer as a derivation rather
than leave it to a contrast between three prose bullets), and give
`RAW_STRING` and `STR_TEXT` productions of their own.
