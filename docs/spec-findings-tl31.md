# tl31 — the grammar at 0.2.34

wolf-lang cut **0.2.34** (its CHANGELOG dated 2026-10-20; `v0.2.34` =
`9da7bdcf`, release 419552903, published 2026-10-21). This repository last
moved at 0.2.33 (tl27, floor 1117) and was tiered by tl28 (`79b6e92`,
verdict-only: every run is `tier full`). This file is lane tl31's contract
and record for tree-sitter-wolf: whether anything 0.2.34 added to the
surface needs a grammar rule or a highlight pattern, the corpus floor at
0.2.34 (the receiver's count at the tag), and tree-sitter-wolf#27 if in
reach. The wolf-lsp half (the pin, the vendored spec with 0.2.34's seven
prelude names and the mark `busy`, the transcripts and the six smokes) is
wolf-lsp `docs/PIN-0234.md` on its branch `tl31`. Contract: planning
`sprints/lsp/tl31-the-editors-at-0234.md` (`e26ec74`); rules
`sprints/RULES.md` with 0.2.34's toolchains; template tl27
(`docs/spec-findings-tl27.md`).

§1–§3 are committed before any `tree-sitter generate`, `test`, `parse`,
`query` or corpus-gate run in this lane; §3 is not edited after this
commit. Everything in §2 was read from git objects (wolf-lang's tags), the
GitHub API, the downloaded archives and CI logs. tree-sitter-wolf#27 gets a
prediction of its own (§3b), committed before its first run.

## 1. Forbidden, absolutely

- No grammar rule, scanner change and no highlight query changed without a
  corpus or highlight case that shows it. **Prelude functions do not
  highlight as builtins** (ruling #77, item 4): no `@function.builtin`
  pattern over prelude names, the seven new ones included, and no pattern
  over marks.
- No `rm` outside `~/lanes/tl31/`; no `git add -A`; nothing under
  `~/.claude`; nothing in another org's repository; no library source that
  is not the maintainer's is read (RULES §1): tree-sitter's behaviour is
  measured black-box (the CLI's `parse`, `test`, `query`) and from its
  published documentation only.
- No build on nomad-1: `tree-sitter generate/test/parse/query` and the gate
  run on kasumi under `~/lanes/tl31/`, each with a private
  `TREE_SITTER_LIBDIR` (tl13). Lanes install no host tool: the CLI is the
  0.26.13 binary tl27 used, accepted only if its sha256 is the one tl14–tl27
  recorded (`ad369a4d…`).
- No merge, no tag, no issue filed or closed; the branch asserted before
  every commit; no attribution trailers.
- The toolchain is the release by digest, each digest read twice, never
  wolf-lang's trunk. The floor ratchets to the measured count at the
  release, never down, never above it; a count of files is compared as a
  set of paths both ways (wolf-lang#177). No "seen red" without a run id,
  sha or captured log in the same paragraph.

## 2. Inputs, re-derived 2026-10-21 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `79b6e92` (tl27, tl28) | `79b6e927` (tl28's plant revert), by `git fetch` on nomad-1 and the clone on kasumi; open issues: #27 | none |
| wolf 0.2.34 | `v0.2.34` at `9da7bdcf` (release 419552903) | `v0.2.34^{commit}` = `9da7bdcf2aea9adf48df6570bedc58e16e9ef853` (annotated tag object `38ab81cb…`), by `git rev-parse` on nomad-1 and `git ls-remote` on kasumi; release **419552903**, `draft=false`, published 2026-10-21T12:58:10Z, the only release carrying the tag, four assets (API digests): linux x86-64 `88a9dd3d…`, linux aarch64 `ca5cadf9…`, macOS arm64 `29c8331f…`, windows `77bb8403…`. The linux x86-64 and macOS archives downloaded on kasumi and hashed twice (`sha256sum`, `openssl dgst`), both equal to the API's; `wolf 0.2.34 (wolfgang, pin 9da7bdc)` | none |
| lupin 0.1.55 | `v0.1.55` at `e642f26` | `v0.1.55^{commit}` = `e642f2630ad4c7f53740428d5cca705f2e0d295b` (tag object `047184fb…`); release 418932753 (linux x86-64 `1152abc0…`, macOS `2eac1ccc…`, matched twice). This repository never runs lupin | none |
| **"the grammar re-checked against 0.2.34"** | expect nothing: s247 and s248 added calls, not syntax | **Nothing grammatical changed in 0.2.34.** At `v0.2.33` and `v0.2.34`: `spec/grammar.ebnf` blob `29d5de10`, `spec/01-grammar.md` blob `d1bd4ff9`, the compiler's parser `crates/wolf_parse/src` tree `03b61b38`, its lexer `crates/wolf_lex/src` tree `9166b9fd`, the formatter `crates/wolf_fmt/src` tree `c29a0c87`, all identical (and identical at v0.2.30–v0.2.33, tl27). Under `crates/wolf_parse` and `crates/wolf_lex` (v0.2.33..v0.2.34, 112 commits) the only change is two snapshot files under `tests/snapshots/`, `os__term_editor_rows`, one per crate, the snapshots of the one corpus file below. The CHANGELOG names no token, keyword, operator or production: seven builtins (calls: `os_fork`, `os_term_restore_at_exit`, `os_signal_wait_fds`, `fs_sync`, `fs_sync_dir`, `fs_realpath`, `os_clock_ns`), one mark (`busy`), the mode int's bits 5–7, `wolf test`'s discovery, the hub at start, the std pin | no rule is owed |
| prelude names | 0.2.34's seven | `spec/prelude.json` blob `41ac122f` (v0.2.33) → `b71ca9cd` (v0.2.34), `.names` as `(name, kind)` sets both ways: 187 → 194, **7 added, 0 removed, 0 entries changed**, all `function`, all `[os.host.sigs]`, all `w0304`: the seven above. Kinds at v0.2.34: `function` 154, `builtin_type` 18, `type` 8, `intrinsic` 8, `provisional` 6, so the type names (`builtin_type` + `type`) stay **26**. Marks 18 → 19 (`busy`, by `os_fork`). `queries/highlights.scm` paints prelude names only as `@type.builtin`; a call paints `@function`; nothing paints a mark (marks are identifiers in an error set). Ruling #77 (4) keeps it so | nothing owed to the queries |
| **the receiver at v0.2.34** | its count | **It fired.** wolf-lang's release run 39602781235 (`push` of `v0.2.34`, 2026-10-21T12:50:00Z), job "dispatch tree-sitter-wolf's corpus gate" (119231236167), log: `since v0.2.33: 1 file(s) moved under spec/grammar.ebnf, spec/01-grammar.md, corpus/` / `dispatched wolf-lang-corpus to wolffe-lang/tree-sitter-wolf for v0.2.34 (9da7bdcf…)` / `receiver run: …/runs/39602808647`. Here run **39602808647** (`repository_dispatch` `wolf-lang-corpus`, 2026-10-21T12:50:12Z, trunk `79b6e927`, job `gate` 119231325842, wolf-lang checked out at `9da7bdcf`): `wolf-lang corpus: 1117 files gated, 38 parse-tier counter-examples excluded` / `PASS: zero ERROR nodes across the corpus (1117 files, floor 1117)`; `tier full` 119234064015 `success` | **the floor equals the release count: no ratchet** |
| corpus size | — | `corpus/**/*.lu` by `git ls-tree`: 1155 at `v0.2.33`, **1155** at `v0.2.34`; as path sets v0.2.33 → v0.2.34: **0 added, 1 modified, 0 removed**: modified `os/term_editor_rows` (its `mode_bit5` row and print line removed and its header comment rewritten: s248 made bits 5–7 fields, wolf-lang#802). Not parse-tier, so 38 excluded and 1117 gated, as the receiver printed | — |
| wolf-lang trunk | — | `0cb954a8` (2026-10-21), past the tag: 1172 `.lu` files (17 added, 3 modified since `v0.2.34`), and `spec/01-grammar.md` moved (s252: a `{` on its own line after an `if`/`while`/`for`/`loop` header is E0201 by design, wolf-lang#822; prefix `~` is retired, E0107, wolf-lang#800); `spec/grammar.ebnf` did not. Both witnesses (`grammar/if_brace_next_line.lu` `fail(E0201)`, `typecheck/int_not_tilde.lu` `fail(E0107)`) are parse-tier counter-examples, excluded by directive; `grammar.js` has no `~`. That is 0.2.35's grammar, not this lane's; the CI gate reads wolf-lang's default branch, so it meets those files | — |
| tests | — | `test/corpus`: 150 cases; no `test/highlight/` (#27 open: tl19's `never.lu` retired at `bedb686`) | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`; kasumi has no `tree-sitter` on `PATH`; tl27's `~/lanes/tl27/tsbin/tree-sitter` copied into `~/lanes/tl31/tsbin/`, sha256 `ad369a4d…` (`setup.log`), tl14–tl27's digest | — |
| tl27's verdicts | — | kasumi `~/lanes/tl27/g1/verdicts.txt` (1155 lines, ERR 22; identical to its `g2/verdicts-head.txt` by `cmp`), over the 0.2.33 corpus at the grammar trunk still carries (`src` tree `e8d4fd5e`, `queries` `cf647eb2`, `test` `884d5bfa`, `grammar.js` `2cac20e7`, as at tl27); copied to `~/lanes/tl31/tl27-verdicts.txt` | — |
| **tree-sitter-wolf#27** | in reach | a `line_comment` (and a `doc_comment`) that follows a newline starts at the END of the previous line (tl19: `(line_comment [0, 15] - [1, 4])` for a `// a` at row 1, column 0), so a highlight assertion lands a row up and `test/highlight/` cannot be used; the issue names a likely cause in `src/scanner.c`, unverified | §3b |

## 3. Prediction, committed before any run

**Not a prediction:** 1155 files, 38 excluded, 1117 gated and a green gate
at trunk's grammar over the tag's corpus are §2 inputs (the receiver
printed them).

1. **Per-file verdicts at trunk's grammar over the v0.2.34 corpus, as path
   sets against tl27's**: 0 paths only in tl27's, 0 only in tl31's; the 1155
   shared paths keep their verdict (`os/term_editor_rows` stays `ok`);
   `ERR` stays 22 (tl27's 22 paths). *Falsifier:* a shared path changing
   verdict.
2. **`generate` is inert and the tests hold**: `src/` byte-identical after
   `tree-sitter generate`; `tree-sitter test` 150 of 150; the three query
   files load. No file under `grammar.js`, `src/`, `queries/` or `test/`
   changes for 0.2.34 itself.
3. **The seven new names parse as plain calls and paint as `print` does**:
   a scratch file calling each name read from `spec/prelude.json` at the
   tag (the tag's list minus the v0.2.33 list wolf-lsp trunk vendors, never
   typed by hand) parses with no `ERROR`/`MISSING`; each callee captures
   `function` exactly once; no `function.builtin` capture anywhere.
4. **The gate's branches at the unchanged floor** (`FLOOR="${FLOOR:-1117}"`),
   over the v0.2.34 corpus: default passes `1117 files gated`, `floor
   1117`; `FLOOR=1118` fails `checkout suspect`, rc 1; a copy with one
   gated file removed fails `only 1116 … floor is 1117`, rc 1; a copy with
   `fn main() -> !int { let ( = }` planted gates 1118 and fails `FAIL: 1
   file(s)` naming it, rc 1.
5. **The floor does not move** (1117 is the release count and already the
   floor); its record in `script/parse-wolf-corpus.sh` and the receiver's
   comment in `ci.yml` gain the v0.2.34 measurement with no number changed.
   **CI at the head** is green gating wolf-lang's trunk (1117 files or
   more), floor 1117; **a planted break goes red**: the default floor moved
   to 2000 reds the corpus step with `the floor is 2000`; its revert is
   green.

## 3b. tree-sitter-wolf#27, predicted before its first run

Committed after §3's runs (`g1`, `g2`) and before any run on #27's witness.
Every measurement on kasumi with a private `TREE_SITTER_LIBDIR`; the cause
is found black-box (the CLI's `parse` and `query` on variants, and scratch
copies of `src/scanner.c` with one branch disabled), never from tree-sitter's
source.

1. **The witness reproduces at trunk's `src/`**: `tree-sitter parse` of
   tl19's five lines gives `(line_comment [0, 15] - [1, 4])` and
   `(line_comment [3, 1] - [4, 4])`, each starting at the end of the token
   before the newline; a comment on its code's own line (`0 // c`) starts at
   its own `//`; a `//!` doc comment after a newline has the same shape.
2. **The guess at the cause**: the newline before the comment is a token
   (`_newline`, a terminator) rather than trivia, and the comment's start is
   that token's start. So a comment after a newline where no terminator is
   valid (inside an argument list's parentheses) starts at its own `//`, and
   the external scanner is not the cause (disabling its `else` lookahead in a
   scratch copy does not move either range). *Falsifier:* either of those.
3. **A fix, only with a case that shows it**: a highlight test
   (`test/highlight/comments.lu`, the repository's first since tl19 retired
   `never.lu` at `bedb686`) asserting `comment` on comments after a newline
   at a block's start, between statements, after an item at top level, and
   a doc comment, with a `type.builtin` caret on the line below one of them:
   **red at trunk's `src/`** (a caret's position read from the comment
   node's start lands a row up), **green after**. With it: `tree-sitter
   test` keeps its 150 corpus cases green; the per-file verdicts over the
   v0.2.34 corpus are unchanged (1155 paths, ERR 22, the same 22); the gate
   gates 1117 green; `generate` reproduces the committed `src/`.
4. **If no change keeps every corpus case and every verdict**, nothing under
   `grammar.js`, `src/` or `queries/` changes, the measured cause is written
   here, and #27 stays open with it.
5. **If `src/` changes**, the editors' grammar pin in wolf-lsp (helix `rev`,
   zed `commit`, both `e7388233`) does not move in this lane: pinning an
   unmerged head would make wolf-lsp's merge wait on this repository's. The
   pin move is an issue to file, with this branch's merged sha.

## 3, scored (written after the measurement; §1–§3 above are unedited since `1f6ba50`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | path sets against tl27's: 0 removed, 0 added, 0 changed (`os/term_editor_rows` `ok`); `ERR` 22; 1155 paths | `g1/verdicts-compare.txt` (head `1f6ba50`, corpus `9da7bdcf`): `tl27 paths 1155; now 1155; ERR now 22`, `only tl27 (removed)` empty, `same path, different verdict` empty, `added 0`; the 22 `ERR` paths are tl27's 22. Trunk's grammar under the gate, `g1/gate-trunk.log`: `1117 files gated, 38 … excluded` / `PASS … (1117 files, floor 1117)`, rc 0 — the receiver's 39602808647 reproduced | **yes** |
| 2 | `generate` inert; 150 of 150; the three queries load; nothing under `grammar.js`, `src/`, `queries/`, `test/` changes for 0.2.34 | `g1/ts-generate.log`, `g2/ts-generate.log`: `generate rc 0`, `src diff rc 0`; `g1/ts-test.log`, `g2/ts-test.log`: `Total parses: 150; successful parses: 150`; `g1/queries.log`, `g2/queries.log`: highlights, locals, injections rc 0; `g2/head.txt` (`c732660`): `src` tree `e8d4fd5e`, `queries` `cf647eb2`, `test` `884d5bfa`, `grammar.js` `2cac20e7`, tl27's four; `g2/diff-vs-trunk.stat`: this file, the script's record and the `ci.yml` comment only. (§3b then changes `src/`, `grammar.js` and `test/` for #27, not for 0.2.34) | **yes** |
| 3 | the 7 new names parse as calls and capture `function` once; no `function.builtin` | `g1/new-names-head.txt`: the tag's list (blob `b71ca9cd`) minus the v0.2.33 list wolf-lsp trunk vendors (blob `41ac122f`): `new names 7 kinds: 7 function`; `g1/calls-tree.txt`: 0 `ERROR`/`MISSING`; `g1/calls-summary.txt`: each callee captures `function` once (plus the CLI's fallback `variable` listing, as `print` does, as tl20–tl27 recorded; the summary's `not-exactly-one-function 7` counts that listing), `function.builtin captures anywhere: 0`. At the head again: `g4/calls-summary.txt` `ERROR nodes 0; function.builtin 0` | **yes** |
| 4 | default green at 1117; `FLOOR=1118` red; shrunk red; planted red | at `c732660` (script blob `f3539b41`): `g2/gate-committed-default.log` `PASS … (1117 files, floor 1117)`, rc 0; `g2/gate-floor-1118.log` `FAIL: only 1117 file(s) gated — the floor is 1118; checkout suspect`, rc 1; `g2/gate-committed-shrunk.log` (`os/signal_shell_rows.lu` removed from a scratch copy) `1116 files gated` / `FAIL: only 1116 … floor is 1117`, rc 1; `g2/gate-planted.log` `1118 files gated` / `FAIL: 1 file(s) …` / `…/tl31_planted_bad_let.lu`, rc 1; `g2/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0. The same four at the head `956a60f` (`g4/`) | **yes** |
| 5 | the floor does not move; CI green at the head gating wolf-lang's trunk; the floor-2000 plant red | `7fa3cf1` adds the v0.2.34 line to the floor's record, `FLOOR="${FLOOR:-1117}"` unchanged; `c732660` the receiver comment. CI: the PR | — (see the PR) |

## 3b, scored (written after the measurement; §3b above is unedited since `8af83eb`)

| # | predicted | measured | held? |
|---|---|---|---|
| 1 | the witness reproduces at trunk's `src/`; a same-line comment starts at its `//`; a doc comment after a newline has the same shape | `w27/out1/comments.txt` (scratch clone at `79b6e927`, private libdir `lib-w27a`): `witness` `(line_comment [0, 15] - [1, 4])` and `(line_comment [3, 1] - [4, 4])`, tl19's ranges exactly; `sameline` `(line_comment [1, 6] - [1, 10])`, its own `//`; `doc` `(doc_comment [1, 15] - [2, 5])` for a `//! d` on row 2 | **yes** |
| 2 | the newline is a token, not trivia, so a comment inside parentheses (no terminator valid) starts at its own `//`; the scanner's `else` lookahead is not the cause | `inparens` `(line_comment [2, 0] - [2, 4])`, its own `//`; variant A (`w27/out-A/`, the `else` lookahead disabled in a scratch copy) gives every range unchanged. **Refined by two more variants:** a comment after indentation starts at its own `//` (`indented`, `[2, 4]`), and after blank lines the start is the end of the last token before ALL of them (`gap`, `[1, 13] - [4, 6]` for a `// gap` on row 4). So the newlines are read as part of the comment token itself: where the terminator was a valid internal token, a `\n` (a separator in `extras` AND the start of `_newline`) was not skipped, and the token the lexer then produced, the comment, began before it; a space or tab, a separator only, is skipped and moves the start. The cause is tree-sitter's lexing of a separator that also starts a valid token, measured black-box | **yes, refined** |
| 3 | a highlight test red at trunk's `src/`, green after; 150 corpus cases; verdicts unchanged; gate 1117; `generate` reproduces `src/` | `test/highlight/comments.lu` (`5c748dc`, 7 assertions). Red at its own commit (trunk's `src/`): `g3/ts-test-red.log` `Failure - row: 2, column: 31, expected highlight 'operator', actual highlights: 'comment.line'`, rc 1 (the caret for row 9 read from a comment node starting on row 8's end, so two rows up and far right). The fix: `3f5d90c` makes `_newline` an external token, lexed by `src/scanner.c` beside `_newline_before_else` (one function decides between them at the newline; where neither is valid the newline is trivia the internal lexer skips; in error recovery it is still the terminator token, as it was when the internal lexer owned it); `956a60f` the regenerated `src/parser.c` and `src/grammar.json` (`node-types.json` unchanged). At `956a60f`: `g4/ts-test.log` `comments.lu (7 assertions)` ✓ and `Total parses: 150; successful parses: 150` (the six corpus cases that expect `ERROR`/`UNEXPECTED '\n'` among them), rc 0; `g4/ts-generate.log` `generate rc 0`, `src diff rc 0`; `g4/verdicts-diff.txt` `head ERR 22 g1 ERR 22`, diff rc 0 (1155 paths, every verdict trunk's); `g4/gate-committed-default.log` `1117 files gated` / `PASS`, rc 0, and the three failure branches red as at `g2`; `g4/w27-comments.txt`: every variant at its own `//` (`witness` `[1, 0] - [1, 4]` and `[4, 0] - [4, 4]`, `gap` `[4, 0]`, `doc` `[2, 0]`), `indented`, `inparens` and `sameline` unchanged | **yes** |
| 4 | if no change keeps every case, nothing changes and #27 stays open | a change kept every case (3) | — (not reached) |
| 5 | the editors' grammar pin in wolf-lsp does not move in this lane | helix `rev` and zed `commit` stay `e7388233` in wolf-lsp's tl31 branch; the move to this branch's merged sha is an issue to file | **yes** |

**What a reader in helix or zed sees change, once their pin moves: a
comment's range.** Every comment that follows one or more newlines where a
statement could end now starts at its own `//` instead of the previous line's
end (comment text objects, folding, and the `comment.line` capture's extent);
nothing else in any tree moves (150 corpus cases, 1155 verdicts). 0.2.34
itself added no syntax: the seven builtins are calls and paint as calls, as
`print` does, and ruling #77 (4) keeps it that way; the floor stays 1117.

## 4. Evidence index

Logs on kasumi under `~/lanes/tl31/`: `setup.log` (tags by `git ls-remote`,
release ids, the API's asset digests, each archive matched by `sha256sum` and
`openssl dgst`, members by name, `std/STD-REV` `e036bec3…` in both archives,
`wolf --version`, `wolf prelude --json` = blob `b71ca9cd`, the CLI's sha256),
`acquire/members.txt`, `g1/*` (trunk's grammar over the tag's corpus),
`g2/*` (the floor record's commit: the gate's branches), `w27/` (#27's
variants: `out1/` at trunk, `out-A/` the `else` lookahead disabled, `out-B/`
the external newline, `hl-trunk/` and `hl-B/` the highlight test in scratch),
`g3/*` (the highlight test red at its own commit; `generate` at the fix
commit), `g4/*` (the head: generate, test, queries, the gate's branches,
verdicts, the variants, the new names). The wolf-lang tree is the depth-1
clone at `9da7bdcf`; the CLI is `tsbin/tree-sitter`, sha256 `ad369a4d…`.
Private libdirs: `lib-g1`, `lib-g2`, `lib-w27*`, `lib-g3a`, `lib-g3b`,
`lib-g4` (`g4/libdirs.txt`). The tag comparisons (v0.2.33 against v0.2.34:
the EBNF, the grammar chapter, the parser, lexer and formatter trees, the
corpus path sets, the prelude's `(name, kind)` and mark sets) were read from
git objects in the org's wolf-lang clone on nomad-1 with `git rev-parse
<tag>:<path>`, `git diff --name-status` and a read-only Python key-set diff;
nothing was built or run there. CI run ids and the plants' red runs are in
the PR body.
