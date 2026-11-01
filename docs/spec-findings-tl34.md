# tl34 — the grammar at 0.2.36: the C variadic tail

wolf-lang cut **0.2.36** (its CHANGELOG dated 2026-10-26; `v0.2.36` =
`5adf3d91`, release 427033151, published 2026-10-28). s263 gave a C
membrane's parameter list a final `, ...` (`[abi.c.variadic.syntax]`), and
wolf-lang's corpus carries two files that spell it. Neither parses here:
the daily gate has been red since 2026-10-25 and the release dispatch was
red at the tag (§2). This file is lane tl34's contract and record for
tree-sitter-wolf: the production for every variadic form the spec clause
and the two corpus files use, a corpus case per form, the highlight query
for the new node, the gate at zero ERRORs over the whole corpus, and the
floor at the release. The wolf-lsp half (the pin at 0.2.36 and the prelude
delta: `VaList`, the four `va_*`, `env_arg0`, `env_args_bytes`) is wolf-lsp
`docs/PIN-0236.md` on its branch `tl34`. Contract: planning
`sprints/lsp/tl34-the-0236-variadics.md`; rules `sprints/the-lane-rules-1031.md`
and `sprints/RULES.md`; template tl31 (`docs/spec-findings-tl31.md`).

§1–§3 are committed before any change to `grammar.js`, `src/`, `queries/`
or `test/`. The runs §2 cites (`g0`) are trunk's grammar measured as it
stands, to reproduce the red CI reports; §3 is not edited after this
commit.

## 1. Forbidden, absolutely

- No grammar rule and no highlight query without a corpus or highlight case
  that shows it, **committed red first** (the case at trunk's grammar,
  failing, before the rule). **Prelude functions do not highlight as
  builtins** (ruling #77): no `@function.builtin` over `va_start`,
  `va_arg`, `va_copy`, `va_end`, `env_arg0` or `env_args_bytes`, and no
  builtin pattern for the prelude type `VaList`.
- The grammar is written from the spec's text alone (README): the
  compiler's parser and lexer are not read, at any commit. No library
  source that is not the maintainer's is read (RULES §1): tree-sitter is
  measured black-box (the CLI's `generate`, `test`, `parse`, `query`) and
  from its published documentation.
- Hosts: kasumi is offline and is never touched. tree-sitter work runs on
  nomad under `~/lanes/tl34/` (light work, the contract), each run with a
  private `TREE_SITTER_LIBDIR`, from a worktree pinned to a commit where a
  run measures a commit. No package is installed on any host: the CLI is
  the lockfile's own, `npm ci` in the lane's clone.
- No merge, label, tag, release, issue filed or closed; the branch asserted
  before every commit; no attribution trailers; no wait on CI (the run id
  is read once and handed back).
- The toolchain identities are the release's, by digest, each digest read
  twice and held to `sprints/release/r41-evidence.md`; never wolf-lang's
  trunk. The floor ratchets to the measured count at the release, never
  down and never above it. A count is compared as a set of paths both ways
  (wolf-lang#177). No "seen red" without a run id, sha or captured log in
  the same paragraph.

## 2. Inputs, re-derived 2026-10-31 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `fccb984d` | `fccb984d` (tl33's head), by a fresh clone on nomad; open issue #37 (the `nightly-red` issue `notify` opened on 2026-10-25) | none |
| wolf 0.2.36 | `v0.2.36` | annotated tag object `86d61559…` peels to `5adf3d91f75b3545ff8d38e5b6693b0b9f367a05` (`git rev-parse` in a blobless clone, `git ls-remote`); release **427033151**, `draft=false`, published 2026-10-28T19:20:00Z, five assets. The linux x86-64 archive hashed on hasu by `sha256sum` and `openssl dgst` (`d383c74c…`, 82,827,649 B) and the macOS arm64 archive on nomad by `shasum -a 256` and `openssl dgst` (`b79d5584…`, 19,426,565 B): each pair equal to each other, to the API's digest and to r41-evidence's table. `wolf --version` = `wolf 0.2.36 (wolfgang, pin 5adf3d9)` / `paired with lupin 0.1.58 (reference interpreter), pin a5378e3` | none |
| lupin 0.1.58 | `v0.1.58` | tag object `dc4689e3…` peels to `6240efe5570dba1a33ba6269e3ba44bae33dd972`; release 425116893; linux x86-64 `34f52792…` (hasu, `sha256sum` and `openssl`) and macOS `c1b02771…` (nomad, `shasum` and `openssl`), equal to the API's and r41-evidence's; `lupin 0.1.58 (wolf-interp, reference interpreter at pin a5378e3)`. This repository never runs lupin | none |
| **the grammar at 0.2.36** | s263's variadic forms | **It moved, by one production.** `spec/grammar.ebnf` blob `29d5de10` → `1e19bf67`, one line: `params ::= param (',' param)* ','?` became `params ::= param (',' param)* (',' '...' \| ','?)`. `spec/01-grammar.md` blob `c9eb5183` → `70fc2a14`: the same line, and the note "A final `, ...` is restricted to a C membrane, after at least one fixed parameter (`[abi.c.variadic.syntax]`). It is not a parameter named `...`, and cannot have a type, mode or trailing comma." `'...'` is the only terminal the EBNF gains. wolf-lang trunk `b16353e8` carries the tag's two blobs | one production owed |
| the clause | — | `spec/04-abi.md` `[abi.c.variadic.syntax]`: "A C membrane's parameter list may end in `, ...`, after at least one fixed parameter: `extern "c" fn f(n: i32, ...) -> i64` declares one; `export fn f(n: i32, ...) -> i64 { ... }` defines one. An `extern "c" fn` with a body is likewise a definition. The ellipsis has no name, type or passing mode. An ellipsis anywhere else in a parameter list, or on an ordinary wolf function, is E0822." E0822 is a membrane-tier code, not a parse-tier one (`E00xx`–`E02xx`, the gate's exclusion): `docs/diagnostics.md` "E0822 — an ellipsis outside the end of a C parameter list". `[abi.c.variadic.list]`: the decayed C `va_list` parameter is spelled `*VaList`. `[abi.c.variadic.builtins]`: `va_start() -> VaList`, `va_arg[T](mut ap: VaList) -> T`, `va_copy(ap: VaList) -> VaList`, `va_end(mut ap: VaList) -> ()`, all calls, inside `unsafe` | — |
| the two red files | — | `membrane/variadic_declarations.lu` (blob `5e819aaf`, `check: pass`): `extern "c" fn printf(fmt: *u8, ...) -> i32` and `export fn sum(n: i32, ...) -> i64 { 0 }`, each under `#[cfg(target = "x86_64-unknown-linux-gnu")]`; `membrane/variadic_position.lu` (blob `bd4ce8a8`, `check: fail(E0822)`): `export fn sum(n: i32, ..., last: i32) -> i64 { 0 }`. Neither directive is parse-tier, so both are gated. At trunk's grammar each `...` is one `ERROR` inside an intact `parameters` node (`(ERROR [8, 31] - [8, 34])` in the first, `(ERROR [5, 22] - [5, 26])`, the ellipsis and its comma, in the second) | — |
| corpus size | 1,199 gated (the nightly) | `corpus/**/*.lu`: 1217 at `v0.2.35`, **1228** at `v0.2.36`, 1239 at trunk `b16353e8`. As path sets `v0.2.35` → `v0.2.36`: **11 added, 0 modified, 0 removed** (`fs/copy_chunk_dev_full`, `fs/copy_chunk_failed_write`, `membrane/variadic_declarations`, `membrane/variadic_position`, `memory/read_lend_frame`, `memory/read_lend_value_semantics`, `os/arg0`, `os/args_bytes`, `rows/else_fallback_bound_slice`, `rows/else_fallback_paren_slice`, `rows/else_fallback_range_refused`); `v0.2.36` → trunk: 11 added (nine `memory/`, `rows/mixed_payload_display`, `typecheck/enum_str_bare_choice`), 0 modified, 0 removed. 40 parse-tier counter-examples excluded at all three, so **1177, 1188 and 1199 gated** | — |
| **the receiver** | its count | At 0.2.35: wolf-lang release run 39925705506, job 120321420168, `since v0.2.34: 69 file(s) moved …`; receiver run **39925733584**: `1177 files gated` / `PASS … (1177 files, floor 1117)`. The floor was not re-measured at 0.2.35 (tl33 moved a query and a corpus case only). At 0.2.36: release run 40744446774, job 123045500831, `since v0.2.35: 13 file(s) moved under spec/grammar.ebnf, spec/01-grammar.md, corpus/` / `dispatched wolf-lang-corpus to wolffe-lang/tree-sitter-wolf for v0.2.36 (5adf3d91…)`; receiver run **40744480999**: `1188 files gated, 40 parse-tier counter-examples excluded` / `FAIL: 2 file(s) with ERROR/MISSING nodes`, the two files above. **First red: the schedule run 40188948638 (2026-10-25)**, 1188 gated and the same two files, because wolf-lang's trunk carried s263's corpus (wolf-lang `a5378e3f`, "corpus: gate variadic declarations by target") three days before the tag. Every daily run since is red by the same two (40327041151, 40501689885, 40691604740, 40877874848, 41058905046, and 41201208450 at 1199 gated) | the floor is 71 below the release count |
| prelude names | — | `spec/prelude.json` blob `08172e0e` → `8c5b3207` (the acquired linux binary's `wolf prelude --json` is blob `8c5b3207` too): 207 → 214 names, as `(name, kind)` sets both ways **7 added, 0 removed, 0 entries changed**: `VaList` (`type`, `[abi.c.variadic.list]`), `va_start`, `va_arg`, `va_copy`, `va_end` (`function`, `[abi.c.variadic.builtins]`), `env_arg0`, `env_args_bytes` (`function`, `[os.host.sigs]`). Marks 19, unchanged. `VaList` is a prelude `type` beside `List`, `Map`, `Pool`, `Mutex`, `channel`, `Scope`, `Proc`, `range`, not a `builtin_type`; `queries/highlights.scm` paints such a name `@type` in type position through `(type_path (path (identifier) @type))` and has no list of them | nothing owed to the builtin list |
| tests | — | `test/corpus`: 151 cases (tl31's 150 and tl33's `v0.2.35 prelude function calls`), counted by header; `test/highlight/comments.lu`, 7 assertions. `grammar.js` blob `dfe40f99`, `src` tree `95de8068`, `queries` tree `cf647eb2`, `test` tree `8b924526`, the gate script blob `f3539b41` | — |
| tree-sitter-cli | — | 0.26.13 by `package-lock.json`. kasumi, where tl14–tl31 kept the linux CLI (`ad369a4d…`), is offline, so this lane's CLI is `npm ci`'s in the lane's clone on nomad: darwin arm64, binary sha256 `89375793…`. CI's is the same lockfile's linux build | a different host's build of the same version |
| **g0: trunk's grammar, measured** | the nightly's red | `script/parse-wolf-corpus.sh` at `fccb984d`: over `v0.2.35` `1177 files gated` / `PASS`, rc 0; over `v0.2.36` `1188 files gated` / `FAIL: 2 file(s)`, the two, rc 1; over trunk `b16353e8` `1199 files gated` / `FAIL: 2 file(s)`, the same two, rc 1 (the nightly reproduced). Per-file verdicts over every `.lu` file, excluded ones included: `v0.2.35` 1217 paths, `ERR` 23; `v0.2.36` 1228 paths, `ERR` 25; trunk `b16353e8` 1239 paths, `ERR` 25. As path sets `v0.2.35` → `v0.2.36`: 0 removed, 0 changed, 11 added, of which the two variadic files are `ERR` and nine are `ok`; `v0.2.36` → trunk: 0 removed, 0 changed, 11 added, all `ok`. The 23 shared `ERR` paths are all parse-tier counter-examples. Logs and verdict files: nomad `~/lanes/tl34/g0/` | — |

## 3. Prediction, committed before any change

1. **The new rows are red at trunk's grammar, and only where they spell
   the ellipsis.** Five corpus cases in `test/corpus/items.txt`: (a) the
   declaration and the definition, `extern "c" fn printf(fmt: *u8, ...) ->
   i32` and `export fn sum(n: i32, ...) -> i64 { 0 }`; (b) the ellipsis
   elsewhere, which the spec refuses as E0822 and not at the parse tier:
   `..., last: i32`, an ordinary `fn` with one, a lone `(...)`, and a
   trailing comma after it; (c) the decayed list parameter `ap: *VaList`;
   (d) the four builtins as calls inside a variadic definition's `unsafe`
   block; (e) s261's `env_arg0()` and `env_args_bytes()` as calls. At
   trunk's grammar (a), (b) and (d) fail (each has an `ERROR` where its
   ellipsis stands) and (c) and (e) pass: they are a path type and calls,
   which this grammar already parses. One highlight test,
   `test/highlight/variadic.lu`, is red at trunk's grammar (no node for
   `...` to capture). *Falsifier:* (a), (b) or (d) passing, or (c) or (e)
   failing.
2. **The rule.** `variadic_parameter`, a named leaf for the `...` token,
   becomes a third alternative of `_parameter` beside `parameter` and
   `self_parameter`, so the ellipsis is a member of any parameter list at
   any position, with the list's optional trailing comma. That is the
   README's superset: the spec puts the misplaced ellipsis, the ordinary
   function's and the one with nothing before it at E0822, a membrane-tier
   refusal, so they parse here as `x = take v` once did not and comparison
   chains do. A typed or moded ellipsis (`...: i32`, `mut ...`) is no
   spelling the spec or the corpus writes and stays an `ERROR`.
   `tree-sitter generate` adds the node to `src/grammar.json`,
   `src/node-types.json` and `src/parser.c` and reproduces the committed
   `src/` byte for byte afterwards. *Falsifier:* a new conflict that needs
   declaring, or `src/` not reproducing.
3. **The tests at the head**: `tree-sitter test` 156 of 156 corpus cases
   (151 + 5) and both highlight files green; the three query files load.
4. **Per-file verdicts at the head, as path sets against g0's**: over
   `v0.2.36`, 1228 paths both ways, exactly `membrane/variadic_declarations`
   and `membrane/variadic_position` move `ERR` → `ok`, `ERR` 25 → 23, no
   other path moves (none of the range files, none of the 40 excluded);
   over `v0.2.35`, 1217 paths, 0 changed; over trunk `b16353e8`, 1239
   paths, the same two and nothing else. *Falsifier:* any other path
   changing verdict, which would mean the new `...` token took a `..` or a
   `.` somewhere it never stood.
5. **The gate's branches at the new floor** (`FLOOR="${FLOOR:-1188}"`),
   over the `v0.2.36` corpus: the default passes `1188 files gated`,
   `floor 1188`; `FLOOR=1189` fails `checkout suspect`, rc 1; a copy with
   one gated file removed fails `only 1187 … floor is 1188`, rc 1; a copy
   with `fn main() -> !int { let ( = }` planted gates 1189 and fails
   `FAIL: 1 file(s)` naming it, rc 1. Over trunk `b16353e8`, `1199 files
   gated` / `PASS`.
6. **The highlights**: in `test/highlight/variadic.lu` the ellipsis
   captures `punctuation.special`; `VaList` in `*VaList` captures `type`;
   the callees `va_start`, `va_end` and `env_arg0` capture `function`;
   nothing in the file captures `function.builtin`.
7. **The floor ratchets 1117 → 1188**, the release's count (tl20's rule:
   never trunk's 1199); its record in `script/parse-wolf-corpus.sh` and the
   receiver's comment in `ci.yml` gain the 0.2.35 and 0.2.36 measurements.
8. **CI at the head** is green gating wolf-lang's trunk (1199 files or
   more, floor 1188). **The plant goes red by name**: `tl34-plant-variadic`,
   the head with `variadic_parameter` taken out of `_parameter` and `src/`
   regenerated (so Gate 1 stays green), and this lane's own variadic rows
   set aside (the corpus cases marked `:skip`, the highlight file removed)
   so that the run reaches Gate 4, is red at `wolf-lang corpus at zero
   ERRORs`, naming exactly the two membrane files. The same removal with
   the rows in place is red at `tree-sitter test` (Gate 2), by the names of
   the three cases and the highlight file, measured locally.
9. **What does not move here**: the editors' grammar pin in wolf-lsp
   (helix `rev`, zed `commit`, both `936a96f5` since tl32). Pinning an
   unmerged head would make wolf-lsp's merge wait on this repository's;
   the pin move to this branch's merged sha is an issue to file (tl31's
   §3b.5).
