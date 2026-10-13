# tl20 — the floor at 0.2.29; nothing grammatical moved in three releases

wolf-lang cut **0.2.27**, **0.2.28** and **0.2.29** (2026-10-11 and
2026-10-12; `v0.2.29` = `6ffe7c60`, release 411040788). This repository last
moved at 0.2.26 (tl19, `e7388233`, floor 1019). This file is lane tl20's
contract and record for tree-sitter-wolf: whether anything those three
releases added to the surface needs a grammar rule or a highlight pattern,
and the corpus floor at 0.2.29. The wolf-lsp half (the pin, the vendored
spec, the transcripts, the std-loading server) is wolf-lsp `docs/PIN-0229.md`
on its branch `tl20`. Contract: planning
`sprints/lsp/tl20-the-editors-at-0229.md` (`42ae4fb`); rules
`sprints/wave-53.md` down to `wave-45.md`; template tl19
(`docs/spec-findings-tl19.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run in this lane, and before any archive is
downloaded; §3 is not edited after this commit. Everything in §2 was read
from git objects (wolf-lang's tags), the GitHub API and CI logs.

## 1. Forbidden, absolutely

- No grammar rule and no highlight query changed without a corpus case that
  shows it. No `rm` outside `~/lanes/tl20/` (kasumi and nomad-1); no deletion
  in any tree this lane did not create; no `git add -A`; nothing under
  `~/.claude`; nothing in another org's repository.
- No build on nomad-1. `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl20/`, each with a private
  `TREE_SITTER_LIBDIR`. Lanes install no host tool: the tree-sitter CLI is the
  0.26.13 binary already on kasumi in an earlier lane's `node_modules`,
  accepted only if its sha256 is the one tl14–tl19 recorded (`ad369a4d…`).
- No merge, no tag, no issue filed or closed; the branch is asserted before
  every commit; no attribution trailers.
- The toolchain is the release archive by digest, each digest read twice,
  never wolf-lang's trunk: trunk holds prelude names no release carries.
- No "seen red" without a run id, sha, path or captured log in the same
  paragraph. The floor ratchets to the measured count at the release, never
  down, never above it. A count of files is compared as a set of paths both
  ways (wolf-lang#177).
- Kill only pids this lane started; kasumi jobs launched with `setsid` and a
  pid file; waits print at least every five minutes; `gh run view`, never
  `gh run watch` without `--interval 60`.

## 2. Inputs, re-derived 2026-10-13 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | — | `e7388233` (tl19's plant revert); open issues: #27 only | none |
| wolf 0.2.29 | `v0.2.29` at `6ffe7c60` | `v0.2.29^{commit}` = `6ffe7c6056eeb8c661b37e38d99b91166e8c1add` (annotated tag object `6f732110…`), read from `git ls-remote` and from the release API; release **411040788**, `draft=false`, published 2026-10-12T23:22:55Z, four assets, exactly one release on the tag; linux x86-64 `ae466e85…`, linux aarch64 `584b8fc2…`, macOS arm64 `a79928ba…`, windows `e8a37a7f…` | none |
| lupin 0.1.52 | `v0.1.52` at `025428b` | `v0.1.52^{commit}` = `025428b725a35bfbc53745d4166817ff3053c0fd`; release 410845419, five assets (linux x86-64 `f5194b74…`). This repository never runs lupin | none |
| wolf-lang trunk | "not trunk" | `b407c73b`, ahead of the tag: 1132 corpus files against the tag's 1130, and three prelude names no release carries (`os_term_size`, `os_term_chars`, `os_signal_wait_fd`). **The CI gate here reads wolf-lang's default branch**, as tl13–tl19 found, so CI gates 1094 files while the release holds 1092 | the floor is set from the release, CI passes above it |
| **"the grammar parses everything 0.2.27 to 0.2.29 added to the surface"** | say if nothing grammatical changed | **Nothing grammatical changed.** At `v0.2.26`, `v0.2.27`, `v0.2.28` and `v0.2.29`: `spec/grammar.ebnf` is blob `29d5de10` at all four; `spec/01-grammar.md` blob `d1bd4ff9` at all four; the compiler's parser `crates/wolf_parse/src` is tree `03b61b38` and its lexer `crates/wolf_lex/src` tree `9166b9fd` at all four. The three CHANGELOG entries (1,576 lines) name no token, keyword, operator or production: they add builtins (calls), runtime behaviour, refusals (E1010) and the std in the archive | no rule is owed |
| **"the new prelude names highlight as builtins (the fs mode/links/times names of 0.2.28, the signal and pid names of 0.2.29)"** | names to add to the queries | `spec/prelude.json` `.names`, as `(name, kind)` sets both ways: v0.2.26 blob `21a2561c` 134 → v0.2.27 151 (+17) → v0.2.28 159 (+8) → v0.2.29 blob `f0fd9c54` 164 (+5); 0 removed; **all 30 added names are `kind: function`**; the type names (`builtin_type` + `type`) are 26 at every tag. `queries/highlights.scm` (blob `d2e3ff70`) holds prelude names in exactly three patterns, all `@type.builtin`: the closed any-position list of 17 prims, `range`, and `never`. It holds **no function name**: there is no `@function.builtin` pattern, and `print(…)` paints `@function` through `(call_expression function: (identifier) @function)`, as every call does. So the list "prelude names at the tag minus what the queries hold", restricted to the kinds the queries paint, is **empty** | **drift: no name is owed to the queries.** A call of a new builtin paints as `print` does. Painting prelude functions as builtins would be a new capture class over all 124 functions, a design change nobody ruled; reported, not made |
| the receiver at 0.2.29 | — | run **38315479145** (`repository_dispatch`, 2026-10-12T22:14Z, trunk `e7388233`): `Total parses: 150; successful parses: 150`, `wolf-lang corpus: 1092 files gated, 38 parse-tier counter-examples excluded`, `PASS … (1092 files, floor 1019)`. The scheduled run 38411129728 (2026-10-13) gates 1094 at wolf-lang trunk, PASS | the gate is green; the floor is 73 below the release count |
| corpus size | — | `corpus/**/*.lu` by `git ls-tree`: 1057 at `v0.2.26`, 1089 at `v0.2.27`, 1129 at `v0.2.28`, **1130** at `v0.2.29`. v0.2.26 → v0.2.29 as path sets: **73 added, 0 removed, 5 modified** (`conc/atomic_counter.lu`, `conc/chan_struct_payload.lu`, `conc/reason_interp.lu`, `net/spawn_accept.lu`, `os/signal_supervisor.lu`). Added by directory: memory 18, conc 13, typecheck 12, faults 7, json 7, fs 5, os 5, comptime 4, link 2. None of the 73 carries a parse-tier `check: fail(E0[012]` directive, so 38 excluded as at v0.2.26 and 1092 gated | — |
| tests | — | `test/corpus`: 150 cases over 11 files; no `test/highlight/` (#27 open: the CLI cannot place an assertion in this grammar) | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`. kasumi has no `tree-sitter` on `PATH`; the pinned binary exists at `~/lanes/tl11/ts/node_modules/tree-sitter-cli/tree-sitter`, sha256 `ad369a4d…` = tl14–tl19's recorded digest. The lane copies that file into `~/lanes/tl20/tsbin/` and re-hashes it; nothing is downloaded or installed | disclosed |
| tl19's verdicts | — | kasumi `~/lanes/tl19/g2/verdicts-head.txt`: 1057 lines, 22 `ERR`, over the 0.2.26 corpus at the grammar this trunk still carries | — |

## 3. Prediction, committed before any run

**What is not a prediction.** 1130 files, 38 excluded, 1092 gated and a green
gate at trunk's grammar are §2 inputs (the receiver printed them).

1. **Per-file verdicts at trunk's grammar over the v0.2.29 corpus, as path
   sets against tl19's.** 0 paths only in tl19's; the 1057 shared paths keep
   tl19's verdict, the 5 modified files included; exactly 73 paths are new,
   **all 73 `ok`**; `ERR` stays 22. *Falsifier:* any shared path changing
   verdict, any added `ERR`, a path count other than 1130.
2. **`generate` is inert and the tests hold**: `tree-sitter generate` leaves
   `src/` byte-identical; `tree-sitter test` passes 150 of 150; the three
   query files load. No file under `grammar.js`, `src/`, `queries/` or
   `test/` changes in this lane. *Falsifier:* `src/` moving, a failing case.
3. **Every new prelude name parses as a plain call and paints as `print`
   does.** A scratch file (not committed: no rule or query changes, so no
   corpus case is owed) calling each of the 30 names read from
   `spec/prelude.json` at the tag parses with no `ERROR` or `MISSING`, and
   `highlights.scm` captures each callee as `function`, exactly 30 times,
   with no `function.builtin` capture anywhere. *Falsifier:* an `ERROR`, or
   any of the 30 capturing something else.
4. **The gate's branches at the ratchet** (`FLOOR="${FLOOR:-1092}"`
   committed), over the v0.2.29 corpus: the committed default passes,
   `1092 files gated`, `floor 1092`; `FLOOR=1093` fails `only 1092 file(s)
   gated — the floor is 1093; checkout suspect`, rc 1; a scratch corpus with
   one gated file removed fails `1091 … floor is 1092`, rc 1; a scratch
   corpus with an unparseable file planted gates 1093 and fails
   `FAIL: 1 file(s)` naming it, rc 1.
5. **CI at the head** (`pull_request`) is green and gates wolf-lang's trunk:
   `1094 files gated` or more (trunk may grow while the lane runs), `floor
   1092`. **A planted break goes red in CI**: one commit moving the default
   floor to 2000 (above anything trunk can reach in a day, so the plant
   cannot pass by accident) reds the `wolf-lang corpus at zero ERRORs` step
   with `the floor is 2000`; its revert is green.

## 3, scored (written after the measurement; §1–§3 above are unedited since `3b95c0b`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | path sets against tl19's: 0 removed, 0 changed, 73 added, all `ok`; `ERR` 22; 1130 paths | `g1/verdicts-compare.txt` (head `3b95c0b`, corpus `6ffe7c60`): `tl19 paths 1057; now 1130; ERR now 22`, `only tl19 (removed)` empty, `same path, different verdict` empty, `added 73; added-ok 73; added-ERR:` empty. The trunk grammar's gate, `g1/gate-trunk.log`: `1092 files gated, 38 … excluded` / `PASS … (1092 files, floor 1019)`, rc 0 — the receiver's 38315479145 reproduced | **yes** |
| 2 | `generate` inert; 150 of 150; the three queries load; nothing under `grammar.js`, `src/`, `queries/`, `test/` changes | `g1/ts-generate.log` and `g2/ts-generate.log`: `generate rc 0`, `src diff rc 0`; `g1/ts-test.log`, `g2/ts-test.log`: `Total parses: 150; successful parses: 150`; `g2/queries.log`: highlights, locals, injections rc 0; `g2/head.txt`: `src` tree `e8d4fd5e`, `queries` tree `cf647eb2`, `test` tree `884d5bfa`, `grammar.js` blob `2cac20e7`, each equal to `e7388233`'s; `g2/diff-vs-trunk.stat`: this file and `script/parse-wolf-corpus.sh` only | **yes** |
| 3 | the 30 new names parse as calls and each captures `function`; no `function.builtin` anywhere | `g1/new-names.txt`: the tag's list (blob `f0fd9c54`) minus the v0.2.26 list (blob `21a2561c`) is 30 names, `30 function`; `g1/calls.lu` (one call a line, `print("x")` as the control) parses with 0 `ERROR`/`MISSING` (`g1/calls-tree.txt`, rc 0); `g1/calls-summary.txt`: every one of the 30 callees captures `function` exactly once, `print` the same, `function.builtin captures anywhere: 0`. The CLI's `query` also lists the fallback `(identifier) @variable` match on each callee, for `print` too (two lines a name; a first-match-wins engine shows `function`), which my summary line counted as "not exactly one capture" for all 31: the check I wrote was stricter than the prediction, the prediction's own terms hold | **yes** |
| 4 | default green at 1092; `FLOOR=1093` red; shrunk red; planted red | at `83cf07d` (script blob `ba6256cc`): `g2/gate-committed-default.log` `PASS … (1092 files, floor 1092)`, rc 0; `g2/gate-floor-1093.log` `FAIL: only 1092 file(s) gated — the floor is 1093; checkout suspect`, rc 1; `g2/gate-committed-shrunk.log` (`os/signal_shell_rows.lu` removed from a scratch copy) `1091 files gated` / `FAIL: only 1091 … floor is 1092`, rc 1; `g2/gate-planted.log` `1093 files gated` / `FAIL: 1 file(s) …` / `…/tl20_planted_bad_let.lu`, rc 1; `g2/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0 | **yes** |
| 5 | CI green at the head gating wolf-lang's trunk at floor 1092; the floor-2000 plant red | run ids in the PR body | — (see the PR) |

Four of four scored before CI held. **What a reader in helix or zed sees
change: nothing.** Three releases added no syntax; their thirty new builtins
are calls and paint as calls, as `print` always has. What changed here is the
floor, 1019 → 1092, so the gate cannot lose the 73 files the three releases
added without saying so.

**The names, by release, from `spec/prelude.json` at the tags (all
`function`, none painted as a builtin by any pattern):** 0.2.27 — `fs_stat`,
`fs_lstat`, `fs_read_link`, `fs_read_dir_entries`, `env_unset`, `os_exec`,
`os_signal_ignore`, `os_signal_default`, `os_signal_poll`, `os_spawn_job`,
`os_proc_pid`, `os_wait_status`, `os_pgid`, `os_term_foreground`,
`os_term_set_foreground`, `os_term_mode`, `os_term_set_mode`; 0.2.28 —
`fs_set_mode`, `fs_open_perm`, `fs_create_dir_mode`, `fs_symlink`,
`fs_link`, `fs_set_times`, `fs_truncate`, `os_umask`; 0.2.29 —
`os_signal_ignored`, `os_signal_send`, `os_signal_number`, `os_pid`,
`os_ppid`. wolf-lang's trunk adds `os_term_size`, `os_term_chars` and
`os_signal_wait_fd`, which no release carries and nothing here names.

**A decision this lane did not take.** The contract asks that the new names
"highlight as builtins". This grammar has never painted a prelude function
as a builtin, so there was no list to extend. Doing it means a new pattern,
`@function.builtin` on a call whose callee is one of the prelude's 124
functions: it would repaint every `print(…)` in every wolf file, it needs a
rule for a program that declares its own `fn` of the same name (W0304 warns,
it does not refuse), and it needs a gate that holds the list to
`spec/prelude.json`, as wolf-lsp's `type-names-check` holds the type lists.
That is a ruling and a lane, not a pin bump.

**Private libdirs, checked** (`g1/libdirs.txt`, `g2/libdirs.txt`): both
`wolf.so` `f3bc57d8…`, the digest tl18 and tl19 recorded (`src/` has not
moved since `66a677f0`). The shared `~/.cache/tree-sitter/lib/wolf.so` still
carries its 2026-09-26 18:19 mtime.

### §2 corrected after the commit

- None of §2's numbers moved. The two drifts §2 names stand: no rule is
  owed, and no name is owed to the queries.
- The tree-sitter CLI was copied from `~/lanes/tl11/ts/node_modules/` on
  kasumi (`setup.log`: sha256 `ad369a4d…`, `tree-sitter 0.26.13`), not
  downloaded; the brief says a lane stops rather than install a missing host
  tool, and this one was present.

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl20/`. The clone the runs use is
`~/lanes/tl20/ts`; the corpus is `~/lanes/tl20/wolf-lang`, a depth-1 clone at
`v0.2.29` = `6ffe7c60` (1130 `.lu`); the tree-sitter binary is
`~/lanes/tl20/tsbin/tree-sitter`.

| claim | artifact |
|---|---|
| the acquisition: tags by `ls-remote`, archive digests = the API's, `wolf --version`, `wolf prelude --json` = the tag's blob, the CLI's digest | `setup.log`, `acquire/members.txt` |
| nothing grammatical moved | wolf-lang blobs and trees at the four tags (§2); `g1/verdicts-compare.txt`; receiver run 38315479145 |
| trunk's grammar over 0.2.29: 1092 gated, PASS; verdicts against tl19's | `g1/gate-trunk.log`, `g1/verdicts.txt`, `g1/verdicts-compare.txt`, `tl19-verdicts-head.txt` |
| the 30 names, their kind, their trees and captures | `g1/new-names.txt`, `g1/new-names-head.txt`, `g1/calls.lu`, `g1/calls-tree.txt`, `g1/calls-captures.txt`, `g1/calls-summary.txt` |
| `generate` inert, 150/150, queries load, nothing but the script and this file differs from trunk | `g1/ts-generate.log`, `g1/ts-test.log`, `g2/ts-generate.log`, `g2/ts-test.log`, `g2/queries.log`, `g2/head.txt`, `g2/diff-vs-trunk.stat` |
| the gate's branches at the ratchet | `g2/gate-committed-default.log`, `g2/gate-floor-1093.log`, `g2/gate-committed-shrunk.log`, `g2/gate-planted.log`, `g2/verdicts-diff.txt` |
| commits | `3b95c0b` (this contract), `83cf07d` (the ratchet) |
| CI at the head; the planted red | run ids in the PR body |

## 5. Done-when

- branch `tl20` on origin; PR open, unmerged, its body carrying the five
  sections, commit-hash bullets and a test checklist; CI green at the head
  sha, read with `gh run view`; the planted red's run id cited
- this §3 commit precedes the ratchet commit
- no attribution trailers; `lane-audit.sh` run from the org directory, its
  exit status read directly
- `~/lanes/tl20/` on kasumi pruned to its logs; no orphan process
- listed to close (not closed by this lane): none
