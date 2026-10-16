# tl24 — the floor at 0.2.30

wolf-lang cut **0.2.30** on 2026-10-15 (`v0.2.30` = `1b37f368`, release
413582739). This repository last moved at 0.2.29 (tl20, `4fe68149`, floor
1092). This file is lane tl24's contract and record for tree-sitter-wolf:
whether anything 0.2.30 added to the surface needs a grammar rule or a
highlight pattern, and the corpus floor at 0.2.30. The wolf-lsp half (the
pin, the vendored spec, the transcripts, wolf-lsp#42) is wolf-lsp
`docs/PIN-0230.md` on its branch `tl24`. Contract: planning
`sprints/lsp/tl24-the-editors-at-0230.md` (`be08902`); rules
`sprints/crawl-54.md` down to `wave-45.md`; template tl20
(`docs/spec-findings-tl20.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run in this lane, and before any archive is
downloaded; §3 is not edited after this commit. Everything in §2 was read
from git objects (wolf-lang's tags), the GitHub API and CI logs.

## 1. Forbidden, absolutely

- No grammar rule and no highlight query changed without a corpus case that
  shows it. **Prelude functions do not highlight as builtins** (ruling #77,
  item 4): no `@function.builtin` pattern over prelude names.
- No `rm` outside `~/lanes/tl24/`; no `git add -A`; nothing under
  `~/.claude`; nothing in another org's repository.
- No build on nomad-1: `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl24/`, each with a private
  `TREE_SITTER_LIBDIR`. Lanes install no host tool: the CLI is the 0.26.13
  binary already on kasumi in an earlier lane's `node_modules`, accepted
  only if its sha256 is the one tl14–tl20 recorded (`ad369a4d…`).
- No merge, no tag, no issue filed or closed; the branch asserted before
  every commit; no attribution trailers.
- The toolchain is the release by digest, each digest read twice, never
  wolf-lang's trunk. The floor ratchets to the measured count at the
  release, never down, never above it; a count of files is compared as a
  set of paths both ways (wolf-lang#177). No "seen red" without a run id,
  sha or captured log in the same paragraph.

## 2. Inputs, re-derived 2026-10-16 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | tl20's merge | `4fe68149` (tl20's plant revert); open issues: #27 only | none |
| wolf 0.2.30 | `v0.2.30` at `1b37f368` | `v0.2.30^{commit}` = `1b37f368228db92eca505c8c4cd3c531ea60be48` (tag object `ffb7c5b3…`), from `git ls-remote`; release **413582739**, `draft=false`, published 2026-10-15T08:53:05Z, four assets: linux x86-64 `4e55b39e…`, linux aarch64 `34237d4a…`, macOS arm64 `f3257e74…`, windows `2772a997…` | none |
| lupin 0.1.53 | `v0.1.53` at `7896edd` | `v0.1.53^{commit}` = `7896eddc17fd9e3e015b025b354ccf62a766734b`; release 413375414 (linux x86-64 `5db55332…`). This repository never runs lupin | none |
| **"the grammar re-checked against 0.2.30"** | say if nothing grammatical changed | **Nothing grammatical changed.** At `v0.2.29` and `v0.2.30`: `spec/grammar.ebnf` blob `29d5de10`, `spec/01-grammar.md` blob `d1bd4ff9`, the compiler's parser `crates/wolf_parse/src` tree `03b61b38`, its lexer `crates/wolf_lex/src` tree `9166b9fd`, the formatter `crates/wolf_fmt/src` tree `c29a0c87`, all identical. Under `crates/wolf_parse` and `crates/wolf_lex` the only change is 22 added snapshot files (`tests/snapshots/`), one per new corpus file, 0 modified. The CHANGELOG names no token, keyword, operator or production: a crash fix (s755), a refusal (E1010, s233), eleven builtins (calls), two terminal mode bits (values), the std pin. The shift rule (ruling #77 A) is **not** in 0.2.30 (0.2.31) | no rule is owed |
| prelude names | — | `spec/prelude.json` blob `f0fd9c54` → `8816efac`, `.names` as `(name, kind)` sets both ways: 164 → 175, 0 removed, **all 11 added are `function`** (`fs_set_owner`, `fs_set_owner_fd`, `os_uid`, `os_euid`, `os_gid`, `os_egid`, `os_groups`, `os_set_ids`, `os_term_size`, `os_term_chars`, `os_signal_wait_fd`); type names 26 at both. `queries/highlights.scm` paints prelude names only as `@type.builtin` (17 prims, `range`, `never`); a call paints `@function`. Ruling #77 (4) keeps it so | nothing owed to the queries |
| the receiver at 0.2.30 | — | run **38706859648** (`repository_dispatch` `wolf-lang-corpus`, 2026-10-15T08:36Z, trunk `4fe68149`): `wolf-lang corpus: 1103 files gated, 38 parse-tier counter-examples excluded` / `PASS: zero ERROR nodes across the corpus (1103 files, floor 1092)`. Scheduled CI 38893442489 (2026-10-16) green | the floor is 11 below the release count |
| corpus size | — | `corpus/**/*.lu` by `git ls-tree`: 1130 at `v0.2.29`, **1141** at `v0.2.30`; as path sets **11 added, 0 removed, 0 modified**: `conc/proc_must_join_legal.lu`, `os/ids_read.lu`, `os/ids_rows.lu`, `os/term_editor_rows.lu`, and seven `typecheck/straight_line_*` (`as_char`, `as_narrow`, `as_sign`, `str_eq`, `str_order`, `wrap_div`, `wrap_rem`). All eleven are `check: run(exit=0, …)`, none parse-tier, so 38 excluded and 1103 gated | — |
| tests | — | `test/corpus`: 150 cases; no `test/highlight/` (#27 open) | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`; kasumi has no `tree-sitter` on `PATH`; the pinned binary at `~/lanes/tl11/ts/node_modules/tree-sitter-cli/tree-sitter` reads sha256 `ad369a4d…` (2026-10-16), tl14–tl20's digest. Copied into `~/lanes/tl24/tsbin/` and re-hashed | disclosed |
| tl20's verdicts | — | kasumi `~/lanes/tl20/g2/verdicts-head.txt`, over the 0.2.29 corpus at the grammar trunk still carries | — |

## 3. Prediction, committed before any run

**Not a prediction:** 1141 files, 38 excluded, 1103 gated and a green gate
at trunk's grammar are §2 inputs (the receiver printed them).

1. **Per-file verdicts at trunk's grammar over the v0.2.30 corpus, as path
   sets against tl20's**: 0 paths only in tl20's; the 1130 shared paths keep
   their verdict; exactly 11 new paths, **all `ok`**; `ERR` stays 22; 1141
   paths. *Falsifier:* a shared path changing verdict, an added `ERR`.
2. **`generate` is inert and the tests hold**: `src/` byte-identical after
   `tree-sitter generate`; `tree-sitter test` 150 of 150; the three query
   files load. No file under `grammar.js`, `src/`, `queries/` or `test/`
   changes in this lane.
3. **The eleven new names parse as plain calls and paint as `print` does**:
   a scratch file calling each name read from `spec/prelude.json` at the tag
   (the tag's list minus the v0.2.29 list) parses with no `ERROR`/`MISSING`;
   each callee captures `function`; no `function.builtin` capture anywhere.
4. **The gate's branches at the ratchet** (`FLOOR="${FLOOR:-1103}"`), over
   the v0.2.30 corpus: default passes `1103 files gated`, `floor 1103`;
   `FLOOR=1104` fails `checkout suspect`, rc 1; a copy with one gated file
   removed fails `only 1102 … floor is 1103`, rc 1; a copy with
   `fn main() -> !int { let ( = }` planted gates 1104 and fails
   `FAIL: 1 file(s)` naming it, rc 1.
5. **CI at the head** is green gating wolf-lang's trunk (1103 files or more:
   trunk has moved since the tag), floor 1103; **a planted break goes red**:
   the default floor moved to 2000 reds the corpus step with `the floor is
   2000`; its revert is green.

## 3, scored (written after the measurement; §1–§3 above are unedited since `a2bc914`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | path sets against tl20's: 0 removed, 0 changed, 11 added, all `ok`; `ERR` 22; 1141 paths | `g1/verdicts-compare.txt` (head `a2bc914`, corpus `1b37f368`): `tl20 paths 1130; now 1141; ERR now 22`, `only tl20 (removed)` empty, `same path, different verdict` empty, `added 11; added-ok 11; added-ERR:` empty. Trunk's grammar under the gate, `g1/gate-trunk.log`: `1103 files gated, 38 … excluded` / `PASS … (1103 files, floor 1092)`, rc 0 — the receiver's 38706859648 reproduced | **yes** |
| 2 | `generate` inert; 150 of 150; the three queries load; nothing under `grammar.js`, `src/`, `queries/`, `test/` changes | `g1/ts-generate.log`, `g2/ts-generate.log`: `generate rc 0`, `src diff rc 0`; `g1/ts-test.log`, `g2/ts-test.log`: `Total parses: 150; successful parses: 150`; `g1/queries.log`, `g2/queries.log`: highlights, locals, injections rc 0; `g2/head.txt`: `src` tree `e8d4fd5e`, `queries` tree `cf647eb2`, `test` tree `884d5bfa`, `grammar.js` blob `2cac20e7`, each equal to trunk `4fe68149`'s; `g2/diff-vs-trunk.stat`: this file and `script/parse-wolf-corpus.sh` only | **yes** |
| 3 | the 11 new names parse as calls and capture `function`; no `function.builtin` | `g1/new-names-head.txt`: the tag's list (blob `8816efac`) minus the v0.2.29 list (blob `f0fd9c54`): `new names 11 kinds: 11 function`; `g1/calls-tree.txt`: 0 `ERROR`/`MISSING`; `g1/calls-summary.txt`: each of the 11 callees captures `function` once (and the CLI's fallback `variable` listing, as for `print`, as tl20 recorded), `function.builtin captures anywhere: 0` | **yes** |
| 4 | default green at 1103; `FLOOR=1104` red; shrunk red; planted red | at `1bf6f6d` (script blob `893486fb`): `g2/gate-committed-default.log` `PASS … (1103 files, floor 1103)`, rc 0; `g2/gate-floor-1104.log` `FAIL: only 1103 file(s) gated — the floor is 1104; checkout suspect`, rc 1; `g2/gate-committed-shrunk.log` (`os/signal_shell_rows.lu` removed from a scratch copy) `1102 files gated` / `FAIL: only 1102 … floor is 1103`, rc 1; `g2/gate-planted.log` `1104 files gated` / `FAIL: 1 file(s) …` / `…/tl24_planted_bad_let.lu`, rc 1; `g2/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0 | **yes** |
| 5 | CI green at the head gating wolf-lang's trunk, floor 1103; the floor-2000 plant red | run ids in the PR body | — (see the PR) |

Four of four scored before CI held. **What a reader in helix or zed sees
change: nothing.** 0.2.30 added no syntax; its eleven builtins are calls and
paint as calls, as `print` does, and ruling #77 (4) keeps it that way. What
changed here is the floor, 1092 → 1103.

## 4. Evidence index

Logs on kasumi under `~/lanes/tl24/` (`setup.log`, `acquire/members.txt`,
`g1/*`, `g2/*`; the wolf-lang tree is the depth-1 clone at `1b37f368`; the
CLI is `tsbin/tree-sitter`, sha256 `ad369a4d…`). Private libdirs:
`lib-g1`, `lib-g2` (`g1/libdirs.txt`, `g2/libdirs.txt`).
