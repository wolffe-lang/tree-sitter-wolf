# tl15 — the mode keywords, and the floor at 0.2.19

wolf-lang cut **0.2.19** on 2026-09-30 (`c2401f05`, release 400208356). This
file is lane tl15's contract and record for tree-sitter-wolf: part (1),
**tree-sitter-wolf#20** (`take` and `mut` lex as identifiers outside mode
positions, so `x = take (v)` parses as a call), and the grammar's half of
part (2), the floor at 0.2.19. The wolf-lsp half (the pin at 0.2.19 and
wolf-lsp#33, the editors' grammar pin) is wolf-lsp `docs/PIN-0219.md` on its
branch `tl15`, which carries its own five sections. Row: `wave-52.md` tl15;
template tl14 (`docs/spec-findings-tl14.md` here, wolf-lsp `docs/PIN-0218.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse` or
corpus-gate run on kasumi, and before any compiler probe; §3 is not edited
after this commit.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl15/` on kasumi and the lane's scratch directory;
  no deletion in any tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1. `tree-sitter generate/test/parse/query`, the corpus
  gate and every compiler probe run on kasumi under `~/lanes/tl15/`, **each
  with a private `TREE_SITTER_LIBDIR`** (`~/lanes/tl15/lib-*`, one per
  grammar tree), never the shared `~/.cache/tree-sitter/lib/wolf.so`.
- No merge, no rebase-merge; no `2>/dev/null` on a checkout; the branch is
  asserted before every commit.
- No "seen red" without a run id, sha, path or captured log in the same
  paragraph. Every new `:error` case is **seen red on trunk's grammar first**
  (the case committed before the grammar change, run against trunk's
  `grammar.js`), and **both failure branches of the corpus gate** are seen
  red, each with its log path.
- The floor ratchets to the measured count, never down, never above it.
- A count of files is compared as a **set of paths both ways**, never as a
  number alone (wolf-lang#177).
- Kill only pids this lane started — never a pattern or a process group.
- CI read with `gh run view`; any watch uses `--interval 60`; waits print at
  least every five minutes. No attribution trailers on any commit or PR.

## 2. Inputs, re-derived 2026-09-30 against origin

| input | row said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `7d18e441` | `7d18e441` (`origin/trunk`, "changelog: tl14") | none |
| wolf 0.2.19 | release 400208356 | `v0.2.19^{commit}` = `c2401f05f37794a078d2acf62f837dad98e5950d`; release id 400208356, `draft=false`, published 2026-09-30T16:02:58Z, target `trunk`, four assets; wolf-lang `origin/trunk` is the **same** commit, so the gate's default-branch checkout and the tag are one tree | none |
| the acquired compiler (the oracle for #20's compiler column) | — | `wolf-0.2.19-x86_64-unknown-linux-gnu.tar.gz` downloaded on kasumi, sha256 `9f3873d80118681a583a7bc00ead8d00186d447d2584aea75bc65a81f8238c8e` = the API's asset digest; `wolf --version` → `wolf 0.2.19 (wolfgang, pin c2401f0)` / `paired with lupin 0.1.42 (reference interpreter), pin ec56a08` | — |
| the pin here | "pinned at 0.2.19" | as tl13/tl14 found, **there is no pin file**: the gate reads wolf-lang's default branch, and the recorded pin is the ratchet paragraph in `script/parse-wolf-corpus.sh` plus `CHANGELOG.md`; "pinned" means that record moves from `ec56a08f` to `c2401f05` | wording (as tl14) |
| the ratchet | — | `script/parse-wolf-corpus.sh`, `FLOOR="${FLOOR:-715}"` | — |
| corpus size | — | **778** `.lu` under `corpus/` at `c2401f05` (`git ls-tree -r`), **747** at `ec56a08f`: 31 added, 1 modified (`memory/mut_elem_excl.lu`), 0 removed | — |
| the receiver at the tag | — | run **36740260729**, `repository_dispatch` `wolf-lang-corpus`, gate job 15:54:24→15:58:17Z (3m53s, in the 122–340 s band), checked out wolf-lang `c2401f05` (its log), `746 files gated, 32 parse-tier counter-examples excluded`, green against floor 715 — so trunk's grammar already parses all 746 at zero ERROR nodes | the item is the floor (715 → 746) |
| spec grammar | — | `spec/grammar.ebnf` blob `3f24d076fde0079aa3b6260b8cbadc97a35a9eff` at **both** v0.2.18 and v0.2.19; `spec/01-grammar.md` blob `520bcba2…` at both; `spec/anchors.json` blob `9be2d074…` at both. The span's only spec edit is `02-memory-model.md` (+25 −10) | none |
| where the spec puts a mode | — | `grammar.ebnf` at `c2401f05`: `param_mode ::= 'mut' \| 'take'` in `param` (incl. `self`), `closure_param`, `receiver ::= '(' param_mode expr ')'`, `call_arg ::= ('mut' \| 'take')? expr` (and `index_arg` through it), and the one moded store `index_place '=' 'take' expr`; `'&mut'` is a prefix operator. Both words are in `reserved_kw` (`[gram.inv.kw]`, 50 words), and `01-grammar.md` §1.3: "Identifiers that collide with reserved keywords do not parse". The one position a reserved word is a name is **member** (`member ::= IDENT \| INT \| reserved_kw`, "Member position is keyword-transparent … `.take(n)` … parse") | — |
| the compiler agrees | — | `crates/wolf_lex/src/lib.rs:174,178` at `c2401f05` maps `"mut"`/`"take"` to `Keyword::Mut`/`Keyword::Take` unconditionally; `crates/wolf_lex/src` and `crates/wolf_parse/src` are the same trees at v0.2.18 and v0.2.19 (`9166b9fd…`, `0bbed454…`) — the span moved only their snapshot tests | none |
| the grammar today | — | `word: $ => $.identifier`, **no `reserved` sets** (`src/parser.c`: `MAX_RESERVED_WORD_SET_SIZE 0`), ABI `LANGUAGE_VERSION 15`; `assignment_statement`'s moded arm carries `prec.dynamic(1, …)` only because `take (v)` also reads as a call (#20's body) | — |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`); `npm ci` on kasumi again left no binary (tl14's note), fetched from the v0.26.13 release URL, sha256 `ad369a4d…c00af` = tl14's | — |
| open issues | — | #20 open (this lane); wolf-lsp#33 open (this lane, other repo) | — |

## 3. Prediction, committed before any run

**What is not a prediction.** The receiver already printed 746 at
`c2401f05` with trunk's grammar (run 36740260729); that number is a
re-measurement.

1. **Red first.** Ten `:error` corpus cases are added before the grammar
   changes, one per spelling the compiler refuses and trunk's grammar
   accepts: `x = take (v)`, `s.f = take (v)`, `xs[0] = mut (v)`,
   `let y = take (v)`, a bare `take (v)` statement, a bare `mut (v)`
   statement, `let take = 1`, `let mut = 1`, `fn take() {}`, and
   `f(take)`. Against trunk's `grammar.js` **exactly those ten fail**
   (each parses clean), and every other case passes (trunk's 133 plus three
   positive guards below). *Falsifier:* any of the ten already ERRORs on
   trunk (it was not a #20 shape), or any other case fails.
2. **The compiler column.** With the acquired 0.2.19, `wolf build` on each
   of the ten shapes (inside `fn main() -> !int { … 0 }`, one directory per
   program; `fn take` at item level) exits non-zero with **E0201**. The
   positive guards (member names `xs.take(2)`, `p.mut`, `s.take = 1`, and
   every mode position) report **no** E0201 (at most E0301 for unbound
   names). *Falsifier:* a refused shape without E0201, or a guard with one.
3. **The fix.** `take` and `mut` become a tree-sitter reserved word set that
   applies in every state, with member position overriding it to an empty
   set. After it, all ten red cases pass, the three guards still pass
   (`xs.take(2)`, `p.mut`, `(mut xs).take(3)`, `s.take = 1` parse clean;
   every mode position — `fn f(mut x: T, take y: U)`, `mut self.{a}`,
   `fn(mut acc, x)`, `f(mut x, take y)`, `pool[mut p]`, `(take c).close()`,
   `xs[i] = take v`, `&mut y` — parses to the same tree), and
   `tree-sitter test` passes **146 of 146**. `src/node-types.json` is
   byte-identical to trunk's (the change is lexical; no node is added or
   removed). *Falsifier:* any failing case, or any `node-types.json` diff.
4. **The moded store's `prec.dynamic` retires.** With `take` reserved,
   `a.b[i] = take (v)` has one reading, so the arm parses the same without
   dynamic precedence (the existing case, unchanged expected tree).
   *Falsifier:* that case fails without it.
5. **The corpus holds.** At `c2401f05`, the branch grammar gates **746
   files, 32 excluded, zero ERROR nodes** — the same 746 paths as trunk's
   grammar (compared as path sets). `FLOOR=746` passes, `FLOOR=747` fails
   "checkout suspect" on the same 746. A planted file spelling #20's own
   shape (`x = take (v)` in a `fn main`) is **clean under trunk's grammar**
   (the gate passes with 747 gated — the blindness #20 describes) and
   **red under the branch's** (747 gated, `FAIL: 1 file(s)`, the file
   named, exit 1). *Falsifier:* any ERROR in the 746, any path-set
   difference, or the planted file ERRORing under trunk.
6. **No collateral beyond the corpus.** Over every `.lu` in wolf-std
   (`14f0ab2c`), boreutils (`d7909754`), lobo (`bfa9ad6a`) and wolf-book
   (`dadc38be`), the set of files with an ERROR/MISSING node is **identical**
   under trunk's and the branch's grammar (both ways). *Falsifier:* any file
   in one set and not the other.
7. **The queries.** `queries/{highlights,locals,injections}.scm` load against
   the branch grammar (CI's gate 3 shape) with no edit.

## 3, scored (written after the measurement; the section above is unedited since `8f8765e`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | exactly the ten new `:error` cases fail on trunk's grammar; every other case passes | `ts-red-trunk.log` (tests at `2343d27`, `grammar.js` blob `6c4c7687` = trunk's, `src/` tree `61248c31` = trunk's): **9 failures**, `Total parses: 146; successful parses: 137`, rc 1. The nine are the ten minus `f(take)`, which **already ERRORs on trunk** (`(ERROR (parameter_mode))` inside `arguments` — `take` is valid there as a mode, so the lexer returned the keyword and the missing operand errored). The three guards and all 133 old cases pass | **no — 9 of 10.** `f(take)` was not a #20 shape; the case stays as a guard of the refusal |
| 2 | every refused shape exits non-zero with E0201; no guard reports E0201 | `compiler/verdicts.txt` (wolf 0.2.19, pin c2401f0): all ten refused, exit 2, but only **seven** with E0201 — `let take = 1` and `let mut = 1` are **E0207** ("expected a pattern"), `fn take() {}` is **E0008** ("`take` is a reserved keyword, so it cannot name a function"). The guards: g1/g2 E0301 only, g3 E0301 + W1002 — no E0201 | **no, on the code — 7 of 10 E0201.** All ten are refused at the front end (E0xxx), which is what the `:error` cases assert; the code I named was too narrow |
| 3 | after the fix: 146/146, guards unchanged, `node-types.json` byte-identical | `fix1-test.log` then `fix2-test.log` and `ts-test.log` at the ratchet head: `146; successful parses: 146`, rc 0; `fix1-node-types.diff` and `fix2-node-types.diff` are 0 bytes; `src/parser.c` gains `MAX_RESERVED_WORD_SET_SIZE 2` (was 0), ABI unchanged at 15 | **yes** |
| 4 | the moded store's `prec.dynamic` retires with no case moving | `fix2-test.log` 146/146 without it (commit `2f4796c`). And the converse, so the claim is not vacuous: trunk's `grammar.js` with **only** `prec.dynamic` removed (`nodyn-trunk-test.log`) fails the two moded-store cases that spell `take (v)` (93 and 109) — the reservation is what makes the removal safe | **yes** |
| 5 | 746 gated, 32 excluded, zero ERRORs, the same paths as trunk; `FLOOR=746` passes, `747` fails; the planted #20 shape passes trunk's gate and reds the branch's | `gate-trunk.log` and `gate-branch.log`: `746 files gated, 32 … excluded`, PASS; `verdicts.diff` over all 778 corpus files (and 964 others) under both grammars: `diff rc 0`; `gate-floor-746.log` PASS rc 0; `gate-floor-747.log` `FAIL: only 746 file(s) gated — the floor is 747; checkout suspect` rc 1; `gate-planted-trunk.log` `747 files gated` / PASS rc 0 (#20's blindness, on the record); `gate-planted-branch.log` `747 files gated` / `FAIL: 1 file(s)` / `…/planted-corpus/tl15_planted_take_call.lu`, rc 1 | **yes** |
| 6 | the ERROR-file set over wolf-std, boreutils, lobo and wolf-book is identical under both grammars | `verdicts-summary.txt`: wolf-std 471 files 0/0, boreutils 28 0/0, lobo 160 0/0, wolf-book 305 files **2/2** (the same two paths); `verdicts.diff` empty | **yes** |
| 7 | the three query files load against the branch grammar | `queries.log`: highlights rc 0 (222 lines of captures), locals rc 0 (92), injections rc 0 (6), on `q-sample.lu` (every mode position plus the member guards) | **yes** |

Five of seven. The two misses are both in the column I wrote from memory of
#20's table rather than from the probe: `f(take)` was never in that table, and
the table's codes were for store shapes only. Neither miss moves the fix.

**The committed default** (`FLOOR="${FLOOR:-746}"`, `script/parse-wolf-corpus.sh`
blob `2f2cfcc6`, checked identical on kasumi at `71e5a28`) was run again after
the ratchet commit with no `FLOOR` in the environment:
`gate-committed-default.log` PASS at 746 (floor 746), rc 0; and on a scratch
copy with one gated file removed (`memory/mut_two_fields_one_region.lu`),
`gate-committed-shrunk.log`: `745 files gated` / `FAIL: only 745 file(s)
gated — the floor is 746; checkout suspect`, rc 1. `ts-generate.log` at the same
head: `generate rc 0`, `src diff rc 0` — the committed parser is what
`grammar.js` generates.

**Private libdirs, checked** (`libdirs.txt`). Trunk's grammar built to
`lib-trunk`/`lib-gtrunk` `wolf.so` sha256 `9afe1d6e…` — the same digest tl14
recorded for trunk's parser — and the branch's to `lib-fix2`/`lib-gbranch`
`0e88d1e9…`. The shared `~/.cache/tree-sitter/lib/wolf.so` still carries its
2026-09-26 18:19 mtime.

**The install note again.** `npm ci` on kasumi (node v26.8.1) exited 0 and left
no `tree-sitter` binary, as at tl14; the v0.26.13 binary was fetched by URL,
sha256 `ad369a4d…` = tl14's.

**The compiler's front-end codes, for the next reader of #20.** Measured with
the acquired 0.2.19 (`compiler/verdicts.txt`): a mode keyword in expression
position is E0201; in binding-pattern position E0207; as an item name E0008.
Member position accepts both words (`xs.take(2)`, `p.mut`, `s.take = 1` reach
resolve, E0301).

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl15/`. The clone the runs used is
`~/lanes/tl15/ts` (at `2343d27` for the red run, `2f4796c` for the gates,
`71e5a28` for the committed-default pair) plus a trunk worktree
`~/lanes/tl15/ts-trunk` at `7d18e44`; the corpus is `~/lanes/tl15/wolf-lang`, a
depth-1 clone at `v0.2.19` = `c2401f05` (778 `.lu`); the other repos are
depth-1 clones under `~/lanes/tl15/others/` (wolf-std `14f0ab2c`, boreutils
`d7909754`, lobo `bfa9ad6a`, wolf-book `dadc38be`).

| claim | artifact |
|---|---|
| nine cases red on trunk's grammar | `ts-red-trunk.log` (rc 1, 9 failures, heads and blobs on line 1) |
| compiler column | `compiler/verdicts.txt`, `compiler/<case>/out.txt` |
| fix green, 146/146, node-types identical | `fix1-generate.log`, `fix1-test.log`, `fix1-node-types.diff` (0 bytes); `fix2-*` the same after `prec.dynamic` retires; `ts-generate.log`, `ts-test.log` at `71e5a28` |
| `prec.dynamic` was load-bearing only without the reservation | `nodyn-trunk-test.log` (rc 1, cases 93 and 109) |
| corpus 746, per-file verdicts identical | `gate-trunk.log`, `gate-branch.log`, `verdicts-trunk.txt`, `verdicts-branch.txt`, `verdicts.diff` |
| pass-count branch red | `gate-floor-747.log` (rc 1), `gate-committed-shrunk.log` (rc 1); green side `gate-floor-746.log`, `gate-committed-default.log` |
| ERROR branch red, and #20's blindness | `gate-planted-branch.log` (rc 1, `tl15_planted_take_call.lu` named); `gate-planted-trunk.log` (rc 0) |
| other repos unchanged | `verdicts-summary.txt`, `verdicts.diff` |
| queries load | `queries.log`, `q-*.out` |
| private libdirs | `libdirs.txt` |
| the receiver already met 0.2.19 | run 36740260729 (`repository_dispatch`, wolf-lang `c2401f05`, 746 gated, floor 715) |
| CI at the head | the PR's `pull_request` run and a `workflow_dispatch --ref tl15` run, ids in the PR body |

## 5. Done-when

- branch `tl15` on origin; PR open, unmerged, its body carrying the five
  sections, commit-hash bullets and a test checklist
- CI green at the head sha (`gh run view`), and a `workflow_dispatch --ref
  tl15` run gating `746 files` at wolf-lang `c2401f05`
- this §3 commit precedes the test commit, which precedes the grammar commit,
  which precedes the ratchet commit
- the ten red cases seen red with a captured log; both gate branches red
- the floor at 746
- #20 is left open for the merge (the PR says "fixes #20"; closed by hand
  only after trunk moves)
- `/private/tmp/tl15-grammar` removed; `~/lanes/tl15/` pruned to its logs;
  no orphan process
