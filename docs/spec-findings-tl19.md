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

## 3, scored (written after the measurement; §1–§3 above are unedited since `aa806a1`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | path sets against tl18's: 0 removed, 0 changed, 50 added, all `ok`; `ERR` 22 | `g1/verdicts-compare.txt` (head `aa806a1`, corpus `89dc1394`): `tl18 paths 1007; now 1057; ERR now 22`, `only tl18 (removed)` empty, `same path, different verdict` empty, `added 50; added-ok 50; added-ERR:` empty. The trunk grammar's gate: `g1/gate-trunk.log` `1019 files gated, 38 … excluded` / `PASS … (1019 files, floor 969)`, rc 0 — the receiver's 37963437735 reproduced | **yes** |
| 2 | the trees are the compiler's | `g1/trees.txt`: `-> never` is `return_type: (type_path (path (identifier)))` with a body (`fn_never_trap.lu` rows 10, 15) and bodyless after `(function_qualifier (string_literal))` (`fn_never_extern.lu` row 10); every `copy region scratch { … }` is `(unary_expression operand: (region_expression name: (identifier) body: (block …)))` (`region_copyout_binding.lu` row 10, `region_copyout_exits.lu` rows 21 and 32); `!` on an integer is `(unary_expression operand: …)` in a `const` value, a `let`, under `&`, and inside `(interpolation …)` (`int_not_signed.lu`, `int_not_mask.lu`); no `ERROR`, no `MISSING`. (The default `parse` output hides anonymous nodes, so the operator's spelling is read off the source span: `[10, 12]` is the `c` of `copy`.) | **yes** |
| 3 | three corpus cases pin those trees and pass at trunk's grammar; `generate` inert | at `8dee475`: `g2/pins-generate.log` `src diff rc 0`; `g2/pins-test.log` **149 of 150** — the integer-complement case failed, and the diff was one closing parenthesis too many in MY expected text (13 nodes deep, 14 `)` written), not a tree difference. Fixed in `fd97027`; `g3/ts-test.log` and `g4/ts-test.log`: `Total parses: 150; successful parses: 150` | **trees yes; my expected text no** (one miscounted paren) |
| 4 | a highlight test red at trunk's queries, green after the `never` pattern | **No test could say it.** `test/highlight/never.lu` failed identically under trunk's queries and the head's (`g3/`, `g4/ts-test-trunk-queries.log` and `g4/ts-test.log`: `Failure - row: 1, column: 28, expected highlight 'type.builtin', actual highlights: 'comment.line'`), because this grammar starts every line comment that follows a newline at the END of the previous line (`g4/comment-ranges.txt`: `// a` on row 1 parses as `(line_comment [0, 15] - [1, 4])`), and the CLI places an assertion from the comment node's start (`parse_position_comments`, tree-sitter v0.26.13). The first prose fix (`ac542e7`, no capture name in the header) moved nothing, which is what showed the cause was the ranges. The test retired in `bedb686`; filed **tree-sitter-wolf#27**. The pattern itself is measured by #5 | **no** |
| 5 | captures move only where `never` is a type: +1, +1, +1, +1, +2 on the five `fn_never_*`; locals identical | `g2/captures-diff.txt` (g1's trunk queries vs the head's `adb7c6b` queries, one parser, all 1057 files): exactly `fn_never_extern.lu 87→88`, `fn_never_handler_arm.lu 111→112`, `fn_never_reaches_end.lu 41→42`, `fn_never_return.lu 47→48`, `fn_never_trap.lu 118→120`, locals unchanged on all five, no other file; `g2/never-captures.txt`: `never` at (10,20) and (15,13) captures `type.builtin` beside the generic `type`; `g2/queries-head.log`: highlights, locals, injections rc 0 | **yes** |
| 6 | default green at 1019; `FLOOR=1020` red; shrunk red; planted red | at `8452337` (script blob `e8ec7ac5`): `g2/gate-committed-default.log` `PASS … (1019 files, floor 1019)`, rc 0; `g2/gate-floor-1020.log` `FAIL: only 1019 file(s) gated — the floor is 1020; checkout suspect`, rc 1; `g2/gate-committed-shrunk.log` (`typecheck/fn_never_trap.lu` removed from a scratch copy) `1018 files gated` / `FAIL: only 1018 … floor is 1019`, rc 1; `g2/gate-planted.log` `1020 files gated` / `FAIL: 1 file(s) …` / `…/tl19_planted_bad_let.lu`, rc 1; `g2/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0 | **yes** |
| 7 | CI green at the head; the planted break red via the highlight test | the highlight test is gone (#4), so the plant moves to the gate this lane did touch: the committed floor. Run ids in the PR body | — (see the PR) |

Four of six scored held; one held on the trees but not on my own expected
text; one (#4) could not be measured by the instrument I chose, for a reason
outside this lane's change, now filed. What a reader in helix or zed sees
change: `never` paints as a builtin type in `-> never` (and nowhere else),
the way `range` paints; `copy region`, `-> never` and `!` on an integer
parsed clean before this lane and still do, and are now pinned by corpus
cases.

**Private libdirs, checked** (`g1/libdirs.txt`, `g2/libdirs.txt`). Trunk's
grammar built to `lib-trunk`, the head's to `lib-head`; both `wolf.so`
`f3bc57d8…`, the digest tl18 recorded for `66a677f0` (`src/` did not move).
The shared `~/.cache/tree-sitter/lib/wolf.so` still carries its 2026-09-26
18:19 mtime.

### §2 corrected after the commit

- None of §2's numbers moved. The contract's "rules for the new syntax" is
  the drift §2 names: no rule is owed; corpus cases pin the trees.
- The acquisition-before-prediction deviation is disclosed above §1.

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl19/`. The clone the runs use is
`~/lanes/tl19/ts`; the corpus is `~/lanes/tl19/wolf-lang`, a depth-1 clone at
`v0.2.26` = `89dc1394` (1057 `.lu`); the tree-sitter binary is
`~/lanes/tl19/tsbin/tree-sitter` (`setup.log` carries its digest).

| claim | artifact |
|---|---|
| the acquisition: archive digests = the API's, members by name, `wolf --version`, `wolf prelude --json` = the tag's blob | `setup.log`, `acquire/members.txt` |
| trunk's grammar over 0.2.26: 1019 gated, PASS; verdicts against tl18's | `g1/gate-trunk.log`, `g1/verdicts.txt`, `g1/verdicts-compare.txt`, `tl18-verdicts-head.txt`; receiver run 37963437735 |
| the trees | `g1/trees.txt` |
| corpus cases: 149/150 on my paren, then 150/150; `generate` inert | `g2/pins-test.log`, `g2/pins-generate.log`, `g3/ts-test.log`, `g4/ts-test.log` |
| the highlight test that could not assert, and why | `g3/`, `g4/ts-test.log`, `g4/ts-test-trunk-queries.log`, `g4/comment-ranges.txt`; tree-sitter-wolf#27 |
| captures move only on the five `fn_never_*` | `g1/captures.txt`, `g2/captures-head.txt`, `g2/captures-diff.txt`, `g2/never-captures.txt`, `g2/queries-head.log` |
| the gate's three branches at the ratchet | `g2/gate-committed-default.log`, `g2/gate-floor-1020.log`, `g2/gate-committed-shrunk.log`, `g2/gate-planted.log`, `g2/verdicts-diff.txt` |
| commits | `aa806a1` (this contract), `8dee475` (corpus cases), `18a7fd7` (the highlight test), `adb7c6b` (the `never` pattern), `8452337` (the ratchet), `fd97027` (the paren), `ac542e7` (the test's prose), `bedb686` (the test retires) |
| CI at the head; the planted red | run ids in the PR body |

## 5. Done-when

- branch `tl19` on origin; PR open, unmerged, its body carrying the five
  sections, commit-hash bullets and a test checklist; CI green at the head
  sha, read with `gh run view`; the planted red's run id cited
- this §3 commit precedes every test, query and ratchet commit
- no attribution trailers
- the worktree removed; `~/lanes/tl19/` pruned to its logs; no orphan
  process
- listed to close (not closed by this lane): none; filed tree-sitter-wolf#27
