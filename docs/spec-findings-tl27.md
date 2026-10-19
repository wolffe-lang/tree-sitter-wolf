# tl27 — the floor at 0.2.33

wolf-lang cut **0.2.33** on 2026-10-19 (`v0.2.33` = `85dab5d7`, release
417610226). This repository last moved at 0.2.32 (tl25, `0c18cfb`, floor
1116). This file is lane tl27's contract and record for tree-sitter-wolf:
whether anything 0.2.33 added to the surface needs a grammar rule or a
highlight pattern, the corpus floor at 0.2.33, and tree-sitter-wolf#32 (the
receiver that did not fire at v0.2.32). The wolf-lsp half (the pin, the
vendored spec with 0.2.33's five prelude names, the transcripts and the six
smokes) is wolf-lsp `docs/PIN-0233.md` on its branch `tl27`. Contract:
planning `sprints/lsp/tl27-the-editors-at-0233.md` (`73e7c1d`); rules
`sprints/compiler/s243-the-hub-and-the-races.md` ("Forbidden / rules") with
0.2.33's toolchains, `sprints/crawl-54.md` down to `wave-45.md`; template
tl25 (`docs/spec-findings-tl25.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run in this lane; §3 is not edited after this
commit. Everything in §2 was read from git objects (wolf-lang's tags), the
GitHub API, the downloaded archives and CI logs.

## 1. Forbidden, absolutely

- No grammar rule and no highlight query changed without a corpus case that
  shows it. **Prelude functions do not highlight as builtins** (ruling #77,
  item 4): no `@function.builtin` pattern over prelude names.
- No `rm` outside `~/lanes/tl27/`; no `git add -A`; nothing under
  `~/.claude`; nothing in another org's repository.
- No build on nomad-1: `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl27/`, each with a private
  `TREE_SITTER_LIBDIR` (tl13). Lanes install no host tool: the CLI is the
  0.26.13 binary tl25 used, accepted only if its sha256 is the one tl14–tl25
  recorded (`ad369a4d…`).
- No merge, no tag, no issue filed or closed; the branch asserted before
  every commit; no attribution trailers.
- The toolchain is the release by digest, each digest read twice, never
  wolf-lang's trunk. The floor ratchets to the measured count at the
  release, never down, never above it; a count of files is compared as a
  set of paths both ways (wolf-lang#177). No "seen red" without a run id,
  sha or captured log in the same paragraph.

## 2. Inputs, re-derived 2026-10-19 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `0c18cfb` (tl25's merge) | `0c18cfb0` (tl25's plant revert), by `git fetch` on nomad-1 and the clone on kasumi; open issues: #27, #32 | none |
| wolf 0.2.33 | `v0.2.33` at `85dab5d7` (release 417610226) | `v0.2.33^{commit}` = `85dab5d7e597680d6fd7034f1d7ed2acb9a92f97` (annotated tag object `56110e4f…`), by `git rev-parse` on nomad-1 and `git ls-remote` on kasumi; release **417610226**, `draft=false`, published 2026-10-19T18:37:53Z, the only release carrying the tag, four assets (API digests): linux x86-64 `4f955e8d…`, linux aarch64 `24cde9e4…`, macOS arm64 `9152dbd1…`, windows `96774801…`. The linux x86-64 and macOS archives downloaded on kasumi and hashed twice (`sha256sum`, `openssl dgst`), both equal to the API's; `wolf 0.2.33 (wolfgang, pin 85dab5d)` | none |
| lupin 0.1.54 | `v0.1.54` at `0e536e8` | `v0.1.54^{commit}` = `0e536e8fb4518eaa798ac426901ab81275db5c9f` (tag object `9c98d445…`); release 415937354 (linux x86-64 `175df238…`, macOS `9cd14db7…`, matched twice). This repository never runs lupin | none |
| **"the grammar re-checked against 0.2.33"** | expect nothing: s246 added calls, not syntax | **Nothing grammatical changed in 0.2.33.** At `v0.2.32` and `v0.2.33`: `spec/grammar.ebnf` blob `29d5de10`, `spec/01-grammar.md` blob `d1bd4ff9`, the compiler's parser `crates/wolf_parse/src` tree `03b61b38`, its lexer `crates/wolf_lex/src` tree `9166b9fd`, the formatter `crates/wolf_fmt/src` tree `c29a0c87`, all identical (and identical at v0.2.30–v0.2.32, tl25). Under `crates/wolf_parse` and `crates/wolf_lex` (v0.2.32..v0.2.33, 42 commits) the only change is four snapshot files under `tests/snapshots/`: `os__signal_one_rows` added and `os__group_rows` modified, one per crate each, the snapshots of the two corpus files below. The CHANGELOG names no token, keyword, operator or production: five builtins (calls: `os_signal_ignore_one`, `os_signal_default_one`, `os_exit_signal`, `os_wait_status_core`, `os_wait_poll_core`), `os_signal_text(0)`'s words, a sent SEGV's disposition, the wait_fd wake pipe at start, the std pin | no rule is owed |
| prelude names | 0.2.33's five | `spec/prelude.json` blob `18ddf784` (v0.2.32) → `41ac122f` (v0.2.33), `.names` as `(name, kind)` sets both ways: 182 → 187, **5 added, 0 removed, 0 entries changed**, all `function`, all `[os.host.sigs]`, all `w0304`: the five above. Kinds at v0.2.33: `function` 147, `builtin_type` 18, `type` 8, `intrinsic` 8, `provisional` 6, so the type names (`builtin_type` + `type`) stay **26**. `queries/highlights.scm` paints prelude names only as `@type.builtin`; a call paints `@function`. Ruling #77 (4) keeps it so | nothing owed to the queries |
| **the receiver at v0.2.33 (#32)** | check whether it fired and why | **It fired.** wolf-lang's release run 39302694537 (`push` of `v0.2.33`, 2026-10-19T18:27:48Z), job "dispatch tree-sitter-wolf's corpus gate" (118231708809), log: `since v0.2.32: 2 file(s) moved under spec/grammar.ebnf, spec/01-grammar.md, corpus/` / `dispatched wolf-lang-corpus to wolffe-lang/tree-sitter-wolf for v0.2.33 (85dab5d7…)` / `receiver run: …/runs/39302827720`. Here run **39302827720** (`repository_dispatch` `wolf-lang-corpus`, 2026-10-19T18:28:45Z, trunk `0c18cfb0`, job `gate` 118232167876, 4m46s): `wolf-lang corpus: 1117 files gated, 38 parse-tier counter-examples excluded` / `PASS: zero ERROR nodes across the corpus (1117 files, floor 1116)` | the floor is 1 below the release count |
| **the receiver at v0.2.32 (#32)** | — | **It was not owed.** The same job in release run 39111522633 (`v0.2.32`): `since v0.2.31: 0 file(s) moved under spec/grammar.ebnf, spec/01-grammar.md, corpus/` / `##[notice]v0.2.32 moves nothing the grammar mirror parses; no dispatch`. The sender is written that way (`release.yml` at `v0.2.33`, the `grammar-mirror` job: "Sent at release time, and only when this tag moved what the mirror parses"); at v0.2.31 (run 39070710901) it read 14 files and dispatched 39070721959. #32's observation is true and is the design, not a fault | #32 answered; close by hand |
| corpus size | — | `corpus/**/*.lu` by `git ls-tree`: 1154 at `v0.2.32`, **1155** at `v0.2.33`; as path sets v0.2.32 → v0.2.33: **1 added, 1 modified, 0 removed**: added `os/signal_one_rows` (`run(exit=0, …)`, so gated; no `<<`/`>>`), modified `os/group_rows` (its `text_zero` row and print line removed, a comment; s246, wolf-lang#787). Neither parse-tier, so 38 excluded and 1117 gated, as the receiver printed | — |
| tests | — | `test/corpus`: 150 cases; no `test/highlight/` (#27 open) | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`; kasumi has no `tree-sitter` on `PATH`; tl25's `~/lanes/tl25/tsbin/tree-sitter` copied into `~/lanes/tl27/tsbin/`, sha256 `ad369a4d…` (`setup.log`), tl14–tl25's digest | — |
| tl25's verdicts | — | kasumi `~/lanes/tl25/g1/verdicts.txt` (1154 lines, ERR 22; identical to its `g2/verdicts-head.txt` by `cmp`), over the 0.2.32 corpus at the grammar trunk still carries; copied to `~/lanes/tl27/tl25-verdicts.txt` | — |

## 3. Prediction, committed before any run

**Not a prediction:** 1155 files, 38 excluded, 1117 gated and a green gate
at trunk's grammar are §2 inputs (the receiver printed them).

1. **Per-file verdicts at trunk's grammar over the v0.2.33 corpus, as path
   sets against tl25's**: 0 paths only in tl25's; the 1154 shared paths keep
   their verdict (`os/group_rows` stays `ok`); exactly 1 new path,
   `os/signal_one_rows`, `ok`; `ERR` stays 22 (tl25's 22 paths); 1155 paths.
   *Falsifier:* a shared path changing verdict, an added `ERR`.
2. **`generate` is inert and the tests hold**: `src/` byte-identical after
   `tree-sitter generate`; `tree-sitter test` 150 of 150; the three query
   files load. No file under `grammar.js`, `src/`, `queries/` or `test/`
   changes in this lane.
3. **The five new names parse as plain calls and paint as `print` does**:
   a scratch file calling each name read from `spec/prelude.json` at the tag
   (the tag's list minus the v0.2.32 list wolf-lsp trunk vendors, never typed
   by hand) parses with no `ERROR`/`MISSING`; each callee captures `function`
   exactly once; no `function.builtin` capture anywhere.
4. **The gate's branches at the ratchet** (`FLOOR="${FLOOR:-1117}"`), over
   the v0.2.33 corpus: default passes `1117 files gated`, `floor 1117`;
   `FLOOR=1118` fails `checkout suspect`, rc 1; a copy with one gated file
   removed fails `only 1116 … floor is 1117`, rc 1; a copy with
   `fn main() -> !int { let ( = }` planted gates 1118 and fails
   `FAIL: 1 file(s)` naming it, rc 1.
5. **CI at the head** is green gating wolf-lang's trunk (1117 files or more:
   trunk may move past the tag), floor 1117; **a planted break goes red**:
   the default floor moved to 2000 reds the corpus step with `the floor is
   2000`; its revert is green.
