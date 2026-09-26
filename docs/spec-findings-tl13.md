# tl13 — the moded store, and the floor at 0.2.17

wolf-lang cut **0.2.17** on 2026-09-26 (`02afce84`, release 397045016). s182's
`[gram.expr.assign]` clause admits one mode in one assignment position, and
this grammar did not know it, so the receiver went red at the tag
(tree-sitter-wolf#19). This file is the lane's contract and record. The
orchestrator's contract template is tl11's
(`wolf/sprints/tooling/tl11-the-pins-at-0216.md`); the row is wave 48's tl13.

## 1. Forbidden, absolutely

- No `rm` outside `~/lanes/tl13/` on kasumi and `/private/tmp/tl13` here; no
  deletion in any tree this lane did not create.
- No `git add -A`; no edit to another lane's file; nothing under `~/.claude`.
- No build on nomad-1: `tree-sitter generate`, `tree-sitter test` and the corpus
  gate run on kasumi under `~/lanes/tl13/`. nomad-1 holds the worktree and git.
- No merge, no rebase-merge; no `2>/dev/null` on a checkout; assert the branch
  before every commit.
- No "seen red" without a run id, sha, path or captured output in the same
  paragraph.
- **The grammar admits `take` exactly where the clause does and nowhere else.**
  `x = take v`, `s.f = take v`, `xs[0] += take v` and `xs[0].f = take v` stay
  ERROR nodes — the compiler's E0201 — and a test says so.
- No closing #19 before the orchestrator's merge prints a trunk sha; the
  closure is its own command, after.
- Kill only pids this lane started, never a pattern or a process group.
- CI is read with `gh run view`; any watch uses `--interval 60`. Waits print
  elapsed time at least every five minutes.
- No attribution trailers on any commit or PR.

## 2. Inputs, re-derived 2026-09-26 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `19ec204` | `19ec2048` (`git ls-remote origin refs/heads/trunk`, "changelog: tl11") | none |
| wolf-lang v0.2.17 | the tag | `v0.2.17^{commit}` = `02afce84f05c7841856a10671b6d7924f79193cc`; wolf-lang `origin/trunk` is the **same** commit (`ls-remote`), so the gate's default-branch checkout and the tag are one tree | none |
| the clause | s182's `[gram.expr.assign]` | `spec/01-grammar.md` +16 prose, +2 EBNF; `spec/grammar.ebnf` +2 (blob `4b2ed993…` → `3f24d076fde0079aa3b6260b8cbadc97a35a9eff`), commits `7da059cf` (the clause) and `1a78a810` (the EBNF) over `v0.2.16..v0.2.17`. Quoted below | none |
| the production | `index_place '=' 'take' expr` | `assign_stmt ::= place assign_op expr TERM \| index_place '=' 'take' expr TERM`, `index_place ::= expr '[' expr ']'` | none |
| the compiler's shape | — | `crates/wolf_parse/src/exprs.rs:466-471` at the tag: the `take` token is bumped iff the operator is plain `=`, the head is a `BracketApply`, and the next token is `Kw(Take)`; otherwise the expression parser meets `take` and refuses (E0201) | see note |
| the compiler's witnesses | — | `crates/wolf_parse/tests/expr_grammar.rs:448` `an_index_store_admits_take` (`xs[0] = take v`, `m["k"] = take v`, `a.b[i] = take (v)`, and `xs[0] = v` unmoded) and `:476` `take_outside_an_index_store_is_e0201` (`x = take v`, `s.f = take v`, `xs[0] += take v`, `xs[0].f = take v`) | none — this lane mirrors both lists |
| the three red files | `corpus/memory/index_store_take_*.lu` | `index_store_take_list.lu` (`fail(E1001)`), `index_store_take_map.lu` (`fail(E1001)`), `index_store_take_read_param.lu` (`fail(E1014)`); none carries `fail(E0[012]`, so all three are GATED, not excluded | none |
| the receiver at the tag | red (#19) | run **36212574034**, `repository_dispatch`, 2026-09-26T02:43:19Z (the release was created 02:43:07Z), gate job 02:43:22→02:47:08, `675 files gated, 32 parse-tier counter-examples excluded`, `FAIL: 3 file(s)`, exactly the three files above; `notify` commented on #19 | see note |
| #19 | open | open; opened by schedule run **36131591364** (2026-09-25T11:50Z, the same three files, the same 675) — **a day BEFORE the tag**: s180 landed the witnesses on wolf-lang trunk and the daily gate met them first. Schedule run 36238719856 (09-26) red again | drift: #19 predates the tag |
| the pin | "moves to v0.2.17" | **there is no pin file in this repo.** The gate reads wolf-lang's default branch; the only recorded pin is the ratchet's paragraph in `script/parse-wolf-corpus.sh` naming the sha each floor was measured at (last: `93a5fe50`, v0.2.16) and `CHANGELOG.md`. "The pin moves" means that record moves to `02afce84` | drift: wording |
| the ratchet | — | `script/parse-wolf-corpus.sh:142`, `FLOOR="${FLOOR:-658}"` (`grep -nF`; tl11 quoted `:107`, the line before its own 35-line paragraph landed above it) | drift: line number |
| corpus size | — | **707** `.lu` at `02afce84` (sparse clone on kasumi, `find corpus -name '*.lu' \| wc -l`), 690 at `93a5fe50` (tl11); +17 files, all from `git diff --stat v0.2.16 v0.2.17 -- corpus` (15 under `corpus/memory/`, 2 under `corpus/resolve/sibling_diag/`) | none |
| tree-sitter-cli | — | 0.26.13 (`package-lock.json`); kasumi node v26.8.1 | none |
| `tree-sitter test` | — | 127 cases at trunk (`test/corpus/*.txt`, 11 files) | none |

**Note on the compiler's shape.** The EBNF's `index_place ::= expr '[' expr ']'`
reads as a one-index subscript, but the compiler admits the move after any
`BracketApply` head — the single postfix bracket shape that serves indexing and
generic application alike (`[gram.amb.brackets]`, D29), with sema deciding
whether the bracket is a container. This grammar has the same single shape,
`index_expression`. So the mirror is `left: index_expression`, and the grammar
admits `take` after exactly the heads the compiler admits it after: no wider
(no `mut`, no compound operator, no non-bracket head) and no narrower.

**Note on the receiver.** A `repository_dispatch` always runs the workflow at
this repository's default branch, so no dispatch can turn green before the
merge. Pre-merge, the receiver workflow is run on the branch by
`workflow_dispatch --ref tl13` (the same `gate` job, against the same wolf-lang
default branch = the tag); the `pull_request` run is the same job again.
After the orchestrator's merge, one `wolf-lang-corpus` dispatch at trunk is the
receiver's own green, and #19 closes by hand citing it.

The clause, quoted from `spec/01-grammar.md` at `02afce84`:

> **One store position carries a mode** (ruled 2026-09-24, wolf-lang#438 — the
> index store follows `push`): the right-hand side of a plain `=` whose place is
> a container element — `xs[i] = take v`, `m[k] = take v` — may be spelled
> `take`, and nowhere else in an assignment may a mode appear. `take` is a
> call-site mode, not an expression, so `x = take v`, `s.f = take v` and every
> compound operator's right-hand side fail to parse exactly as before (E0201).

## 3. Prediction, committed before `tree-sitter generate` or the gate runs

1. **The rule.** `assignment_statement` becomes a two-way choice: the existing
   `place assign_op expr` arm unchanged, and a new arm
   `index_expression '=' 'take' expr` with `take` as an anonymous token under a
   `mode` field (no new node type — wolf-lsp's node inventory does not move;
   `"take"` is already `@keyword.storage.modifier` in `highlights.scm`, so the
   query files need no edit). **One** LR conflict appears (the arm's
   `index_expression` against its reduction to `_expression` on `=`), declared
   and resolved by GLR on the next token. Falsified if generate reports more
   than one conflict or none.
2. **The tests.** `tree-sitter test`: 127 → **132** cases, all passing — one
   positive case carrying the compiler's three admitted spellings plus the
   unmoded `xs[0] = v`, and one `:error` case for each of the four refused
   spellings. Each refused spelling produces an ERROR node, and `xs[0] = v`
   still parses on the old arm with no `mode`. Falsified by any failure or by a
   refused spelling that parses clean.
3. **The corpus.** At `02afce84`: **707 `.lu`, 32 excluded, 675 gated, zero
   ERROR nodes** — the three `index_store_take_*` files move from ERROR to clean
   and no other file changes verdict. The floor ratchets **658 → 675**.
   Falsified if the count is not 675, if the excluded count moves, or if any
   other file reds.
4. **Both failure branches seen red at the new floor:** `FLOOR=675` passes,
   `FLOOR=676` fails "checkout suspect"; a planted ERROR file in a scratch copy
   fails with the file named. And the old grammar (trunk `19ec204`) against the
   same corpus fails with exactly the three files — the red the fix answers.
5. **`src/` moves** (unlike tl11): `parser.c`, `grammar.json`,
   `node-types.json` regenerate and are committed; gate 1 (`git diff
   --exit-code -- src/` after a CI regenerate) is green at head.
6. **Queries** load unchanged.

## 4. Evidence index

Filled as the work lands; every line cites a run id, a sha, a path or a
captured output.

## 5. Done-when

- branch `tl13` on origin; PR open, unmerged
- CI green at the head sha (`gh run view`), and the branch-run receiver
  (`workflow_dispatch --ref tl13`) green against wolf-lang `02afce84`
- the §3 commit precedes the grammar commit
- the floor at 675 (or the measured count), both failure branches seen red with
  captured output
- #19 open until the orchestrator's merge; closed by hand after, citing the sha
  and the post-merge receiver run
- `/private/tmp/tl13` removed; `~/lanes/tl13/` holds only this lane's clones; no
  orphan process
