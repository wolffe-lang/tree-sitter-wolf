# tl19 — the floor at 0.2.26, `-> never`, `copy region`, and `never` painted

wolf-lang cut **0.2.26** on 2026-10-09 (`89dc1394`, release 408143286). This
repository last moved at 0.2.25 (tl18, `66a677f0`, floor 969). This file is
lane tl19's contract and record for tree-sitter-wolf: what 0.2.26 adds to the
surface a grammar sees (`-> never`, ruling #50; `!` on an integer, ruling #51;
`copy region name? { … }`, ruling #56), whether the grammar parses each one
into the tree the compiler means, the prelude's one new type name (`never`)
painted as a builtin, and the corpus floor at 0.2.26. The wolf-lsp half (the
pin, the vendored spec, the type-names classification, the editors' grammar
pin) is wolf-lsp `docs/PIN-0226.md` on its branch `tl19`, with its own five
sections. Contract: planning `sprints/lsp/tl19-the-editors-at-0226.md`; rules
`sprints/wave-53.md` down to `wave-45.md`; template tl18
(`docs/spec-findings-tl18.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run on kasumi; §3 is not edited after this commit.

**One deviation from the contract, disclosed here before anything is
measured.** The contract says the prediction is committed "before the
archives are unpacked". The acquisition (`~/lanes/tl19/setup.sh` on kasumi,
log `setup.log`) downloaded, digest-checked and **unpacked** the four
archives before this commit, because §2 cites their member digests and
`wolf --version` (tl18's order). Nothing else ran against them: the only
commands that executed the acquired binaries were `wolf --version`,
`lupin --version` and `wolf prelude --json` (hashed, not read for names).
No grammar, query or gate has run in this lane. The one 0.2.26 gate result
that exists is the public receiver run 37963437735 (below), and §3 treats
its numbers as inputs, not predictions.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl19/` (kasumi) and this lane's two worktrees
  (`/private/tmp/tl19-grammar`, `/private/tmp/tl19-lsp`); no deletion in any
  tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1. `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl19/`, **each with a private
  `TREE_SITTER_LIBDIR`**, never the shared `~/.cache/tree-sitter/lib/wolf.so`.
  kasumi's `/home` is at 97 % (37 GB free): one clone per repo, pruned as
  the evidence is written.
- No merge, no tag; no `2>/dev/null` on a checkout; the branch is asserted
  before every commit. No attribution trailers.
- The toolchain is the release archive by digest, never a clone's build,
  Homebrew or `~/.local/bin`.
- No "seen red" without a run id, sha, path or captured log in the same
  paragraph. **Both failure branches of the gate** are seen red at the
  ratchet head, each with its log path.
- The floor ratchets to the measured count, never down, never above it.
- A count of files is compared as a **set of paths both ways**, never as a
  number alone (wolf-lang#177).
- Kill only pids this lane started; kasumi jobs launched with `setsid`,
  waited on by a done-file or the recorded pid in loops that print at least
  every five minutes. CI read with `gh run view`; no `gh run watch` without
  `--interval 60`.

## 2. Inputs, re-derived 2026-10-09 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `66a677f0` | `66a677f0dfcbc676966ebd30ae91179a09370288` ("changelog: tl18"); the kasumi clone agrees (`setup.log`) | none |
| wolf 0.2.26 | `89dc1394`, release published | `v0.2.26^{commit}` = `89dc139443da38078df6093568da87bc6d0ee6f9` (annotated tag object `fdc73f26…`); release **408143286**, `draft=false`, published 2026-10-09T17:48:26Z, target `trunk`, four assets, exactly one release on the tag (the whole list queried) | none |
| the archives | linux x86-64 `05acdc5e…`, linux aarch64 `8b019b64…`, macOS arm64 `8ea7ef3b…`, windows `9cb6958d…` | API digests exactly these four; linux x86-64 75,695,949 B `05acdc5ea2f2…` and macOS arm64 17,388,103 B `8ea7ef3b1e6c…` downloaded on kasumi, sha256 equal to the API's (`setup.log` `MATCH` lines; members by name in `acquire/members.txt`); `wolf --version` → `wolf 0.2.26 (wolfgang, pin 89dc139)` / `paired with lupin 0.1.49 (reference interpreter), pin 294d626` | none |
| lupin 0.1.49 | `f516a5f`; linux x86-64 `84911a35…`, aarch64 `e1f53d15…`, macOS `ad188d58…`, windows zip `ebff44ab…`, `lupin.exe` `64212006…` | `v0.1.49^{commit}` = `f516a5f4ea43…` (tag object `5d14986a…`); release 408028965, five assets with exactly those digests; linux and macOS archives downloaded and matched; `lupin 0.1.49 (wolf-interp, reference interpreter at pin 294d626)`. This repository never runs lupin | none |
| the default branch | — | wolf-lang `origin/trunk` = `89dc1394` = the tag, so the CI gate's default-branch checkout and the tag hold the same corpus | none (re-checked at CI time) |
| the pin here | — | as tl13–tl18 found, no pin file: the gate reads wolf-lang's default branch; the recorded pin is the ratchet paragraph in `script/parse-wolf-corpus.sh` (`FLOOR="${FLOOR:-969}"`) and `CHANGELOG.md` | wording (as tl18) |
| **"the grammar parses `-> never` and `copy region { … }`" — contract item 2 asks for "rules for the new syntax"** | rules owed | **No production moved.** `spec/grammar.ebnf` is blob `29d5de10` at v0.2.25 and v0.2.26, and the compiler's parser is the same tree at both tags (`crates/wolf_parse/src` `03b61b38`, `crates/wolf_lex/src` `9166b9fd`). The three spellings are semantics over syntax both parsers already accepted: `never` is a type NAME (a `builtin_type` in `spec/prelude.json`, anchor `type.fn.never`; wolf-lang `38bccd90`), `!` was already a unary operator, and `[mem.region.copyout]` says of `copy region` "no new token, keyword or code; the second prefix that changes what a block's `}` does, beside `freeze region { … }`" (`spec/02-memory-model.md` at v0.2.26, line 761) — the `copy` prefix over a region block, which this grammar already reads as `unary_expression` (operator `copy`) over `region_expression` | **drift: no rule is owed;** the lane pins the trees with corpus cases instead (§3.3) |
| the receiver at 0.2.26 | — | run **37963437735** (`repository_dispatch`, 2026-10-09T17:02Z, trunk `66a677f0`, wolf-lang `89dc1394`): `wolf-lang corpus: 1019 files gated, 38 parse-tier counter-examples excluded` / `PASS: zero ERROR nodes across the corpus (1019 files, floor 969)`, `success`. The trunk grammar gates 0.2.26 green today; the floor is 50 below the count | the gate is not red; the floor is owed |
| corpus size | — | **1057** `.lu` under `corpus/` at `89dc1394` (`git ls-tree`; the kasumi clone's `find` agrees, `setup.log`), **1007** at `6710f9e0`: **50 added, 0 modified, 0 removed**. Added by directory: memory 31 (nine `region_copyout_*`), typecheck 9 (five `fn_never_*`, four `int_not_*`), comptime 4, os 3, fs 3 | — |
| exclusions | — | the gate's rule (`check: fail(E0[012]` in the first 20 lines) over the 50 added files: **none** matches, so **38** as at v0.2.25 and **1019 gated** = 1057 − 38, the receiver's number | — |
| the new spellings in the corpus | — | `copy region scratch { … }` at **10** code sites in the 9 `memory/region_copyout_*.lu` (`region_copyout_exits.lu` has two; every one named — the corpus spells no anonymous `copy region {` outside a comment); `-> never` at **6** code sites in 5 files — `typecheck/fn_never_extern.lu` 1 (bodyless `extern "c" fn abort() -> never`), `fn_never_handler_arm.lu` 1, `fn_never_reaches_end.lu` 1, `fn_never_return.lu` 1, `fn_never_trap.lu` 2; `!` on an integer (or, refused, on a float) in the four `typecheck/int_not_*.lu`, in `let`, in `const` initializers (`const PAGE_MASK: u32 = !0xfff`), under `&` and `+` (`x + 0xfff & !0xfff`), and inside string interpolation in all four (`"{!x}"`, `"{!(0 as u32)}"`). No corpus file binds a value named `never` | — |
| the prelude | — | `spec/prelude.json` `e61b9fcf` → `21a2561c`, 124 → 134 names, 0 removed: nine `function` (`fs_copy_chunk`, `os_spawn_fds`, `os_pipe`, `os_chdir`, `os_isatty`, `os_error`, `os_error_text`, `bytes_find`, `bytes_count`) and one `builtin_type`, **`never`** (`w0304: false`; wolf-lang's `BUILTIN_TYPE_ONLY` = `["never"]`: "written only as a fn's return type … a binding named `never` shadows nothing", and wolf-std binds one four times: `tests/bytes/utf8_validation.lu:90`, `tests/fs/fstat_rows.lu:72`, `tests/net/wait_readiness.lu:80`, `tests/x/crypto/chacha20/flipped_tag_row.lu:54` at `0f74ec5`). The acquired binary's `wolf prelude --json` hashes to the tag's blob `21a2561c` (`setup.log`) | — |
| the queries today | — | `highlights.scm` paints no prelude FUNCTION as a builtin (no `@function.builtin` pattern exists; a call paints `@function`), so the nine new functions have nothing to join. Builtin TYPES paint `@type.builtin` two ways: the closed any-position list of the 17 prims (`int` … `wrapping`), and `range` scoped to a one-segment `type_path` (`(#eq? @type.builtin "range")`), because the name resolves in type position only and the corpus binds `var range`. `never` is in neither; in `-> never` it paints `@type` through `(type_path (path (identifier) @type))` | `never` is owed, scoped like `range` |
| tests | — | `test/corpus`: 147 cases over 11 files; **no `test/highlight/`** directory, so no query is under a test today | — |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`); `releases/download/v0.26.13/tree-sitter-linux-x64.gz`, sha256 `ad369a4d…` = tl14–tl18's (`setup.log`) | — |
| tl18's verdicts | — | `~/lanes/tl18/g3/verdicts-head.txt` (grammar `f375a8d`, whose `src/` and `queries/` are trunk's, over the 0.2.25 corpus: 1007 lines, 22 `ERR` — the fifteen `grammar/*` counter-examples, `resolve/broken_sibling/mangled.lu` and the six `rows/negative/first_*`), copied to `~/lanes/tl19/tl18-verdicts-head.txt` | — |
| open issues | — | none on tree-sitter-wolf (#25 closed at tl18's merge) | — |

## 3. Prediction, committed before any run

**What is not a prediction.** 1057 files, 38 excluded, 1019 gated and a
green gate at trunk's grammar are §2 inputs (the receiver printed them).

1. **Per-file verdicts at trunk's grammar, as path sets against tl18's.**
   0 paths only in tl18's; the 1007 shared paths keep tl18's verdict; exactly
   the 50 added paths are new, **all 50 `ok`** (the gate's PASS covers only
   gated files; none of the 50 is excluded, so none may be `ERR`). `ERR`
   stays 22. *Falsifier:* any shared path changing verdict, any added `ERR`.
2. **The trees are the compiler's.** Under trunk's grammar:
   `fn die(msg: str) -> never { … }` has `return_type: (type_path (path
   (identifier)))` spelling `never`, and `extern "c" fn abort() -> never`
   the same with no body; `copy region scratch { … }` is `(unary_expression
   operator: "copy" operand: (region_expression name: (identifier) body:
   (block …)))`, and the anonymous `copy region { … }` the same with no
   `name`; `!a` on an integer is `(unary_expression operator: "!" operand:
   (identifier))`, inside a string interpolation too. No `ERROR`, no
   `MISSING`. *Falsifier:* any other shape (in particular `copy` binding
   tighter or looser than the whole region block, or `never` reading as a
   keyword node).
3. **Corpus cases pin those trees, and they pass at trunk's grammar** — they
   are pins, not red-first cases, because no rule changes: `test/corpus/`
   gains cases for the named and anonymous `copy region`, `-> never` with a
   body and bodyless `extern "c"`, and `!` on an integer (bare and in an
   interpolation); `tree-sitter test` passes 147 + N of 147 + N at trunk's
   `grammar.js`, and `generate` leaves `src/` byte-identical (no rule moves).
   *Falsifier:* a new case failing at trunk's grammar, or `src/` moving.
4. **`never` paints `@type.builtin` in type position only, red first.** A
   highlight test (`test/highlight/never.lu`, the repository's first)
   asserting `type.builtin` on `never` in `-> never` (a body, and a bodyless
   `extern "c" fn`) and `!type.builtin` on a local binding named `never`
   **fails at trunk's queries** (`never` resolves to `type`) and passes after
   one pattern beside `range`'s: `((type_path (path . (identifier)
   @type.builtin .)) (#eq? @type.builtin "never"))`, not the any-position
   list. `locals.scm` and `injections.scm` unchanged. *Falsifier:* the test
   passing at trunk's queries, or failing after the pattern, or the binding
   painting `type.builtin`.
5. **Captures over the corpus move only where `never` is a type.** Running
   trunk's and the head's `highlights.scm` against the same parser over all
   1057 files, the head captures **exactly one more** per type-position
   `never` — `fn_never_extern.lu` +1, `fn_never_handler_arm.lu` +1,
   `fn_never_reaches_end.lu` +1, `fn_never_return.lu` +1, `fn_never_trap.lu`
   +2 — and the same count on the other 1052 (the new pattern adds a capture;
   the generic `@type` capture stays in the output). `locals.scm` counts
   identical everywhere. All three queries load. *Falsifier:* a query error,
   or any other file's count moving.
6. **Both gate branches red at the ratchet head** (`FLOOR="${FLOOR:-1019}"`
   committed): the committed default passes at 1019; `FLOOR=1020` fails
   `only 1019 file(s) gated — the floor is 1020; checkout suspect`, rc 1; a
   scratch corpus with one gated file removed fails `1018 … floor is 1019`,
   rc 1; a scratch corpus with `fn main() -> !int { let ( = }` planted gates
   1020 and fails `FAIL: 1 file(s)` naming it, rc 1.
7. **CI at the head** (`pull_request`) is green with `1019 files gated`,
   `floor 1019`, and the corpus-test step running the highlight test; **a
   planted break goes red in CI**: one commit dropping `never` from the
   pattern reds the `corpus tests` step (`tree-sitter test`, the highlight
   assertion) in its own `pull_request` run; its revert is green.
