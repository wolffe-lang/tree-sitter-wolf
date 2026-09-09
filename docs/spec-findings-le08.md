# le08 spec findings — five calls, no syntax, and one correction to le07

le08 re-read the spec diff `v0.2.4..v0.2.5`. It is two files, 168
lines added, zero removed: `spec/11-os.md` (+163) and
`spec/anchors.json` (+5). The sprint contract predicted "no syntax
delta" for s137's five clauses. That prediction is confirmed by
measurement, and §1 gives the measurement, following le07's precedent.
§3 records a correction: le07's own §2 recorded a fact about `char` that
is not true, and the reason is a path that does not exist.

## 0. The five new anchors, and what each asks of the grammar

`spec/anchors.json` gains five anchors in one release:

| anchor | what it introduces | grammar? |
| --- | --- | --- |
| `[os.net.listen.opts]` | `net_listen_with(str, bool, int) -> int` | **no** |
| `[os.net.wait]` | `net_wait(List[int], int) -> List[int]` | **no** |
| `[os.proc]` | §4 prose header, no call of its own | **no** |
| `[os.proc.inherit]` | `os_spawn_with(str, List[str], List[int]) -> int`, `net_adopt_listener(int) -> int` | **no** |
| `[os.cpus]` | `os_cpus() -> int` | **no** |

Five clauses, five new builtin FUNCTIONS (`[os.proc]` is a section
header and declares none). No new type name, keyword, operator or
literal form.

## 1. The measurement, not the prediction

Three independent limbs, all measured:

(a) The spec's own grammar chapter is untouched.
`spec/01-grammar.md` is not in the diff at all, so `[gram.inv.kw]` §6.1's
closed set of 50 reserved keywords is byte-identical across the pins.
So is every production in it. `spec/10-types.md` (the type chapter, and
the file that carried le07's whole byte tier) is likewise absent from
the diff.

(b) The reference compiler's lexer and parser are unchanged.
This is the limb that would catch a syntax delta the prose failed to
announce. Across `v0.2.4..v0.2.5`, `git diff --name-only` touches
`wolf_lex` and `wolf_parse` in eight files, all of them
`tests/snapshots/*.snap`: the four new witnesses' lex and decl
snapshots (`net/reuse_port`, `net/wait_readiness`,
`net/inherit_listener`, `os/cpus`). No `src/` file in either crate
changed. A release that added a token, a keyword or a production could
not have left both crates' sources byte-identical.

(c) The builtin TYPE set is byte-identical.
`crates/wolf_sema/src/prelude.rs`'s `BUILTIN_TYPES` holds the same
seventeen names at both pins:

```
bool str byte char int uint i8 i16 i32 i64 u8 u16 u32 u64 f32 f64 wrapping
```

What grew is `PRELUDE`, the builtin FUNCTION list, by the five names
above (`net_listen_with`, `net_adopt_listener`, `net_wait`, `os_cpus`,
`os_spawn_with`). That distinction matters here: this repo keeps no
builtin-function list. `queries/highlights.scm` paints calls
structurally,

```scheme
(call_expression function: (identifier) @function)
```

and never by name, so every one of s137's five calls is highlighted
correctly the moment it is written, with no query edit. The le07 entry
recorded this posture for `[os.net.unix]`'s two calls; s137's five
arrive through the same door, and it is now the second release in a row
where the OS tier grew and this repo did nothing.

`grammar.js` is unchanged. `queries/*.scm` are unchanged. The
measured delta is none.

## 2. The four new witnesses parse clean, and they are ordinary wolf

Each of the four is in Gate 4's gated set and parses at zero ERROR nodes:

| witness | clause | the shapes it actually uses |
| --- | --- | --- |
| `corpus/net/reuse_port.lu` | `[os.net.listen.opts]` | `else \|e\| match e { unsupported => …, _ => … }`, `0 - 1`, `?`, interpolation |
| `corpus/net/wait_readiness.lu` | `[os.net.wait]` | `List[int]()`, `(mut set).push(a)`, `net_wait(set, 20)?.len`, `woke[0]` |
| `corpus/net/inherit_listener.lu` | `[os.proc.inherit]` | `for a in args`, `else \|_\| return 21`, `List[str]()`, `os_spawn_with(exe, argv, inherit)` |
| `corpus/os/cpus.lu` | `[os.cpus]` | `var`, `os_cpus()` (zero-argument), `else \|_\| { … }`, `?`, interpolation |

Nothing there is newer than le05. The two shapes worth naming, because
they are the ones a "no delta" claim could hide behind, are
`net_wait(set, 20)?.len` (a `?` operator followed immediately by a
field access) and `else |_| return 21` (an else-block whose whole
body is a bare `return`). Both parse clean; both have been in the grammar
since le04's escape work and le05's separator law respectively. The type
names in the five signatures (`List[int]`, `List[str]`, `str`, `bool`,
`int`) are all generic type paths this grammar has parsed since le02, and
`(mut set).push(a)` is the ordinary mut-borrow receiver.

## 3. A correction: le07's `char` finding is wrong, and the conclusion it reached is right anyway

le07's §2 recorded, of the `@type.builtin` list:

> **`char` is in NEITHER limb of the compiler.** `grep -rn '"char"'
> compiler` is empty at v0.2.4: there is no `Prim::Char`, and `char` is
> not in `BUILTIN_TYPES`.
> […] **The mid-end has not landed `char`; the language has it.**

All three of those statements are false, at v0.2.4 and at v0.2.5.
The cause is in the quoted command: the le07 reading grepped a directory
named `compiler/`, and wolf-lang has no `compiler/` directory at trunk,
at `v0.2.4`, or at `v0.2.5`. The crates live at `crates/` off the repo
root. A recursive grep of a nonexistent path returns nothing, and that
nothing was read as an absence of the name.

Measured through the real path, at both pins:

- `char` is in `crates/wolf_sema/src/prelude.rs`'s `BUILTIN_TYPES`,
  fourth name in the literal, `"bool", "str", "byte", "char", …`.
- `Prim::Char` does exist, at `crates/wolf_mem/src/ubcheck.rs:7735`
  at v0.2.5 (`:7375` at v0.2.4), in three match arms. Those two numbers
  are two measurements and not a transposition, which is worth saying
  because they read like one: `git grep -n 'Prim::Char' <tag> --
  crates/wolf_mem/src/ubcheck.rs` answers 7375/7399/7422 at v0.2.4 and
  7735/7759/7782 at v0.2.5, three arms each. Re-run 2026-09-08 and
  unchanged at v0.2.6 (tree-sitter-wolf#4).

So `char` passes both limbs of le06's conjunction and always did.
le07's *conclusion* (keep `char` in `@type.builtin`) is correct, and the
query file needs no change today. But its recorded *reason* is a
measurement error, and the sentence "the mid-end has not landed `char`"
is the kind of belief a later sprint acts on. It is retired here.

The two-limb test re-run correctly across the whole `@type.builtin` set
at v0.2.5 (spec-prose mentions / membership in `BUILTIN_TYPES`):

| name | `spec/*.md` | `BUILTIN_TYPES` | verdict |
| --- | --- | --- | --- |
| `int` `str` `byte` `char` `f64` `wrapping` | many | yes | both limbs |
| `i8` `i32` `i64` `u8` `u16` `u32` `u64` `f32` `bool` | ≥1 | yes | both limbs |
| `uint` `i16` | 0 | yes | compiler limb — stays |
| `usize` `isize` | 0 | **no** | neither — struck at le06, **stays struck** |

Seventeen names in, seventeen names out. No query change.

## 4. The corpus floor, re-measured

At wolf-lang trunk `6263ffa` (the corpus is byte-identical at `v0.2.5`
and at trunk; `git diff v0.2.5..6263ffa -- corpus` is empty): 507 `.lu`
files, 25 parse-tier counter-examples excluded by directive, 482 gated,
zero ERROR nodes. The floor ratchets 478 → 482.

The four added files are s137's four witnesses; the exclusion count is
unchanged at 25, since none of the four is a parse-tier
counter-example (all four are `phase: run`). 503 → 507 in, 478 → 482
gated.

## Known gaps carried forward

- le07's §3, unchanged and still live: the leading-BOM tolerance is a
  tree-sitter RUNTIME behaviour this repo's CI cannot assert through the
  `tree-sitter test` harness, and the harness disagrees with it.
  Do not "fix" `grammar.js` to satisfy a harness failure on a leading
  BOM. This sprint added no BOM tests and changed nothing here; the
  mid-file half stays pinned in `test/corpus/items.txt`, the leading half
  by Gate 4 over `corpus/grammar/bom_at_start.lu`.
- Nothing new. s137 asked this repo for nothing.
