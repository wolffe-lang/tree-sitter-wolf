# tl16 — the floor at 0.2.20

wolf-lang cut **0.2.20** on 2026-10-02 (`cdde128a`, release 401498582). This
file is lane tl16's contract and record for tree-sitter-wolf: the floor at
0.2.20 in tl15's steps — the corpus floor ratcheted to the 0.2.20 count, the
per-file verdicts compared with tl15's as path sets, and any construct the
grammar cannot parse reported by file. The wolf-lsp half (the pin at 0.2.20,
the stale client docs, zed's lagging `highlights.scm`) is wolf-lsp
`docs/PIN-0220.md` on its branch `tl16`, which carries its own five sections.
Row: `wave-52.md` tl16 ("Pins at 0.2.20"); template tl15
(`docs/spec-findings-tl15.md` here, wolf-lsp `docs/PIN-0219.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse` or
corpus-gate run on kasumi; §3 is not edited after this commit. The acquisition
(clones, the release archives, the tree-sitter binary) ran first, because §2
cites it: `~/lanes/tl16/setup.log`.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl16/` on kasumi and the lane's scratch directory;
  no deletion in any tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1. `tree-sitter generate/test/parse/query` and the corpus
  gate run on kasumi under `~/lanes/tl16/`, **each with a private
  `TREE_SITTER_LIBDIR`** (`~/lanes/tl16/lib-*`), never the shared
  `~/.cache/tree-sitter/lib/wolf.so`.
- No merge, no rebase-merge; no `2>/dev/null` on a checkout; the branch is
  asserted before every commit.
- No "seen red" without a run id, sha, path or captured log in the same
  paragraph. **Both failure branches of the corpus gate** are seen red at the
  ratchet head, each with its log path.
- The floor ratchets to the measured count, never down, never above it.
- A count of files is compared as a **set of paths both ways**, never as a
  number alone (wolf-lang#177).
- Kill only pids this lane started — never a pattern or a process group;
  jobs launched with `setsid`, waited on in printing loops.
- CI read with `gh run view`; any watch uses `--interval 60`; waits print at
  least every five minutes. No attribution trailers on any commit or PR.
- Prune each kasumi tree the moment its evidence is written (`/home` is at
  92 %, three pin lanes share it).

## 2. Inputs, re-derived 2026-10-02 against origin

| input | row said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `1834e73` | `1834e73050e91164602e0f100cba8b138ced71dd` (`origin/trunk`, "changelog: tl15") | none |
| wolf 0.2.20 | release 401498582 | `v0.2.20^{commit}` = `cdde128a30999652c9d70189664226b766a206f0` (annotated tag object `db412213…`); release id 401498582, `draft=false`, published 2026-10-02T03:16:00Z, target `trunk`, four assets, exactly one release on the tag (the whole list queried) | none |
| the default branch | — | wolf-lang `origin/trunk` is **not** the tag this time: `6a57f943` (s195, seven commits past `cdde128a`, merged 2026-10-02T03:32:59Z). `git diff v0.2.20 origin/trunk -- corpus/ spec/` is **empty**, so the gate's default-branch checkout and the tag hold the same corpus and the same spec | the tag is not trunk; the corpus is |
| the acquired compiler | — | `wolf-0.2.20-x86_64-unknown-linux-gnu.tar.gz` downloaded on kasumi, sha256 `24855d5efae9515ac092f1db11613187838f018f017dc20416f70905fb816ce9` = the API's asset digest; `wolf --version` → `wolf 0.2.20 (wolfgang, pin cdde128)` / `paired with lupin 0.1.43 (reference interpreter), pin c2401f0` (`setup.log`) | — |
| the pin here | "pinned at 0.2.20" | as tl13–tl15 found, there is no pin file: the gate reads wolf-lang's default branch, and the recorded pin is the ratchet paragraph in `script/parse-wolf-corpus.sh` plus `CHANGELOG.md`; "pinned" means that record moves from `c2401f05` to `cdde128a` | wording (as tl15) |
| the ratchet | — | `script/parse-wolf-corpus.sh`, `FLOOR="${FLOOR:-746}"` (line 190) | — |
| corpus size | "about 90 files" | **861** `.lu` under `corpus/` at `cdde128a` (`git ls-tree -r`), **778** at `c2401f05`: **83 added** (76 `corpus/memory/`, 7 `corpus/rows/`), 2 modified (`memory/elem_dyn_read_after_mut.lu`, `memory/mut_read_overlap.lu`), 0 removed. Of the 83, **none** carries a parse-tier directive (`check: fail(E0[012]`) in its first 20 lines; the file-level directive count over all 861 is 31, plus `resolve/broken_sibling`'s member, the same **32** exclusions as at every cut since tl04 | 83, not "about 90" |
| the receiver at the tag | — | run **36955900148**, `repository_dispatch` `wolf-lang-corpus`, 2026-10-02T02:29:58Z — between the tag commit (01:45:21Z) and s195's merge (03:32:59Z), so its default-branch checkout was `cdde128a`; gate job 02:31:04→02:34:17Z (3m13s, in the 122–340 s band); `Total parses: 146; successful parses: 146`; `829 files gated, 32 parse-tier counter-examples excluded`; `PASS … (829 files, floor 746)` — trunk's grammar already parses all 829 at zero ERROR nodes | the item is the floor (746 → 829) |
| spec grammar | — | `spec/grammar.ebnf` blob `3f24d076fde0079aa3b6260b8cbadc97a35a9eff` at **both** v0.2.19 and v0.2.20 (and at v0.2.18). `spec/01-grammar.md` blob `520bcba2…` → `8266e09a…`: one hunk, +3 −1 prose lines under the struct-literal production ("the shorthand is exactly the longhand `Point { x: x }` … a non-`Copy` `x` moves into the field", s190, wolf-lang#486) — no production changes. `spec/anchors.json` blob `9be2d074…` → `6be24a9e…`: +`mem.tier0.excl.4`, +`type.row.else`, 0 dropped, 0 retargeted (key sets both ways) | none |
| the two rulings | "say whether either touches the grammar" | **Neither does.** Ruling #17's `[mem.tier0.excl.4]` (`02-memory-model.md`, two-phase arguments) and ruling #18's `[type.row.else]` (`10-types.md`, an `else` handles its scrutinee's own row) are semantics over spellings the grammar already parses (`f(mut a, a.x)`, `look(m, key()?) else 0`); the EBNF is the same blob, and the new corpus rows spell no new construct (`else |none| …`, `xs[i + 1]`, `W { xs }` are all pre-0.2.20 syntax) | — |
| the front end at the tag | — | `crates/wolf_parse/src` moved (`0bbed454…` → `b20dd47c…`): `exprs.rs` +15 −3, the field-init shorthand now wraps its IDENT in a `PathExpr` (s190). The token stream is unchanged, `crates/wolf_lex/src` is the same tree (`9166b9fd…`); a shorthand `W { xs }` is the same source text, so the grammar's tree does not move | — |
| the grammar today | — | `grammar.js` blob `6c4c7687…`'s successor at `1834e73`; `src/parser.c` `LANGUAGE_VERSION 15`, `MAX_RESERVED_WORD_SET_SIZE 2` (tl15's reservation); test corpus 146 cases over 11 files | — |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`); `npm ci` on kasumi (node v26.8.1) exited 0 and again left **no** binary (tl14, tl15); fetched from `releases/download/v0.26.13/tree-sitter-linux-x64.gz`, sha256 `ad369a4df2bb1ebf5cd37045d34bdc9160b9351f92520399106d8e689cac00af` = tl14's and tl15's, `tree-sitter 0.26.13` | — |
| tl15's verdicts | — | `~/lanes/tl15/verdicts-branch.txt` (1,742 lines: 778 corpus + 964 other-repo paths), copied to `~/lanes/tl16/tl15-verdicts-branch.txt` for the path-set comparison | — |
| open issues | — | tree-sitter-wolf: none open; #20 closed at tl15's merge | — |

## 3. Prediction, committed before any run

**What is not a prediction.** The receiver already printed 829 at `cdde128a`
with trunk's grammar (run 36955900148); that number is a re-measurement. The
grammar does not change in this lane (the EBNF is the same blob), so there is
no red-first grammar case and no `node-types.json` claim beyond identity.

1. **The gate at trunk's grammar.** `script/parse-wolf-corpus.sh` at
   `1834e73` (floor 746, no `FLOOR` in the environment) over the tag's
   corpus with a private libdir: **829 files gated, 32 excluded, zero ERROR
   nodes**, PASS, rc 0. *Falsifier:* any other count, or any file named.
2. **Per-file verdicts, compared as path sets both ways.** Every one of the
   861 corpus files parses `ok`. Against tl15's corpus verdicts (778 paths,
   path prefix normalised): the 778 old paths are all present with the same
   verdict; the paths present only now are **exactly the 83** that
   `git diff --name-status v0.2.19 v0.2.20 -- corpus/` adds; **0** paths are
   present only in tl15's. *Falsifier:* any `ERR`, or any path in one set and
   not the other beyond the 83.
3. **No new construct the grammar cannot parse.** All 83 added files parse
   clean, listed by file in the evidence; the two modified files too.
   *Falsifier:* any of them `ERR` — reported by file in §3-scored, and the
   construct named.
4. **The grammar is inert.** `tree-sitter generate` at the head leaves
   `src/` byte-identical (`git diff --exit-code -- src/` rc 0);
   `tree-sitter test` passes **146 of 146**; the three
   `queries/*.scm` load against the private build with no edit.
   *Falsifier:* any `src/` diff, failing case, or query error.
5. **Both gate branches red at the ratchet head** (`FLOOR="${FLOOR:-829}"`
   committed): the committed default passes at 829; `FLOOR=830` fails
   `only 829 file(s) gated — the floor is 830; checkout suspect`, rc 1; a
   scratch corpus with one gated file removed fails the committed default
   with `828 … floor is 829`, rc 1; and a scratch corpus with
   `fn main() -> !int { let ( = }` planted gates **830** and fails
   `FAIL: 1 file(s)` with the file named, rc 1. *Falsifier:* any of the
   three red runs exiting 0, or the green one exiting 1.
6. **CI at the head** (`pull_request`, and a `workflow_dispatch --ref tl16`)
   is green, its gate log carrying `829 files gated` and `floor 829` — if
   wolf-lang's default branch grows past the tag before the run, the gated
   count is **above** 829 and the floor still passes; the number is reported
   either way. *Falsifier:* a red gate, or a count below 829.

## 3, scored (written after the measurement; the section above is unedited since `e2778ad`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | 829 gated, 32 excluded, zero ERROR nodes at trunk's grammar, floor 746 | `gate-trunk.log` (head `1834e73`, script blob `2f2cfcc6`, corpus `cdde128a`, `FLOOR env: unset`, libdir `lib-gate`): `829 files gated, 32 parse-tier counter-examples excluded` / `PASS … (829 files, floor 746)`, rc 0 | **yes** |
| 2 | every one of the 861 parses `ok`; against tl15's 778: 0 removed, 0 changed, exactly the 83 added | `verdicts-corpus.txt`: 861 lines, **16 `ERR`** — the fifteen `corpus/grammar/*` parse-tier counter-examples (`char_uni_seven_digits`, `closure_params_no_separator`, `if_then_let_body`, `if_then_missing`, `let_group_bare_tuple`, `let_group_one_init`, `match_range_open`, `newline_leading`, `range_bare`, `str_bare_brace`, `str_dollar_brace`, `struct_literal_no_separator`, `struct_pattern_no_separator`, `struct_pattern_rest_bare`, `tuple_pattern_no_separator`) and `resolve/broken_sibling/mangled.lu`, every one excluded by directive and every one `ERR` in tl15's file too. `verdicts-compare.txt`: `only tl15 (removed)` empty, `same path, different verdict` empty, `added 83 removed 0` | **no, on the first clause — 16 of 861 are `ERR`, as they were at tl15 and as the gate's own exclusion rule says they must be; the path-set comparison held in full.** I wrote "every one" from the gate's PASS line and forgot that the gate skips the counter-examples before parsing; the verdict run does not |
| 3 | all 83 added files and the 2 modified parse clean | `verdicts-added.txt`: 83 lines, `ok 83, ERR 0` (76 `memory/`, 7 `rows/`); `memory/elem_dyn_read_after_mut.lu` and `memory/mut_read_overlap.lu` `ok` | **yes** — no new construct the grammar cannot parse |
| 4 | `src/` byte-identical after `generate`; 146/146; queries load | `ts-generate.log` at `76a9c05`: `generate rc 0` / `src diff rc 0`, ABI 15, `MAX_RESERVED_WORD_SET_SIZE 2`; `ts-test.log`: `Total parses: 146; successful parses: 146`, rc 0; `queries-head.log`: highlights rc 0 (222 lines), locals rc 0 (92), injections rc 0 (6) | **yes** |
| 5 | committed default green at 829; `FLOOR=830` red; shrunk red; planted red with the file named | `gate-committed-default.log` (script blob `ebaf7c77`, `FLOOR env: unset`): `PASS … (829 files, floor 829)`, rc 0. `gate-floor-830.log`: `FAIL: only 829 file(s) gated — the floor is 830; checkout suspect`, rc 1. `gate-committed-shrunk.log` (`memory/mut_claim_two_phase_reads.lu` removed from a scratch copy): `828 files gated` / `FAIL: only 828 file(s) gated — the floor is 829; checkout suspect`, rc 1. `gate-planted.log` (`fn main() -> !int { let ( = }` as `tl16_planted_bad_let.lu`): `830 files gated` / `FAIL: 1 file(s) with ERROR/MISSING nodes:` / `…/planted-corpus/tl16_planted_bad_let.lu`, rc 1 | **yes** |
| 6 | CI green at the head, `829 files gated`, `floor 829` | the run ids and the gated count are in the PR body (written after the push) | — |

Four of five scored; the miss is a sentence, not a number — the measurement
underneath it (the 16 ERRs are tl15's 16, excluded by directive) is what the
comparison exists to show.

**Private libdirs, checked** (`libdirs.txt`). Trunk's grammar built to
`lib-gate` and the ratchet head's to `lib-head`, both `wolf.so` sha256
`0e88d1e9…` — the digest tl15 recorded for its branch parser, which is what
trunk's parser has been since the merge. The shared
`~/.cache/tree-sitter/lib/wolf.so` still carries its 2026-09-26 18:19 mtime.

**The install note, a third time.** `npm ci` on kasumi (node v26.8.1) exited 0
and left no `tree-sitter` binary (tl14, tl15); the v0.26.13 binary was fetched
by URL, sha256 `ad369a4d…` = tl14's and tl15's (`setup.log`).

### §2 corrected after the commit (drift in my own inputs; §2 left as committed)

- `grammar.js` was described as "blob `6c4c7687…`'s successor" — a lazy
  spelling. The measured fact is simpler: `grammar.js`, `src/` and
  `queries/` are untouched by this lane, and `tree-sitter generate` at the
  head leaves `src/` byte-identical (`ts-generate.log`).

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl16/`. The clone the runs use is
`~/lanes/tl16/ts` (at `1834e73` for the trunk gate, at the ratchet head for
the branch runs); the corpus is `~/lanes/tl16/wolf-lang`, a depth-1 clone at
`v0.2.20` = `cdde128a` (861 `.lu`); the private libdirs are
`~/lanes/tl16/lib-gate` (trunk's grammar) and `lib-head` (the ratchet head,
the same parser bytes); the tree-sitter binary is
`~/lanes/tl16/ts/node_modules/tree-sitter-cli/tree-sitter` (copied from
`~/lanes/tl16/tsbin/`, `setup.log` carries its digest).

| claim | artifact |
|---|---|
| the acquisition: archive digests, `wolf --version`, the tree-sitter binary's sha | `setup.log`, `npm-ci.log` |
| 829 gated at trunk's grammar | `gate-trunk.log` (rc 0, heads on line 1) |
| per-file verdicts, 861 corpus files | `verdicts-corpus.txt`; the comparison with tl15's: `verdicts-compare.txt` (added / removed / changed path lists), `verdicts-added.txt` = the 83 |
| the 83 new files by name, each `ok`; the 16 `ERR` are tl15's 16 | `verdicts-added.txt`, `verdicts-corpus.txt`, `tl15-corpus-verdicts.txt` |
| generate leaves `src/` identical; 146/146; queries load | `ts-generate.log`, `ts-test.log` (at `76a9c05`); `queries.log`, `q-*.out` (trunk's grammar), `queries-head.log`, `q-head-*.out` (the head) |
| committed default green at 829 | `gate-committed-default.log` (rc 0) |
| pass-count branch red | `gate-floor-830.log` (rc 1), `gate-committed-shrunk.log` (rc 1) |
| ERROR branch red, the file named | `gate-planted.log` (rc 1) |
| private libdirs; the shared cache untouched | `libdirs.txt` |
| the receiver already met 0.2.20 | run 36955900148 (`repository_dispatch`, 829 gated, floor 746) |
| CI at the head | the PR's `pull_request` run and a `workflow_dispatch --ref tl16` run, ids in the PR body |

## 5. Done-when

- branch `tl16` on origin; PR open, unmerged, its body carrying the five
  sections, commit-hash bullets and a test checklist
- CI green at the head sha (`gh run view`), and a `workflow_dispatch --ref
  tl16` run gating at least `829 files` at floor 829
- this §3 commit precedes the ratchet commit, which precedes the scored
  commit and the changelog commit
- both gate branches seen red with captured logs at the ratchet head
- the floor at 829
- `/private/tmp/tl16-grammar` removed; `~/lanes/tl16/` pruned to its logs
  (the `ts`, `wolf-lang`, `lib-*`, `*-corpus` trees gone); no orphan process
