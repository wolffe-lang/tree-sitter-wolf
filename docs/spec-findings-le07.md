# le07 spec findings — the byte asks nothing, the BOM asks once

le07 re-read the spec diff `v0.2.3..v0.2.4` — `spec/01-grammar.md`,
`spec/02-memory-model.md`, `spec/10-types.md`, `spec/11-os.md`,
`spec/anchors.json`. Five files, 158 lines added. The sprint's question
was which of those lines add SYNTAX. The answer is measured below and it
is **one line, and even that one is already satisfied** — but the
measurement that proves it had to be taken through the right door, and
the wrong door gives the opposite answer. §3 is the part worth keeping.

## 0. The three new anchor families, and what each asks of the grammar

`spec/anchors.json` gains six anchors in three families:

| family | anchors | grammar? |
| --- | --- | --- |
| `[type.byte]` | `.cast`, `.interp`, `.op` | **no** |
| `[os.net]` | `.unix` | **no** |
| `[gram.lex.source]` (no new anchor; the prose changed) | — | **no**, and §3 says why that took work to establish |

`[gram.lex.str.multi]`'s D74 rewrite also changed no anchor and no
production.

## 1. `[type.byte]` — a builtin type NAME, and the spec says so in the clause

`spec/10-types.md` §4b is 70 new lines and every one of them is typing,
not parsing. The clause settles it in its own words:

> `byte` is a builtin type NAME resolved in type position like `int` and
> `char`, not a keyword: `[gram.inv.kw]`'s closed set stays at 50.

The reserved-keyword production in `spec/01-grammar.md` §6.1 is
byte-identical across the diff and still checksums 50. Everything §4b
rules is spelled in syntax the grammar has parsed since le02:

- `List[byte]` is a generic type path — `byte` is an `identifier` under
  a `type_path`, no different from `List[int]`.
- `0 as byte`, `b as int`, `b as int as char` are `cast_expression`s.
- `[type.byte.op]`'s "every operator widens to `int`" is a typing rule
  over `binary_expression` — the parse of `b + 1` never depended on the
  operand types.
- `[type.byte.interp]`'s `{b:x}` is the ordinary format spec
  (`[gram.amb.fmtcolon]`), already parsed.
- **No literal suffix.** §4b is explicit: "there is no suffix inventory;
  `65 as byte` is the spelling". A suffix WOULD have been a lexer change
  (`65byte`), and it is the one shape of byte-tier syntax le06 flagged
  as the thing le07 might owe (`spec-findings-le06.md` §2). It did not
  arrive. Nothing is owed.

`queries/highlights.scm` already carries `byte` in the `@type.builtin`
set — since le02, re-checked at le06, correct at v0.2.4. No query change.

## 2. The builtin list re-checked against the compiler's closed set

le06 struck `usize`/`isize` on a two-limb test: **no `spec/*.md` names
them AND they are not in the compiler's closed builtin set.** le07 re-ran
both limbs at v0.2.4, because a type-tier release is exactly when that
list drifts.

`compiler/crates/wolf_sema/src/prelude.rs`'s `BUILTIN_TYPES` at v0.2.4
holds sixteen names:

```
bool str byte int uint i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 wrapping
```

Two readings follow, and both leave the query file alone:

- **`byte` is now in the compiler's set**, with a `Prim::Byte` beside it
  in `wolf_sema/src/types.rs`. le06 kept `byte` on the spec limb alone
  ("it is a builtin at this tag already"); at v0.2.4 both limbs carry it.
  The le06 line in `highlights.scm` that says this list "does not wait
  on" s135 is now retired by events rather than revised.
- **`char` is in NEITHER limb of the compiler.** `grep -rn '"char"'
  compiler` is empty at v0.2.4: there is no `Prim::Char`, and `char` is
  not in `BUILTIN_TYPES`. It stays in `@type.builtin` anyway, and this is
  not an oversight — it passes the SPEC limb overwhelmingly (`[type.char]`
  is its own §4, D58, 51 mentions across `spec/*.md`), and le06's test is
  a conjunction: a name goes only when spec AND compiler are both silent.
  Recording it here so a future sprint reading `BUILTIN_TYPES` alone does
  not strike a type the language plainly has. **The mid-end has not
  landed `char`; the language has it.**
- `i16` and `uint` are the mirror case — zero mentions in `spec/*.md`,
  but both in the compiler's closed set. Same conjunction, same answer:
  they stay.

## 3. `[gram.lex.source]` — D74's BOM rule, and the door you measure through

This is the one new sentence that reaches the grammar's file start:

> A byte order mark at the very start of a file is stripped and is never
> a diagnostic (D74 — tolerated, kept in place by the formatter);
> anywhere else it is a stray character (E0107).

Two behaviours are asserted, and they are opposite behaviours for the
same three bytes. wolf-lang carries the witness at
`corpus/grammar/bom_at_start.lu` — a `phase: run` file (so the corpus
gate **includes** it, it is not a parse-tier counter-example) whose first
three bytes are `EF BB BF`.

**The measurement, through three doors:**

| door | leading BOM | mid-file BOM |
| --- | --- | --- |
| `tree-sitter parse <file>` (CLI, Gate 4's door) | clean, root at `[0, 3]` | `ERROR` |
| **`ts_parser_parse` over a buffer (the C library)** | **clean** | **`(ERROR (UNEXPECTED 65279))`** |
| `tree-sitter test` (the suite harness) | **`(ERROR (UNEXPECTED 65279))`** | `(ERROR (UNEXPECTED 65279))` |

The C library row was taken by compiling this repo's committed
`src/parser.c` + `src/scanner.c` against the `tree-sitter` crate and
parsing `&str` buffers directly. **That row is the one that matters**,
because it is the door every consumer of this grammar uses: nvim, helix
and zed hand the parser a BUFFER, never a path — and D74 says the
formatter KEEPS the mark in place, so the buffer really does still
begin `EF BB BF` after a save. The library's answer is exactly the
spec's, both halves: position 0 is skipped, every other position is a
stray character. `extras` is `[/\s/, …]` and `/\s/` does not match
U+FEFF, so the tolerance is the tree-sitter runtime's own position-0
skip, not a hole in `extras` — which is why the mid-file half stays
strict for free.

**`grammar.js` needs no change, and must not get one.** The trap is
worth naming because le07 walked into it: the `tree-sitter test` harness
does NOT perform the runtime's position-0 skip — it feeds a test body
straight in — so three corpus tests written to pin D74's leading-BOM
tolerance all FAILED, and the obvious "fix" is to add U+FEFF to
`extras` or to open `source_file` with an optional BOM token. Either
change would be measured green by the harness and would **break the
editors**, because `extras` cannot distinguish position 0 and would make
the mid-file BOM trivia too — retiring E0107's whole half of D74. The
harness disagrees with both the CLI and the library; the harness is the
one that is wrong.

What le07 pins instead:

- **the mid-file half in the suite** — `test/corpus/items.txt` gains
  "D74: a byte order mark anywhere but the start is a stray character",
  which asserts `(ERROR (UNEXPECTED 65279))`. All three doors agree on
  this half, so it is truthfully expressible in the harness. It sits
  beside the shebang tests, the file-start-trivia neighbourhood.
- **the leading half by Gate 4** — `corpus/grammar/bom_at_start.lu` is
  one of the 478 gated files and parses at zero ERROR nodes. That is a
  real pin through a real door.
- **the leading half through the library** is pinned by nothing
  automated. It cannot be, without adding a Rust toolchain to a
  JS-toolchain CI for one assertion. It is measured, recorded in the
  table above, and the reason a future sprint must not "fix" the harness
  failure is written down here. **This is the one known gap le07 carries
  forward.**

## 4. `[os.net.unix]` — two builtin functions, zero syntax

`net_listen_unix(path: str)` and `net_connect_unix(path: str)` are
call expressions over plain identifiers. This repo has no builtin-FUNCTION
list to update: `queries/highlights.scm` paints calls structurally
(`(call_expression function: (identifier) @function)`), never by name, so
the net tier's growth reaches it for free — as `fs_*`, `net_read_bytes`
and the rest already did. The nine files under `corpus/net/` (including
`unix_echo.lu`, the clause's own witness) are in the 478 and parse clean.

`spec/02-memory-model.md`'s three edits are `List[int]` → `List[byte]`
in prose and a ledger-accounting sentence. No production.

## 5. The corpus floor, re-measured

At wolf-lang trunk `1323c4e` (the r07 merge; `v0.2.4` and trunk hold a
byte-identical corpus): **503** `.lu` files, **25** parse-tier
counter-examples excluded by directive, **478** gated, **zero** ERROR
nodes. The floor ratchets **466 → 478**.

One discrepancy to flag: the le07 contract predicted "v0.2.4's is 511
files". The tree holds 503, at the tag and at trunk both
(`git ls-tree -r --name-only v0.2.4 -- corpus | grep -c '\.lu$'`). The
floor follows the measurement, not the prediction.

## Known gaps carried forward

- §3's last bullet: the leading-BOM tolerance is a tree-sitter RUNTIME
  behaviour this repo's CI cannot assert through the harness, and the
  harness actively disagrees with it. Do not "fix" grammar.js to satisfy
  a harness failure on a leading BOM.
