# le04 spec findings — the escape's bound, and where it does not reach

The le04 catch-up re-read the spec diff `83f83bb..v0.2.1` (three files:
`spec/grammar.ebnf`, `spec/01-grammar.md`, `spec/02-memory-model.md`).
Per the le02/le03 pattern, silences met during the reading are recorded
here with the compiler's parser left unread.

## 0. Two le03 findings, re-read at v0.2.1

wolf-lang#189 is CLOSED, and the grammar follows. The le03 finding
recorded that `CHAR_ESC` wrote `HEX_DIGIT+` while the prose said "one to
six hex digits", with nothing naming which text was normative. The r04
release measured the lexer and ruled the prose the letter: the
production is amended to a named `UNI_ESC` with one to six
`HEX_DIGIT`s, and the bound is on the escape's SHAPE rather than the
value it names, so leading zeros count and `'\u{000041}'` is `'A'` while
`'\u{0000041}'` is E0101 before anything asks what it spells.
`grammar.js` follows in the char literal; see finding 1 for the half it
cannot follow.

wolf-lang#190, the comma before `..` in a struct pattern, is ruled and
its tracker is CLOSED. r04's probe found the machines disagree (wolfgang
accepts the comma-less spellings, lupin refuses per the production's
letter), and the spec sentence was backed out of the patch release,
since the fix had not shipped. D67 has since ruled: the production is
the law, separators are required, and `..` follows a separator like one
more member. tree-sitter-wolf is not acted on here at le04; see the
CHANGELOG's known-gaps line. Note that D67 names #190 as the tracker for
the wolfgang tightening while the issue is CLOSED (`COMPLETED`,
2026-09-01); that is flagged on the issue, which stays closed.

## 1. `UNI_ESC` is named but only wired into `CHAR_ESC`

Filed: wolf-lang#198.

v0.2.1's prose makes a new cross-reference claim: the one-to-six bound
"is the production's, and it **binds in string literals too**
(`[gram.lex.str.escape]`)". The production side does not carry that
claim. In `spec/grammar.ebnf` the string productions are

```ebnf
STRING     ::= '"' STR_PART* '"'
STR_PART   ::= STR_TEXT | '{{' | '}}' | INTERP
```

`STR_PART` has no escape alternative at all: not `\n`, not `\x41`,
not `UNI_ESC`. The new `UNI_ESC` non-terminal is reachable only from
`CHAR_ESC`, so a reader working from the grammar file alone derives the
bound for `'…'` and derives *no escapes whatsoever* for `"…"`, while
the prose says the bound binds in both. (The escape set for strings
lives only in `[gram.lex.str.escape]`'s prose bullet: "Escapes: `\n \t
\r \\ \" \0 \x7f \u{1F43A}`".)

The gap predates v0.2.1 (`STR_PART` never listed escapes), but v0.2.1
is the first release whose prose asserts a production-level bound
crossing into it.

Suggested fix: give `STR_PART` a `STR_ESC` alternative and define it in
terms of the escape set plus `UNI_ESC`, mirroring `CHAR_ESC`:

```ebnf
STR_PART   ::= STR_TEXT | STR_ESC | '{{' | '}}' | INTERP
STR_ESC    ::= '\' ('n' | 't' | 'r' | '0' | '\' | '"') | '\x' HEX_DIGIT HEX_DIGIT | UNI_ESC
```

which also lets `[gram.lex.char]`'s "the escape set is the string set
plus `\'`" be read off the productions instead of asserted in prose.

## 2. Where the grammar cannot encode the bound, and why

This one is a limit of this port, recorded so the next reader does not
"fix" it.

The bound is encoded in `char_literal`: no other token starts with `'`,
so a seven-digit escape leaves an ERROR node where wolfc reports
E0101 (`test/corpus/chars.txt`, "seven hex digits is not a char
literal"). The zero-digit half (`'\u{}'`) was already outside the token.

The bound is not encoded in `escape_sequence` (strings). Measured at
le04: bounding that branch to `{1,6}` does not yield an ERROR, because
the token's last alternative is a `.` catch-all (the escape set is
permissive there on purpose; `\q` belongs to sema). `"\u{0000041}"`
would then lex as `\u` via the catch-all, after which `{0000041}`
re-enters interpolation mode and the tree gains a plausible-looking
`(interpolation (integer_literal))` where an escape stood. That changes
the tree's SHAPE, and `locals.scm`/`injections.scm` read shape, which
makes it a worse lie than the permissive token. So the digit count stays
unbounded inside `"…"`, with the corpus recording what the grammar does
(`test/corpus/strings.txt`, "the `\u{…}` digit bound is NOT encoded
inside a string").

Encoding it needs a distinct node, an `invalid_escape` token matching
the over-long shape and painted `@error`, which adds a node to the
public surface and a downstream change in wolf-lsp's queries and node
inventories. It is flagged here and not taken at le04.

## 3. `[mem.model.order]` (D66) — no grammar surface

The third file in the diff amends `defer`/`errdefer` to run at scope
exit rather than as the frames return, LIFO with `[mem.shared.drop.1]`'s
drops, and names the loop-body case. The change is purely semantic:
`defer` and `errdefer` are already tokens here and their syntax is
untouched. Recorded so the diff is accounted for line by line.

## 4. Two findings outside the grammar, filed from the wolf-lsp half

Recorded here so this sprint's upstream reports are in one place.

- wolf-lang#199: D57's version string is clone-dependent.
  `xtask`'s `git_short_sha()` runs `git rev-parse --short` with git's
  auto abbreviation, which just grew from seven to eight characters in
  a full clone, so `wolf --version` at `v0.2.1` prints
  `pin 75fd2d0b` where the same commit in a smaller clone would print
  `pin 75fd2d0`. wolf-lsp's PIN records the string verbatim and
  `doctor` refuses any mismatch.
- wolf-lang#200: the `v0.2.0` and `v0.2.1` GitHub releases are
  DRAFTS with tier-1 assets uploaded. Only `v0.1.0` is published, so
  every downstream "acquire the pinned artifact" lane is still dark;
  the asset is now unpublished where it used to be absent.
