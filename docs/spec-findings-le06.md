# le06 spec findings — the type list, and the productions that arrived

le06 re-read the spec diff `v0.2.2..v0.2.3` (`spec/grammar.ebnf`,
`spec/01-grammar.md`, `spec/10-types.md`). Per the le02–le05 pattern,
silences met during the reading are recorded here rather than settled by
peeking at the compiler's parser — with one deliberate exception, marked
where it happens, because the question le06 was sent to answer is about
a CLOSED SET and the spec does not publish one.

## 0. wolf-lang#215 — CLOSED at v0.2.3, and the grammar was already right

le05 recorded that `MULTILINE_STRING`, `RAW_STRING` and `STR_TEXT` were
**named in `grammar.ebnf` and defined nowhere in it**: a reader working
from the extracted grammar alone could derive no body for any of the
three. v0.2.3 defines all of them, and adds `SCALAR`, `NL`, `MULTI_PART`,
`MULTI_TEXT`, `HASH_FENCE`, `RAW_TEXT`, `GENERALIZED_STRING`, `GEN_TEXT`
and `CHAR_TEXT` beside them:

```ebnf
SCALAR ::= /* any one Unicode scalar value */
NL     ::= /* U+000A */
STR_TEXT   ::= (SCALAR - ('"' | '\' | '{' | '}' | NL))+
MULTILINE_STRING ::= '"""' MULTI_PART* '"""'
MULTI_TEXT ::= ((SCALAR - ('\' | '{' | '}'))+) - (SCALAR* '"""' SCALAR*)
RAW_STRING ::= 'r' HASH_FENCE '"' RAW_TEXT '"' HASH_FENCE
RAW_TEXT   ::= SCALAR*
GENERALIZED_STRING ::= IDENT '"' GEN_TEXT '"'
GEN_TEXT ::= (SCALAR - ('"' | NL))*
CHAR_TEXT ::= SCALAR - ("'" | '\' | NL)
```

**No grammar change follows**, and that is the finding worth writing
down. `grammar.js` read those four literal forms off the prose in le02
and has modelled them this way ever since: `raw_string_literal` is
`_raw_string_start · string_content · _raw_string_end` with no
`$.interpolation` child, and `generalized_string_literal`'s body is one
flat `token.immediate(/[^"\r\n]+/)`. `RAW_TEXT ::= SCALAR*` and
`GEN_TEXT ::= (SCALAR - ('"' | NL))*` say exactly that: no INTERP
alternative in either. An independent reading of the prose and the
productions written three sprints later agree without contact.

This mattered downstream this sprint. wolf-lsp's tmLanguage generator
had the opposite reading — both raw forms included `#interpolation`, so
`r"C:\logs\{today}\wolf.log"` painted `{today}` as a hole (wolf-lsp#4).
The productions above are now the vendored proof of which reading was
right; the fix ships in wolf-lsp le06.

## 1. `usize` and `isize` are not wolf types, and this repo painted them

`queries/highlights.scm` has carried

```scheme
"f32" "f64" "bool" "str" "byte" "usize" "isize" "char"
```

since the first queries commit (le02, `743b592`). Nothing in this
repository has ever justified those two names, and re-reading for them
this sprint found nothing to justify them with:

* **No `spec/*.md` file names `usize` or `isize`.** Measured at v0.2.3:
  `grep -rn 'usize\|isize' spec/` returns nothing. `spec/10-types.md`
  writes `i32`, `f64`, `u64`, `char`, `wrapping[T]`; it never writes a
  pointer-width integer of either sign.
* **The compiler's closed builtin set does not carry them.** This is the
  deliberate exception to the no-peeking rule, and it is narrow: the
  question is whether a NAME is in a closed set, not how anything parses,
  and `spec/10-types.md` says outright that "the real inventory is spec
  02's" — a spec section that does not exist yet. At v0.2.3
  `wolf_sema::prelude::BUILTIN_TYPES` is `bool str byte char int uint i8
  i16 i32 i64 u8 u16 u32 u64 f32 f64 wrapping` — seventeen names, and
  neither `usize` nor `isize` among them.

They are Rust-isms that rode in with a hand-written list. Painting a
name `@type.builtin` tells a reader the language has that type; these
two told them wolf has two types it does not. That is the same class of
error wolf-lsp#4 was — a highlighter asserting a language fact that is
not true — pointed the other way, and le06 removes them.

`wrapping` joins the list in their place: D56's wrapping-arithmetic
constructor is a real builtin type name (`wrapping[u32]`,
`[type.numlit.cast.wrap]` in `spec/10-types.md`), it is in the closed set
above, and it was the one name in that set this list had never carried.

## 2. `byte`: nothing is owed, and nothing waits on s135

le06's contract asked whether `byte` should join the type names *if*
wolf-lang s135 had merged by the grammar step. Measured 2026-09-02:

* **s135 has not merged.** `git log origin/trunk` tops out at `5241ab7`
  (the r06 release merge); there is no `origin/s135` branch, and no
  `byte`-tier work in the log below it.
* **`byte` is already in this list, and already correct.** It has been
  in `highlights.scm` since le02 and it is in `BUILTIN_TYPES` at v0.2.3.

So there is no `byte` change to make and none to defer. Whatever s135
does to the byte tier, `byte` is a builtin type name today and this line
does not wait on it. What le07 may owe is different and larger: if s135
introduces byte-tier *syntax* (a literal form, a slice spelling), that is
a `grammar.js` question, not a query-file one.

## 3. `Self` — deliberately not in the builtin list

wolf-lsp's tmLanguage paints `Self` with the type scope, so the two
engines' lists differ by it. That difference is correct rather than
drift. `Self` is not a builtin type NAME — it is a context-bound alias,
legal only inside a trait or an impl — and a regex grammar has no way to
express that condition, so it lists the word. This grammar can see
context: `Self` in type position already paints through `(type_path
(path (identifier)) @type)`, and adding it to the `#any-of?` builtin set
would paint it as a builtin scalar in positions where it is not a type
at all.

Recorded here rather than filed: it is a property of the two engines'
different powers, the same reason `cap`/`rc`/`pool` diverge
(`[gram.inv.ctx]`, contextual keywords), which wolf-lsp#5 also
declined to file.

## 4. The corpus floor, re-measured

482 `.lu` files at v0.2.2, 486 at v0.2.3 / trunk `5241ab7`. Twenty are
parse-tier counter-examples excluded by directive, so the gate parses
**466** files at zero ERROR nodes, and the floor ratchets 463 → 466. The
gate checks out wolf-lang's default branch rather than a tag, so the
floor tracks trunk: leaving it at a v0.2.2 measurement would let the gate
quietly lose three files' worth of coverage, which is the exact failure
the ratchet exists to prevent.

No new ERROR nodes, and no grammar change was needed to reach zero at the
new corpus.
