# le03 spec findings — where the grammar spec is silent

The le03 catch-up re-read the spec at wolf-lang `83f83bb` (v0.2.0+s129)
and landed char literals (`[gram.lex.char]`, D58), D63 binder comma
groups (`[gram.item.let]`), and struct patterns (`[gram.pat.struct]`).
Per the le02 pattern (`spec-findings-le02.md`), silences met during the
reading are recorded here rather than settled by peeking at the
compiler's parser; each is filed upstream.

## 1. `'\u{…}'` digit count: the EBNF and the prose disagree

Filed: wolf-lang#189.

`[gram.lex.char]` gives `CHAR_ESC ::= … | '\u{' HEX_DIGIT+ '}'` —
unbounded — while the same section's prose says "`\u{…}` takes one to
six hex digits". `'\u{0000000041}'` is derivable from the production
and refused by the prose; nothing says which text is normative, and
E0110's malformed-shape list names neither a digit-count case nor
leading zeros.

tree-sitter-wolf follows the EBNF permissively (`HEX_DIGIT+`); a
digit-count refusal, if intended, is sema's.

Suggested fix: either bound the production (`HEX_DIGIT HEX_DIGIT?
HEX_DIGIT? HEX_DIGIT? HEX_DIGIT? HEX_DIGIT?` or a prose-side "the
production is bounded by the prose") or strike "one to six" and let
the non-scalar rule do the refusing (any value above `0x10FFFF` is
already E0110, which makes seven-plus significant digits refuse
themselves — only leading zeros stay undecided).

## 2. Struct patterns: is the comma before `..` optional?

Filed: wolf-lang#190.

`[gram.pat.struct]` derives
`path '{' field_pat (',' field_pat)* ','? '..'? '}'` — the comma
before `..` rides the optional trailing comma, so `Point { x .. }`
(no separator) is derivable alongside `Point { x, .. }`. Every worked
example in the clause and the fmt canonical form (`Point { x, y: p,
.. }` per s129's fmt commit) writes the comma; nothing says whether
the comma-less spelling parses, and E0814's shape list (missing /
duplicate / empty) does not cover it.

tree-sitter-wolf follows the production as written: the comma before
`..` is optional.

Suggested fix: one word either way — `',' '..'` if the comma
separates (making the production `(',' field_pat)* (',' '..'?)? '}'`
in spirit), or an explicit note that `..` needs no separating comma.
