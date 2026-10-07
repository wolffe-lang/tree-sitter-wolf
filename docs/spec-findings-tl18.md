# tl18 — the floor at 0.2.25, and `extern "c" let`

wolf-lang cut **0.2.25** on 2026-10-07 (`6710f9e0`, release 406122367). This
repository last moved at 0.2.20 (tl16, `a95fed6c`, floor 829), five releases
ago. This file is lane tl18's contract and record for tree-sitter-wolf: the
corpus floor at 0.2.25, the per-file verdicts compared with tl16's as path
sets, and the one construct the grammar cannot parse — fixed here. The
wolf-lsp half (the pin at 0.2.25, the editors' grammar pin) is wolf-lsp
`docs/PIN-0225.md` on its branch `tl18`, with its own five sections.
Contract: planning `sprints/lsp/tl18-the-editors-at-0225.md`; rules
`sprints/wave-53.md` down to `wave-45.md`; template tl16
(`docs/spec-findings-tl16.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse` or
corpus-gate run on kasumi; §3 is not edited after this commit. The
acquisition (archives, the depth-1 corpus clone, the tree-sitter binary) ran
first, because §2 cites it: `~/lanes/tl18/setup.log` on kasumi.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl18/` (kasumi and nomad-1) and this lane's two
  worktrees; no deletion in any tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1. `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl18/`, **each with a private
  `TREE_SITTER_LIBDIR`**, never the shared `~/.cache/tree-sitter/lib/wolf.so`.
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
  waited on by a done-file in loops that print at least every five minutes.
  CI read with `gh run view`; no `gh run watch` without `--interval 60`.

## 2. Inputs, re-derived 2026-10-07 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `a95fed6c` | `a95fed6c` ("changelog: tl16") | none |
| wolf 0.2.25 | `6710f9e0`, release 406122367 | `v0.2.25^{commit}` = `6710f9e0cbc3a7264349093751ce7a46a407e473` (annotated tag object `90f1c11e…`); release 406122367, `draft=false`, published 2026-10-07T20:18:34Z, four assets, exactly one release on the tag | none |
| the archives | linux x86-64 `9d91f533…`, macOS arm64 `202c8d6c…` | downloaded on kasumi, sha256 equal to the API digest: linux x86-64 74,979,974 B `9d91f533ba23…`, macOS arm64 17,229,080 B `202c8d6c5c90…` (`setup.log`, `acquire/members.txt`); `wolf --version` → `wolf 0.2.25 (wolfgang, pin 6710f9e)` / `paired with lupin 0.1.48 (reference interpreter), pin 294d626` | none |
| the default branch | — | wolf-lang `origin/trunk` = `6710f9e0` = the tag at the time of writing, so the CI gate's default-branch checkout and the tag hold the same corpus | none (re-checked at CI time) |
| the pin here | "where it pins wolf" | as tl13–tl16 found, there is no pin file: the gate reads wolf-lang's default branch; the recorded pin is the ratchet paragraph in `script/parse-wolf-corpus.sh` (`FLOOR="${FLOOR:-829}"`, line 210) and `CHANGELOG.md`. "Pinned" means that record moves from `cdde128a` to `6710f9e0` | wording (as tl16) |
| **"0.2.25 adds no syntax; the grammar should not move"** | the grammar does not move | **False for this repo's span.** 0.2.25 itself adds no syntax (`spec/grammar.ebnf` is blob `29d5de10` at v0.2.23, v0.2.24 and v0.2.25), but this repo's record is at **0.2.20**, and v0.2.23 (kw09, wolf-lang `231219b6`) added one production: `bare_item … \| extern_let_item` and `extern_let_item ::= 'extern' STRING 'let' IDENT ':' type TERM` (`git diff v0.2.20 v0.2.25 -- spec/grammar.ebnf`, the whole diff, +2 −1). The grammar has no rule for it | **drift: one production owed** |
| the receiver, red on trunk since 2026-10-04 | — | run **37211326706** (`repository_dispatch` at the v0.2.23 tag, 2026-10-04T14:59Z): `944 files gated, 38 parse-tier counter-examples excluded` / `FAIL: 2 file(s)` — `corpus/membrane/extern_let_image.lu`, `corpus/membrane/extern_let_not_ptr.lu`; again **37416400091** (v0.2.24, 10-06) and **37679728322** (v0.2.25, 2026-10-07T20:08Z): `969 files gated, 38 … excluded` / `FAIL: 2 file(s)`, the same two files; the daily schedule red with them (37201787398, 37326162424, 37469667022, 37627950806). The red-CI alarm opened **tree-sitter-wolf#25** (2026-10-04, open) | the trunk gate is red; this lane is its fix |
| corpus size | — | **1007** `.lu` under `corpus/` at `6710f9e0` (`git ls-tree -r`; `find` on the kasumi clone agrees, `setup.log`), **861** at `cdde128a`: **146 added**, **5 modified** (`comptime.lu`, `faults/index_origin_min_overflow.lu`, `ffi.lu`, `memory/unsafe_sig.lu`, `typecheck/wrap_narrow_cast.lu`), **0 removed**. Added by directory: memory 58, rows 39, grammar 14, conc 10, faults 7, comptime 3, membrane 6, typecheck 6, fs 2, kernels 1 | — |
| exclusions | — | the gate's own rule (`check: fail(E0[012]` in the first 20 lines, or a module member whose `entry.lu` says so), read from the tag's blobs: **38** at v0.2.25 against **32** at v0.2.20 — the 32 kept, **6 added**, all `corpus/rows/negative/first_*` (s203, ruling #28): `first_boundary_before_lex` (E0202), `first_keyword_pattern` (E0207), `first_parse_before_lex` (E0207), `first_parse_before_resolve` (E0207), `first_same_offset_lex` (E0102), `first_stray_backtick` (E0107); 0 dropped. So **969 gated** = 1007 − 38, which is the receiver's number | — |
| the two red files | — | `extern_let_image.lu` (`check: run`, three `#[cfg(target = …)] extern "c" let NAME: *u8`), `extern_let_not_ptr.lu` (`check: fail(E0821)`, phase resolve — a parse-clean program, so gated: `extern "c" let __kernel_end: int`) | — |
| the other new surface | — | `#[section]`, `#[repr]`, `cfg(target …)` attributes, `[abi.interrupt]`, atomics `Order`, `packed`/`align`, `size_of`/`offset_of`: none is a production (the EBNF's only move is above), and the receiver names no other file | — |
| the grammar today | — | `grammar.js`: `function_qualifier` already spells `seq('extern', $.string_literal)` (bodyless `extern "c" fn`); no item starts `extern … let`. `queries/highlights.scm` already paints `"extern"` (line 221) and `"let"` (line 215) as keywords. `test/corpus`: 146 cases over 11 files | — |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`); fetched from `releases/download/v0.26.13/tree-sitter-linux-x64.gz`, sha256 `ad369a4d…` = tl14–tl16's (`setup.log`) | — |
| tl16's verdicts | — | `~/lanes/tl16/verdicts-corpus.txt` (861 lines, 16 `ERR`: the fifteen `corpus/grammar/*` counter-examples and `resolve/broken_sibling/mangled.lu`), copied to `~/lanes/tl18/tl16-verdicts-corpus.txt` | — |
| open issues | — | tree-sitter-wolf#25 (the red-CI alarm, open) | — |

## 3. Prediction, committed before any run

**What is not a prediction.** 1007 files, 38 excluded, 969 gated, and the
two red files are §2 measurements (the receiver already printed them).

1. **The gate at trunk's grammar reproduces the receiver.** At `a95fed6c`
   (floor 829) over the tag's corpus with a private libdir: `969 files
   gated, 38 … excluded`, `FAIL: 2 file(s)`, exactly
   `membrane/extern_let_image.lu` and `membrane/extern_let_not_ptr.lu`,
   rc 1. *Falsifier:* any other count or file.
2. **Per-file verdicts at trunk's grammar, as path sets against tl16's.**
   0 paths only in tl16's; the 861 shared paths keep tl16's verdict
   (including the 5 modified files, all `ok`); exactly the 146 added paths
   are new. Of the 146, `ERR` is the two extern-let files plus **at most**
   the six new `first_*` exclusions (they are parse-tier counter-examples,
   so an `ERR` there is the grammar agreeing with the compiler, not a
   defect); every other added file `ok`. *Falsifier:* any shared path
   changing verdict, any `ERR` outside those eight.
3. **One rule fixes it, red first.** A `test/corpus/items.txt` case for
   `extern "c" let NAME: *T` (with an attribute, and `pub`) fails at
   `a95fed6c`'s grammar and passes after the rule. The rule is
   `extern_let_declaration` — `repeat(attribute) optional(visibility)
   'extern' field('abi', string_literal) 'let' field('name', identifier)
   ':' field('type', _type)` — in `_statement` beside the other items, with
   no new conflict and no change to any existing case's tree (147 of 147
   pass; the 146 old expectations untouched). `generate` changes `src/`
   only by the new rule (`grammar.json`, `node-types.json`, `parser.c`).
   *Falsifier:* a declared conflict needed, an old case changing, or the
   red case passing before the rule.
4. **After the rule, the gate is green at 969** with zero ERROR nodes, and
   the per-file verdicts differ from trunk's only on the two extern-let
   files (`ERR` → `ok`). *Falsifier:* any third file moving.
5. **The queries: `highlights.scm` unchanged.** `extern`, `let`, the ABI
   string and the type already capture through existing patterns; the
   name is a plain identifier as in a `let`. `locals.scm` gains one line —
   the name as `@local.definition.var`, as a `let` binder is. All three
   queries load against the head's parser; on `extern_let_image.lu` the
   head's highlights capture **strictly more** than trunk's (the ERROR
   region captured fewer); on every other corpus file trunk and head
   capture the same count. *Falsifier:* a query error, or a capture count
   that moves on a file other than the two.
6. **Both gate branches red at the ratchet head** (`FLOOR="${FLOOR:-969}"`
   committed): the committed default passes at 969; `FLOOR=970` fails
   `only 969 file(s) gated — the floor is 970; checkout suspect`, rc 1; a
   scratch corpus with one gated file removed fails with `968 … floor is
   969`, rc 1; a scratch corpus with `fn main() -> !int { let ( = }`
   planted gates 970 and fails `FAIL: 1 file(s)` naming it, rc 1.
7. **CI at the head** (`pull_request`) is green with `969 files gated` and
   `floor 969` (above 969 only if wolf-lang's default branch grows first;
   reported either way); trunk's own red (37679728322) is this PR's
   seen-red-in-CI for the gate the bump touches.

## 3, scored (written after the measurement; §1–§3 above are unedited since `b4d7661`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | trunk's grammar: 969 gated, 38 excluded, `FAIL: 2`, the two extern-let files, rc 1 | `gate-trunk.log` (head `a95fed6c`, script blob `ebaf7c77`, corpus `6710f9e0`, `FLOOR env: unset`, libdir `lib-trunk`): `969 files gated, 38 parse-tier counter-examples excluded` / `FAIL: 2 file(s)` / `…/membrane/extern_let_image.lu`, `…/membrane/extern_let_not_ptr.lu`, rc 1 — the receiver's 37679728322, reproduced | **yes** |
| 2 | path sets against tl16's: 0 removed, 0 changed, 146 added; added `ERR` only the two plus at most the six `first_*` | `verdicts-compare.txt`: `tl16 paths 861; now 1007`, `only tl16 (removed)` empty, `same path, different verdict` empty (the 5 modified files keep `ok`), `added 146 removed 0 added-ok 138`; added `ERR`: the two extern-let files and **all six** `rows/negative/first_*` (each a parse-tier counter-example the gate excludes, so the grammar agrees with the compiler) | **yes** |
| 3 | the new case red at `a95fed6c`, green after the rule; no conflict; 147/147; `src/` moves only by the rule | `ts-test-red.log` at `82b4b01`: `Total parses: 147; successful parses: 146; failed parses: 1` — the extern-let case, its tree an `ERROR` where `extern_let_declaration` is expected — rc 1. `ts-test-rule.log`: `147; successful parses: 147`, rc 0; `ts-generate.log`: `generate rc 0`, changed `src/grammar.json` +64, `src/node-types.json` +102, `src/parser.c` (regenerated tables), no `conflicts` entry added (`grammar.js` diff in `9248dcd`); every one of the 146 old expectations unedited (`git diff a95fed6c 9248dcd -- test/` touches only the new case) | **yes** |
| 4 | after the rule the gate is green at 969; verdicts differ from trunk's only on the two | `g3/gate-committed-default.log` (head `f375a8d`, script blob `4c5897b7`): `969 files gated, 38 … excluded` / `PASS: zero ERROR nodes across the corpus (969 files, floor 969)`, rc 0. `g3/verdicts-diff.txt`: `head ERR 22 trunk ERR 24`, the diff is exactly lines 306–307, `ERR` → `ok` for `membrane/extern_let_image.lu` and `membrane/extern_let_not_ptr.lu` | **yes** |
| 5 | `highlights.scm` unchanged; `locals.scm` +1 line; queries load; head's highlights capture **strictly more** on `extern_let_image.lu`; same counts everywhere else | `highlights.scm` untouched (`git diff a95fed6c f375a8d -- queries/highlights.scm` empty); `locals.scm` +1 (`84b29bb`); `g3/queries-head.log`: highlights rc 0, locals rc 0, injections rc 0. `g3/captures-diff.txt` (trunk parser + trunk queries against head parser + head queries, all 1007 files): **only the two files differ**. But `extern_let_image.lu` highlights **250 → 250**, not more; `extern_let_not_ptr.lu` 27 → 28; locals 77 → 80 and 7 → 9 | **no, on one clause.** The ERROR region still exposed every token to the anonymous-node patterns (`"extern"`, `"let"`, the string, the identifiers each still captured: `g3/q-head-highlights.out` paints `extern`/`let` `keyword.storage.modifier` at lines 13, 26, 39), so recovering the tree moved no highlight on that file; on `extern_let_not_ptr.lu` one capture is gained. The locals moves are the new definition line (head parser with trunk's queries: 77 and 8, `captures-headparser-trunkqueries.txt`) — +3 and +1 from the line, +1 from the parse. Everything else held |
| 6 | committed default green at 969; `FLOOR=970` red; shrunk red; planted red with the file named | `g3/gate-committed-default.log` rc 0 (above). `g3/gate-floor-970.log`: `FAIL: only 969 file(s) gated — the floor is 970; checkout suspect`, rc 1. `g3/gate-committed-shrunk.log` (`membrane/extern_let_image.lu` removed from a scratch copy): `968 files gated` / `FAIL: only 968 file(s) gated — the floor is 969; checkout suspect`, rc 1. `g3/gate-planted.log` (`fn main() -> !int { let ( = }` as `tl18_planted_bad_let.lu`): `970 files gated` / `FAIL: 1 file(s) with ERROR/MISSING nodes:` / `…/planted-corpus/tl18_planted_bad_let.lu`, rc 1 | **yes** |
| 7 | CI green at the head, 969 gated, floor 969; trunk's red is the seen-red | the run ids and the gated count are in the PR body | — |

Five of six scored held; the miss is a capture count I reasoned from the tree
instead of from the patterns, which match anonymous keyword nodes inside an
ERROR as readily as outside one. What a reader of `extern "c" let` in helix or
zed sees changes only where the old ERROR swallowed a token (one capture on
`extern_let_not_ptr.lu`) — highlights were already right; what the rule buys
is a clean tree (no red squiggle from the parser, folds and locals right) and a
green gate.

**Private libdirs, checked** (`libdirs.txt`, `g3/libdirs.txt`). Trunk's grammar
built to `lib-trunk` and `lib-red` (`wolf.so` sha256 `0e88d1e9…`, the digest
tl15 and tl16 recorded), the head's to `lib-head` (`f3bc57d8…`). The shared
`~/.cache/tree-sitter/lib/wolf.so` still carries its 2026-09-26 18:19 mtime.

### §2 corrected after the commit

- None of §2's numbers moved. The contract's "the grammar should not move" is
  the drift §2 names; the lane fixed it in this repo (the rule), as the
  contract's "a refusal is fixed in this repo or filed upstream" allows.

## 4. Evidence index

All logs are on kasumi under `~/lanes/tl18/`. The clone the runs use is
`~/lanes/tl18/ts`; the corpus is `~/lanes/tl18/wolf-lang`, a depth-1 clone at
`v0.2.25` = `6710f9e0` (1007 `.lu`); the tree-sitter binary is
`~/lanes/tl18/tsbin/tree-sitter` (`setup.log` carries its digest).

| claim | artifact |
|---|---|
| the acquisition: archive digests = the API's, members by name, `wolf --version`, the binary's sha | `setup.log`, `acquire/members.txt` |
| trunk red on the two files, locally and in CI | `gate-trunk.log`; runs 37211326706, 37416400091, 37679728322 |
| per-file verdicts, 1007 files, against tl16's 861 | `verdicts-trunk.txt`, `verdicts-compare.txt`, `tl16-verdicts-corpus.txt` |
| the case red, then green | `ts-test-red.log` (at `82b4b01`), `ts-test-rule.log`, `ts-generate.log` |
| the head: `generate` inert, 147/147 | `g3/ts-generate.log` (`src diff rc 0`), `g3/ts-test.log` |
| the gate's three branches at the head | `g3/gate-committed-default.log`, `g3/gate-floor-970.log`, `g3/gate-committed-shrunk.log`, `g3/gate-planted.log` |
| verdicts at the head move only the two | `g3/verdicts-head.txt`, `g3/verdicts-diff.txt` |
| queries load; captures | `g3/queries-head.log`, `g3/q-head-*.out`, `g3/captures-{trunk,head,headparser-trunkqueries}.txt`, `g3/captures-diff.txt` |
| commits | `b4d7661` (this contract), `82b4b01` (the red case), `9248dcd` (the rule), `84b29bb` (locals), `f375a8d` (the ratchet) |
| CI at the head | the PR's run id, in the PR body |

## 5. Done-when

- branch `tl18` on origin; PR open, unmerged, its body carrying the five
  sections, commit-hash bullets and a test checklist; CI green at the head
  sha, read with `gh run view`
- this §3 commit precedes the red case, the rule and the ratchet
- no attribution trailers
- the worktree removed; `~/lanes/tl18/` pruned to its logs; no orphan
  process
- listed to close (not closed by this lane): tree-sitter-wolf#25
