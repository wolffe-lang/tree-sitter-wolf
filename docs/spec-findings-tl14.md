# tl14 — the floor at 0.2.18

wolf-lang cut **0.2.18** on 2026-09-27 (`ec56a08f`, release 397723077). This
file is lane tl14's contract and record for tree-sitter-wolf. The lane's shared
inputs (release, archives, anchors, the wolf-lsp half) are in wolf-lsp's
`docs/PIN-0218.md` on its branch `tl14`; this file carries the grammar's own
five sections. Template: tl11 (`wolf/sprints/tooling/tl11-the-pins-at-0216.md`)
and tl13's record (`docs/spec-findings-tl13.md`, `wave-48.md`).

§1–§3 are committed before any gate run on kasumi; §3 is not edited after.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl14/` on kasumi and the lane's scratch directory;
  no deletion in any tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1. `tree-sitter generate`, `tree-sitter test` and the
  corpus gate run on kasumi under `~/lanes/tl14/`, **each with a private
  `TREE_SITTER_LIBDIR`** (`~/lanes/tl14/lib-*`), never the shared
  `~/.cache/tree-sitter/lib/wolf.so` (tl13's false green).
- No merge, no rebase-merge; no `2>/dev/null` on a checkout; the branch is
  asserted before every commit.
- No "seen red" without a run id, sha, path or captured log in the same
  paragraph. **Both failure branches of the gate are seen red** (the
  pass-count branch at FLOOR+1, the ERROR-node branch with a planted file in a
  scratch copy), each with its log path.
- The floor ratchets to the measured count, never down, never above it.
- Kill only pids this lane started — never a pattern or a process group.
- CI read with `gh run view`; any watch uses `--interval 60`. No attribution
  trailers.

## 2. Inputs, re-derived 2026-09-28 against origin

| input | row said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `388bf91` | `388bf91` (`origin/trunk`, "changelog: tl13") | none |
| wolf-lang v0.2.18 | `ec56a08f` | `v0.2.18^{commit}` = `ec56a08f04ff318ea659fd58683f7ae4f22dc7a5`; wolf-lang `origin/trunk` is the **same** commit, so the gate's default-branch checkout and the tag are one tree — one number, not two | none |
| the pin | "pinned to 0.2.18" | as tl13 found, **there is no pin file here**: the gate reads wolf-lang's default branch, and the recorded pin is the ratchet paragraph in `script/parse-wolf-corpus.sh` plus `CHANGELOG.md`. "Pinned" means that record moves from `02afce84` to `ec56a08f` | wording (as tl13) |
| the ratchet | — | `script/parse-wolf-corpus.sh:161`, `FLOOR="${FLOOR:-675}"` (`grep -n`) | line moved 142 → 161 (tl13's paragraph) |
| corpus size | — | **747** `.lu` at `ec56a08f` (`git ls-tree -r` over `corpus`), **707** at `02afce84`: +40 files added and 2 modified (`elem_move_one_place.lu` +16 −19, `list_session_struct.lu` +8 −1), all under `corpus/memory/` — the 40 are 7 `ctl_store_order*` (s183), 24 `elem_*` (eg01/eg01b), 9 `mut_param_*` (s184) | — |
| exclusions | — | the script's own exclusion rule (header `check: fail(E0[012]`, plus the D59 `entry.lu` rule) emulated over `git archive` trees: **32 at both tags, 0 new**; gated **675** at `02afce84` (reproduces tl13's measured 675, so the emulation fires) and **715** at `ec56a08f`; 0 gated files removed | — |
| grammar | — | `spec/grammar.ebnf` blob `3f24d076fde0079aa3b6260b8cbadc97a35a9eff` at **both** `02afce84` and `ec56a08f`; `spec/01-grammar.md` unchanged across the span (`git diff --numstat` empty; the spec diff is `02-memory-model.md` +123 −8 and `anchors.json` +1 only) | none |
| the receiver at the tag | — | run **36333447636**, `repository_dispatch` `wolf-lang-corpus`, gate job 16:29:50→16:33:44Z (3m54s, inside the 122–340 s band), checked out wolf-lang `ec56a08f` (its log), `715 files gated, 32 parse-tier counter-examples excluded`, `PASS … (715 files, floor 675)`. Sent by wolf-lang's release run 36333436269 (`v0.2.18`, success). Schedule run 36431904676 (2026-09-28) the same: 715, PASS | the dispatch works; the item is the floor |
| open issues | — | #20 (`x = take (v)` parses as a call) open, not this lane's | — |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`) | — |

## 3. Prediction, committed before any gate run

**What is not a prediction.** CI's receiver already printed 715 at
`ec56a08f` (run 36333447636), and the exclusion emulation above says the same;
the floor number is a re-measurement.

1. **The floor at v0.2.18 = trunk is 715.** Local run on kasumi with a private
   `TREE_SITTER_LIBDIR`: `715 files gated, 32 … excluded`, PASS. `FLOOR=715`
   passes; `FLOOR=716` fails "checkout suspect" on the same 715 files.
   *Falsifier:* any count other than 715, or any ERROR node.
2. **The ERROR-node branch reds** on a scratch copy of the corpus with one
   planted unparseable file: 716 gated, `FAIL: 1 file(s)`, the file named, exit 1.
3. **The grammar does not move.** `tree-sitter generate` leaves `src/`
   byte-identical (`git diff --exit-code -- src/` clean) and `tree-sitter test`
   passes with the same case count as trunk `388bf91` (counted from the run, not from the files). No `grammar.js` edit.
   *Falsifier:* any `src/` diff or any test failure.
4. **None of the 40 new (or 2 modified) files needs a grammar change**: s183's
   `ctl_store_order*` spell index stores (plain and `take`) tl13 already
   admitted; eg01's `elem_*` and s184's `mut_param_*` are memory-tier witnesses
   (E1001/E1014-class or `run`) over existing syntax. EG2's
   `swap(mut xs[0], mut xs[1])` is wave 50's eg02 and is **not** in 0.2.18.

## 3, scored (written after the measurement; the section above is unedited since `da2a396`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | 715 gated, 32 excluded, PASS; `FLOOR=715` passes, `FLOOR=716` fails on the same 715 | `gate-default.log`: `715 files gated, 32 parse-tier counter-examples excluded` / `PASS … (715 files, floor 675)`; `gate-floor-715.log` PASS rc 0; `gate-floor-716.log` `FAIL: only 715 file(s) gated — the floor is 716; checkout suspect` rc 1 | **yes** |
| 2 | a planted file reds the ERROR branch: 716 gated, `FAIL: 1 file(s)`, named | `gate-planted.log`: `716 files gated`, `FAIL: 1 file(s) with ERROR/MISSING nodes:` `…/planted-corpus/tl14_planted_error.lu`, rc 1 | **yes** |
| 3 | `generate` leaves `src/` byte-identical; `test` passes at trunk's count | `ts-generate.log`: `generate rc 0`, `git status --porcelain -- src/` empty, `src diff rc 0`; `ts-test.log`: `Total parses: 133; successful parses: 133; failed parses: 0`, `test rc 0` (133 = tl13's count at `388bf91`) | **yes** |
| 4 | no grammar change for the 40 new / 2 modified files | zero ERROR nodes over all 715; no `grammar.js` edit | **yes** |

Four of four. The committed default (`FLOOR="${FLOOR:-715}"`, blob `867f73cc`
of `script/parse-wolf-corpus.sh`, hash checked identical on kasumi) was run
again **after** the edit, with no `FLOOR` in the environment:
`gate-committed-default.log` PASS at 715 (floor 715), rc 0; and on a scratch
copy with one gated file removed (`memory/mut_param_restore_whole.lu`),
`gate-committed-shrunk.log`: `714 files gated` / `FAIL: only 714 file(s)
gated — the floor is 715; checkout suspect`, rc 1. So the number the default
branch meets is the number committed, and the committed default bites one file
below it.

**Private libdir, checked.** Every run above exported
`TREE_SITTER_LIBDIR=~/lanes/tl14/lib-ts`; that directory's `wolf.so` (sha256
9afe1d6eaba8975caadefc93eda45ade686a871ffa589d90e3efee7bad22b105) was built at
20:44 on 2026-09-28, and the shared `~/.cache/tree-sitter/lib/wolf.so` still
carries its 2026-09-26 18:19 mtime — untouched.

**A side note on the install.** `npm ci` on kasumi (node v26.8.1) exited 0
and left `node_modules/tree-sitter-cli/tree-sitter` **absent**: the package's
postinstall download failed silently, and `install.js` run by hand printed
"Downloading …" and wrote nothing. The binary was fetched with `curl` from the
same v0.26.13 release URL; its sha256
ad369a4df2bb1ebf5cd37045d34bdc9160b9351f92520399106d8e689cac00af is
identical to tl13's copy (`~/lanes/tl13/ts/node_modules/tree-sitter-cli/tree-sitter`).
An install step reporting success having installed nothing is tl11's
chocolatey lesson again; CI's `npm ci` on ubuntu is unaffected (its runs
print the parse counts).

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl14/`; the clone the runs used is
`~/lanes/tl14/ts` at `da2a396` (runs 1–3) and the same tree plus the
committed `script/parse-wolf-corpus.sh` blob `867f73cc` (the committed-default
pair). The corpus is `~/lanes/tl14/wolf-lang`, a depth-1 clone at
`v0.2.18` = `ec56a08f` (747 `.lu`).

| claim | artifact |
|---|---|
| floor 715 at v0.2.18 = trunk | `gate-default.log`, `gate-floor-715.log`, `gate-committed-default.log` |
| pass-count branch red | `gate-floor-716.log` (rc 1), `gate-committed-shrunk.log` (rc 1) |
| ERROR-node branch red | `gate-planted.log` (rc 1, `tl14_planted_error.lu` named) |
| grammar unchanged | `ts-generate.log` (`src diff rc 0`); `spec/grammar.ebnf` blob `3f24d076fde0079aa3b6260b8cbadc97a35a9eff` at `02afce84` and `ec56a08f` |
| corpus tests | `ts-test.log` (133/133) |
| the receiver already met 0.2.18 | run 36333447636 (`repository_dispatch`, wolf-lang `ec56a08f`, 715 gated, floor 675), sent by wolf-lang release run 36333436269; schedule run 36431904676 the same |
| private libdir | `~/lanes/tl14/lib-ts/wolf.so` sha256 9afe1d6e…, shared cache mtime 2026-09-26 |
| CI at the head | the PR's `pull_request` run and a `workflow_dispatch --ref tl14` run, ids in the PR body |

## 5. Done-when

- branch `tl14` on origin; PR open, unmerged, its body carrying the five
  sections
- CI green at the head sha (`gh run view`), and a `workflow_dispatch --ref
  tl14` run of the same gate green against wolf-lang `ec56a08f` with
  `715 files gated` in its log
- the §3 commit (`da2a396`) precedes the ratchet commit
- the floor at 715, both failure branches seen red with captured logs
- `/private/tmp/tl14-ts` removed; `~/lanes/tl14/` pruned to its logs; no
  orphan process
