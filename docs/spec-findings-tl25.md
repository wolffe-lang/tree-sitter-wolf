# tl25 — the floor at 0.2.32

wolf-lang cut **0.2.31** on 2026-10-17 (`v0.2.31` = `f4faf59d`) and
**0.2.32** on 2026-10-18 (`v0.2.32` = `72de141f`, release 416327027), a
point release over it. This repository last moved at 0.2.30 (tl24,
`794fdcf`, floor 1103). This file is lane tl25's contract and record for
tree-sitter-wolf: whether anything 0.2.31 or 0.2.32 added to the surface
needs a grammar rule or a highlight pattern, and the corpus floor at
0.2.32. The wolf-lsp half (the pin, the vendored spec with 0.2.31's seven
prelude names, the transcripts) is wolf-lsp `docs/PIN-0232.md` on its
branch `tl25`. Contract: planning `sprints/lsp/tl25-the-editors-at-0232.md`
(`0fb714c`); rules `sprints/crawl-54.md` down to `wave-45.md`; template
tl24 (`docs/spec-findings-tl24.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run in this lane; §3 is not edited after this
commit. Everything in §2 was read from git objects (wolf-lang's tags), the
GitHub API, the downloaded archive and CI logs.

## 1. Forbidden, absolutely

- No grammar rule and no highlight query changed without a corpus case that
  shows it. **Prelude functions do not highlight as builtins** (ruling #77,
  item 4): no `@function.builtin` pattern over prelude names.
- No `rm` outside `~/lanes/tl25/`; no `git add -A`; nothing under
  `~/.claude`; nothing in another org's repository.
- No build on nomad-1: `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl25/`, each with a private
  `TREE_SITTER_LIBDIR` (tl13). Lanes install no host tool: the CLI is the
  0.26.13 binary already on kasumi in an earlier lane's `node_modules`,
  accepted only if its sha256 is the one tl14–tl24 recorded (`ad369a4d…`).
- No merge, no tag, no issue filed or closed; the branch asserted before
  every commit; no attribution trailers.
- The toolchain is the release by digest, each digest read twice, never
  wolf-lang's trunk. The floor ratchets to the measured count at the
  release, never down, never above it; a count of files is compared as a
  set of paths both ways (wolf-lang#177). No "seen red" without a run id,
  sha or captured log in the same paragraph.

## 2. Inputs, re-derived 2026-10-18 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `794fdcf` (tl24's merge) | `794fdcfb` (tl24's plant revert), by `git ls-remote` on nomad-1 and the clone on kasumi; open issues: #27 only | none |
| wolf 0.2.32 | `v0.2.32` at `72de141f` | `v0.2.32^{commit}` = `72de141f624662fdff522e8beba459fab7c5cf66` (annotated tag object `d21c4b28…`), by `git ls-remote` on nomad-1 and on kasumi; release **416327027**, published 2026-10-18T08:38:14Z, four assets (API digests): linux x86-64 `4c37f9c5…`, linux aarch64 `af27d426…`, macOS arm64 `061ea7e5…`, windows `40eb42af…`. The linux x86-64 and macOS archives downloaded on kasumi and hashed twice (`sha256sum`, `openssl dgst`), both equal to the API's; `wolf 0.2.32 (wolfgang, pin 72de141)` | none |
| lupin 0.1.54 | `v0.1.54` at `0e536e8` | `v0.1.54^{commit}` = `0e536e8fb4518eaa798ac426901ab81275db5c9f` (tag object `9c98d445…`); release 415937354 (linux x86-64 `175df238…`, macOS `9cd14db7…`, matched twice). This repository never runs lupin | none |
| **"the grammar re-checked against 0.2.32"** | expect none: s237's shift rule is a check, not syntax | **Nothing grammatical changed in 0.2.31 or 0.2.32.** At `v0.2.30`, `v0.2.31` and `v0.2.32`: `spec/grammar.ebnf` blob `29d5de10`, `spec/01-grammar.md` blob `d1bd4ff9`, the compiler's parser `crates/wolf_parse/src` tree `03b61b38`, its lexer `crates/wolf_lex/src` tree `9166b9fd`, the formatter `crates/wolf_fmt/src` tree `c29a0c87`, all identical. Under `crates/wolf_parse` and `crates/wolf_lex` (v0.2.30..v0.2.32) the only change is 26 added and 2 modified snapshot files under `tests/snapshots/` (13 corpus files added, one per crate each; `memory/raw_lshr_top_bits` modified, a comment); 0.2.31..0.2.32 touches neither crate nor the corpus. The CHANGELOGs name no token, keyword, operator or production: the shift rule (`[type.int.shift]`, ruling #77 A: what `<<`/`>>` *compute* on plain integers, the constant evaluator, the overflow trap), exit 71 at start, seven builtins (calls), the poll's status values; 0.2.32 is a runtime descriptor fix and the checked machine's waits | no rule is owed |
| prelude names | 0.2.31's seven, none new at 0.2.32 | `spec/prelude.json` blob `8816efac` (v0.2.30) → `18ddf784` (v0.2.31) = `18ddf784` (v0.2.32), `.names` as `(name, kind)` sets both ways: 175 → 182, **7 added, 0 removed**, all `function`, all `[os.host.sigs]`: `os_signal_send_group`, `os_signal_send_all`, `os_set_pgid`, `os_signal_last`, `os_signal_realtime`, `os_signal_text`, `os_wait_poll`; v0.2.31 → v0.2.32: 0 added, 0 removed. Type names (`builtin_type` 18 + `type` 8) 26 at all three. `queries/highlights.scm` paints prelude names only as `@type.builtin`; a call paints `@function`. Ruling #77 (4) keeps it so | nothing owed to the queries |
| the receiver at 0.2.31 | — | run **39070721959** (`repository_dispatch` `wolf-lang-corpus`, 2026-10-17T21:23Z, trunk `794fdcfb`): `wolf-lang corpus: 1116 files gated, 38 parse-tier counter-examples excluded` / `PASS: zero ERROR nodes across the corpus (1116 files, floor 1103)`. Scheduled run 39121708619 (2026-10-18T11:03Z, after the 0.2.32 tag at 08:27Z): the same two lines | the floor is 13 below the release count |
| the receiver at 0.2.32 | — | **no `repository_dispatch` run at the 0.2.32 tag** in this repository's run list (the last is 39070721959, at 0.2.31); 0.2.32 changed no corpus file, and the scheduled run above gated the same 1116 | reported, not chased: wolf-lang's dispatch is not this repository's |
| corpus size | — | `corpus/**/*.lu` by `git ls-tree`: 1141 at `v0.2.30`, **1154** at `v0.2.31` and `v0.2.32`; as path sets v0.2.30 → v0.2.32: **13 added, 1 modified, 0 removed**: added `comptime/shift_overflow` (`fail(E0706)`), `comptime/shift_value`, `faults/int_shift_count_negative`, `faults/int_shift_left_overflow`, `faults/int_shift_left_past_width`, `faults/int_shift_left_sign_bit`, `kernels/wrap_lshr_fold`, `os/group_rows`, `os/job_poll_rows`, `typecheck/int_shift_value`, `typecheck/straight_line_shl_assign`, `typecheck/straight_line_shl_const`, `typecheck/straight_line_shr_var`; modified `memory/raw_lshr_top_bits` (a comment and its stdout). None parse-tier, so 38 excluded and 1116 gated | — |
| tests | — | `test/corpus`: 150 cases; no `test/highlight/` (#27 open) | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`; kasumi has no `tree-sitter` on `PATH` and tl24's `tsbin/` copy is gone (pruned); the pinned binary at `~/lanes/tl11/ts/node_modules/tree-sitter-cli/tree-sitter` was copied into `~/lanes/tl25/tsbin/` and reads sha256 `ad369a4d…` (`setup.log`), tl14–tl24's digest | disclosed |
| tl24's verdicts | — | kasumi `~/lanes/tl24/g2/verdicts-head.txt` (1141 lines, ERR 22), over the 0.2.30 corpus at the grammar trunk still carries; copied to `~/lanes/tl25/tl24-verdicts-head.txt` | — |

## 3. Prediction, committed before any run

**Not a prediction:** 1154 files, 38 excluded, 1116 gated and a green gate
at trunk's grammar are §2 inputs (the receiver printed them).

1. **Per-file verdicts at trunk's grammar over the v0.2.32 corpus, as path
   sets against tl24's**: 0 paths only in tl24's; the 1141 shared paths keep
   their verdict (`memory/raw_lshr_top_bits` stays `ok`); exactly 13 new
   paths, **all `ok`**; `ERR` stays 22; 1154 paths. *Falsifier:* a shared
   path changing verdict, an added `ERR`.
2. **`generate` is inert and the tests hold**: `src/` byte-identical after
   `tree-sitter generate`; `tree-sitter test` 150 of 150; the three query
   files load. No file under `grammar.js`, `src/`, `queries/` or `test/`
   changes in this lane.
3. **The seven new names parse as plain calls and paint as `print` does**:
   a scratch file calling each name read from `spec/prelude.json` at the tag
   (the tag's list minus the v0.2.30 list wolf-lsp trunk vendors) parses
   with no `ERROR`/`MISSING`; each callee captures `function`; no
   `function.builtin` capture anywhere. The thirteen new files' shifts
   (`<<`, `>>`, `<<=`, `>>=` on plain and `wrapping` integers) parse with no
   `ERROR` (part of 1).
4. **The gate's branches at the ratchet** (`FLOOR="${FLOOR:-1116}"`), over
   the v0.2.32 corpus: default passes `1116 files gated`, `floor 1116`;
   `FLOOR=1117` fails `checkout suspect`, rc 1; a copy with one gated file
   removed fails `only 1115 … floor is 1116`, rc 1; a copy with
   `fn main() -> !int { let ( = }` planted gates 1117 and fails
   `FAIL: 1 file(s)` naming it, rc 1.
5. **CI at the head** is green gating wolf-lang's trunk (1116 files or more:
   trunk may move past the tag), floor 1116; **a planted break goes red**:
   the default floor moved to 2000 reds the corpus step with `the floor is
   2000`; its revert is green.

## 3, scored (written after the measurement; §1–§3 above are unedited since `ed993b5`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | path sets against tl24's: 0 removed, 0 changed, 13 added, all `ok`; `ERR` 22; 1154 paths | `g1/verdicts-compare.txt` (head `ed993b5`, corpus `72de141f`): `tl24 paths 1141; now 1154; ERR now 22`, `only tl24 (removed)` empty, `same path, different verdict` empty (`memory/raw_lshr_top_bits.lu` `ok` in `g1/verdicts.txt`), `added 13; added-ok 13; added-ERR:` empty; the 22 `ERR` paths are tl24's 22. Trunk's grammar under the gate, `g1/gate-trunk.log`: `1116 files gated, 38 … excluded` / `PASS … (1116 files, floor 1103)`, rc 0 — the receiver's 39070721959 reproduced | **yes** |
| 2 | `generate` inert; 150 of 150; the three queries load; nothing under `grammar.js`, `src/`, `queries/`, `test/` changes | `g1/ts-generate.log`, `g2/ts-generate.log`: `generate rc 0`, `src diff rc 0`; `g1/ts-test.log`, `g2/ts-test.log`: `Total parses: 150; successful parses: 150`; `g1/queries.log`, `g2/queries.log`: highlights, locals, injections rc 0; `g2/head.txt`: `src` tree `e8d4fd5e`, `queries` tree `cf647eb2`, `test` tree `884d5bfa`, `grammar.js` blob `2cac20e7`, each equal to trunk `794fdcf`'s (tl24's `g2/head.txt` names the same four); `g2/diff-vs-trunk.stat`: this file and `script/parse-wolf-corpus.sh` only | **yes** |
| 3 | the 7 new names parse as calls and capture `function`; no `function.builtin`; the shift files parse | `g1/new-names-head.txt`: the tag's list (blob `18ddf784`) minus the v0.2.30 list wolf-lsp trunk vendors (blob `8816efac`): `new names 7 kinds: 7 function`; `g1/calls-tree.txt`: 0 `ERROR`/`MISSING`; `g1/calls-summary.txt`: each of the 7 callees captures `function` once (and the CLI's fallback `variable` listing, as for `print`, as tl20 and tl24 recorded), `function.builtin captures anywhere: 0`. The 13 new files, eleven with `<<`/`>>`, all `ok` (row 1) | **yes** |
| 4 | default green at 1116; `FLOOR=1117` red; shrunk red; planted red | at `df23804` (script blob `fd0b34da`): `g2/gate-committed-default.log` `PASS … (1116 files, floor 1116)`, rc 0; `g2/gate-floor-1117.log` `FAIL: only 1116 file(s) gated — the floor is 1117; checkout suspect`, rc 1; `g2/gate-committed-shrunk.log` (`os/signal_shell_rows.lu` removed from a scratch copy) `1115 files gated` / `FAIL: only 1115 … floor is 1116`, rc 1; `g2/gate-planted.log` `1117 files gated` / `FAIL: 1 file(s) …` / `…/tl25_planted_bad_let.lu`, rc 1; `g2/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0 | **yes** |
| 5 | CI green at the head gating wolf-lang's trunk, floor 1116; the floor-2000 plant red | run ids in the PR body | — (see the PR) |

Four of four scored before CI held. **What a reader in helix or zed sees
change: nothing.** 0.2.31 and 0.2.32 added no syntax: the shift rule
changes what `<<` and `>>` compute, not how they parse; the seven builtins
are calls and paint as calls, as `print` does, and ruling #77 (4) keeps it
that way. What changed here is the floor, 1103 → 1116.

## 4. Evidence index

Logs on kasumi under `~/lanes/tl25/` (`setup.log`, `acquire/members.txt`,
`g1/*`, `g2/*`; the wolf-lang tree is the depth-1 clone at `72de141f`, and
the three tags were read from a blobless clone, `wolf-lang-all`; the CLI is
`tsbin/tree-sitter`, sha256 `ad369a4d…`). Private libdirs: `lib-g1`,
`lib-g2` (`g1/libdirs.txt`, `g2/libdirs.txt`).
