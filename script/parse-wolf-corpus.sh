#!/bin/sh
# Parse wolf-lang's corpus tree with tree-sitter-wolf and require zero
# ERROR/MISSING nodes on every file that is *lexically and syntactically
# valid* wolf.
#
# The corpus deliberately contains counter-examples: files whose `//!`
# header pins `check: fail(E00xx|E01xx|E02xx)` — grammar-reservation,
# lexer-tier, and parser-tier rejections. Those files do not parse by
# the spec's own word, so they are the only exclusions, and they are
# excluded by reading the directive, never by construct. Files that fail
# at later phases (resolve/typecheck/mem/…) parse fine and are gated.
#
# Usage: script/parse-wolf-corpus.sh <path-to-wolf-lang-corpus>

set -eu

CORPUS="${1:?usage: parse-wolf-corpus.sh <wolf-lang-corpus-dir>}"
TS="${TREE_SITTER:-./node_modules/.bin/tree-sitter}"

# The pass-count floor (le03): the gate must actually gate at least this
# many files, so a shrinking checkout (sparse-checkout drift, a wrong
# path) cannot go green by parsing nothing. Ratchets as the corpus grows,
# never down. Measured 443 at wolf-lang 83f83bb (le03); re-measured 454
# at v0.2.1 / trunk e6548a9 (le04) — 467 `.lu` files, 13 parse-tier
# counter-examples excluded by directive; re-measured 463 at v0.2.2
# (the corpus is byte-identical at the tag and at trunk 4d9683d) — 482
# `.lu` files, 19 parse-tier counter-examples excluded by directive;
# re-measured 466 at v0.2.3 / trunk 5241ab7 (le06) — 486 `.lu` files, 20
# parse-tier counter-examples excluded by directive; re-measured 478 at
# v0.2.4 / trunk 1323c4e (le07) — 503 `.lu` files, 25 parse-tier
# counter-examples excluded by directive, zero ERROR nodes. (The le07
# contract predicted 511 `.lu` files; the tree holds 503 at both the tag
# and trunk, and the floor follows the measurement.) Re-measured 482 at
# v0.2.5 / trunk 6263ffa (le08) — 507 `.lu` files (s137's four new
# witnesses: net/reuse_port, net/wait_readiness, net/inherit_listener,
# os/cpus), the same 25 parse-tier counter-examples excluded, zero ERROR
# nodes; the corpus is byte-identical at the tag and at trunk.
# Re-measured 483 at v0.2.6 / trunk 5b8841e (2026-09-08,
# tree-sitter-wolf#4) — 508 `.lu` files, the same 25 parse-tier
# counter-examples excluded, and the tag and trunk gate the identical
# count (their only corpus diff is a five-line edit to
# test/conc_schedules_test.lu, which adds no file).
# Re-measured 546 at trunk be348b9 (2026-09-11, tl01, the v0.2.11
# re-vendor) — 575 `.lu` files, 29 parse-tier counter-examples excluded.
# The corpus grew 67 files over five releases (v0.2.7..v0.2.11); the
# four new exclusions are s151's three refused `if`/`then` spellings
# (grammar/if_then_missing, if_then_mixed, if_then_let_body) and s147's
# refused open range arm (grammar/match_range_open), all E0201. The tag
# gates 541 of 570: trunk carries five more files than v0.2.11.
#
# Re-measured 577 at trunk c1e62fa (2026-09-12, tl04, the s157/s158
# surface) — 608 `.lu` files, 31 parse-tier counter-examples excluded,
# zero ERROR nodes. The corpus grew 33 files; the two new exclusions are
# s158's `list_lit_untyped_empty` (E0419) and `error_alias_open` (E0201).
# Worth knowing what this run cost: the gate reads wolf-lang's default
# branch, so s157 and s158 turned it red here with no push to this repo
# at all. The last recorded green (run 34633743874, 2026-09-11) simply
# predates them. Thirteen files were failing when tl04 opened — eight
# `list_lit_*`, four `error_alias_*`, and s157's `match_nullary_variant`,
# which belongs to no issue this repo had filed.
#
# Re-measured 584 at trunk 30731a6 = v0.2.14 (2026-09-15, tl08,
# tree-sitter-wolf#14) — 615 `.lu` files, the same 31 parse-tier
# counter-examples excluded, zero ERROR nodes. The corpus grew seven
# files (s159/s160's witnesses) and the grammar none: `git diff c1e62fa
# v0.2.14 -- spec/grammar.ebnf spec/01-grammar.md` is empty, so no
# production moved and the external scanner paid nothing. Witnessed at
# the boundary locally: FLOOR=584 passes, FLOOR=585 fails "checkout
# suspect" on the same 584 files.
#
# Re-measured 640 at trunk 6d2aa72 (2026-09-17, tl09, the v0.2.15 pin) —
# 672 `.lu` files, 32 parse-tier counter-examples excluded, zero ERROR
# nodes. TWO numbers exist at this bump and the floor takes the larger
# for the reason the paragraph below gives: the TAG `v0.2.15`
# (`2e4ca769`) gates **634** of 666, and trunk, six files further on,
# gates **640** of 672. The gate reads the DEFAULT BRANCH, so trunk is
# the number it will meet; 634 is recorded beside it because 634 is what
# the release-day dispatch actually ran (run 35213581814 and the 11:40
# schedule both printed "634 files gated, 32 parse-tier counter-examples
# excluded"). Witnessed at both boundaries locally: FLOOR=634 passes and
# FLOOR=635 fails at the tag, FLOOR=640 passes and FLOOR=641 fails at
# trunk.
#
# THE GRAMMAR MOVED AT THIS BUMP AND COST THIS REPOSITORY NOTHING, which
# is a measurement and not a shrug. `spec/grammar.ebnf` is +5 −2 over
# `v0.2.14..v0.2.15`: s163 paid wolf-lang#28's debt and wrote `FORMAT_SPEC`
# out as a real production — `FMT_FILL`, `FMT_ALIGN` and `FMT_TYPE` under
# the new `[type.interp.spec]` anchor — where it had been a comment
# citing a `spec §7.4` that never existed. `grammar.js` already models
# the whole of it permissively (`format_spec: ':' repeat1(choice(...))`,
# with `[gram.amb.fmtcolon]`'s rule that the first top-level `:` starts
# the spec and interpolations may nest inside it), so the written-out
# EBNF names what this mirror already accepted: zero productions changed,
# zero external-scanner work, `tree-sitter generate` reproduces `src/`
# byte-identically. Measured directly as well as by the corpus, on a
# fixture spelling every `FMT_TYPE` letter and every `FMT_ALIGN` form
# plus fill, sign, zero-pad, width, precision, a nested `{n:>{w}}` and a
# bare `{n:}` — zero ERROR nodes, against a negative control (`"{n:>8"`,
# an unterminated interpolation) that does produce them, so the check can
# still red.
#
# Re-measured 658 at trunk = v0.2.16 = `93a5fe50` (2026-09-24, tl11, the
# 0.2.16 pin) — 690 `.lu` files, 32 parse-tier counter-examples excluded,
# zero ERROR nodes. ONE number this time, not two: wolf-lang's default
# branch IS the tag at this cut (`origin/trunk` and `v0.2.16^{commit}`
# both resolve to 93a5fe50), so the number the gate will meet and the
# number at the release are the same number. The corpus grew 24 files
# and all 24 land in the GATED column: every refusal 0.2.16 adds sits at
# a later tier than the exclusion's `check: fail(E0[012]` — s175's
# `rows/negative/error_alias_private/` is E0304, s177's #444 witness
# `memory/move_field_use_after.lu` is E1001, `typecheck/list_lit_elem_unfit.lu`
# is E0415 and `strings/trim_cutset_refused.lu` is E0402. Witnessed at
# the boundary: FLOOR=658 passes, FLOOR=659 fails "checkout suspect" on
# the same 658 files.
#
# AND THE OTHER BRANCH WAS SEEN RED TOO, which the boundary alone does
# not prove. `FLOOR=659` exercises the pass-COUNT branch; the ERROR-NODE
# branch is the one this gate exists for, and a run that only ever
# passes has never shown it works. Planted `tl11_planted_error.lu`
# (`fn main() -> !int { let ( = }`) into a scratch COPY of the corpus:
# 659 gated, `FAIL: 1 file(s) with ERROR/MISSING nodes`, exit 1, the
# file named. Both failure branches and the pass branch, at this pin.
#
# THE GRAMMAR DID NOT MOVE AT THIS BUMP, and that is checked two ways
# rather than assumed. `spec/grammar.ebnf` is unchanged across
# `2e4ca769..93a5fe50`: `git diff --quiet` exits 0 AND the blob sha is
# `4b2ed9939875a8a7d65924449fbd2ba29a3fcd56` on both sides — the second
# check is the stronger one, because a diff can be quieted by a filter
# and a blob sha cannot. So no production moved, the external scanner
# paid nothing, and no word or symbolic terminal joined the inventory.
# `tree-sitter generate` at this pin leaves `src/` byte-identical
# (`git diff --exit-code -- src/`, clean), which is the check run rather
# than a regenerate committed: a commit of identical bytes would be a
# claim that something moved. The `FORMAT_SPEC` write-out that cost tl09
# five contextual rulings was the PREVIOUS release's and does not recur.
#
# Re-measured 675 at trunk = v0.2.17 = `02afce84` (2026-09-26, tl13,
# tree-sitter-wolf#19) — 707 `.lu` files, the same 32 parse-tier
# counter-examples excluded, zero ERROR nodes. ONE number again: wolf-lang's
# default branch is the tag at this cut. The corpus grew 17 files, all
# gated. THE GRAMMAR MOVED THIS TIME: s182's `[gram.expr.assign]` admits
# `take` on the right of a plain `=` whose place is a container element
# (`index_place '=' 'take' expr`), and three of the new files spell it
# (`memory/index_store_take_{list,map,read_param}.lu`, E1001/E1001/E1014 —
# later tiers, so gated). The trunk grammar (19ec204) parsed 672 of the 675
# and ERRORed on exactly those three: the red #19 recorded from the daily
# gate on 2026-09-25 (run 36131591364) and the release dispatch on 09-26
# (run 36212574034), before the tag and at it. `assignment_statement` grew
# the moded arm, and the refused spellings (`x = take v`, `s.f = take v`,
# `xs[0] += take v`, `xs[0].f = take v`, `xs[0] = mut v`) stay ERROR —
# the compiler's E0201 — pinned as `:error` cases in test/corpus.
# Witnessed at the boundary: FLOOR=675 passes, FLOOR=676 fails "checkout
# suspect" on the same 675 files; and the ERROR branch on a scratch copy
# with `x = take xs` planted: 676 gated, `FAIL: 1 file(s)`, the file named.
#
# Re-measured 715 at trunk = v0.2.18 = `ec56a08f` (2026-09-28, tl14) —
# 747 `.lu` files, the same 32 parse-tier counter-examples excluded, zero
# ERROR nodes, with a private TREE_SITTER_LIBDIR. One number: wolf-lang's
# default branch is the tag at this cut. The corpus grew 40 files over
# v0.2.17..v0.2.18, all under `corpus/memory/` and all gated — s183's seven
# `ctl_store_order*`, eg01/eg01b's 24 `elem_*`, s184's nine `mut_param_*`
# (memory-tier refusals or `run`, never `fail(E0[012]`). The grammar did not
# move: `spec/grammar.ebnf` is blob `3f24d076` at both tags, `tree-sitter
# generate` leaves `src/` byte-identical, and the receiver's release
# dispatch (run 36333447636, at `ec56a08f`) had already gated the same 715
# against the old floor. Witnessed at the boundary: FLOOR=715 passes,
# FLOOR=716 fails "checkout suspect" on the same 715 files; and the ERROR
# branch on a scratch copy with `fn main() -> !int { let ( = }` planted:
# 716 gated, `FAIL: 1 file(s)`, the file named.
#
# Re-measured 746 at trunk = v0.2.19 = `c2401f05` (2026-09-30, tl15) —
# 778 `.lu` files, the same 32 parse-tier counter-examples excluded, zero
# ERROR nodes, with a private TREE_SITTER_LIBDIR. The corpus grew 31 files
# over v0.2.18..v0.2.19 (eg02, eg02b, s185; all `corpus/memory/`, all
# gated), and the receiver's release dispatch (run 36740260729) had
# already gated the same 746 against the old floor. The same cut reserved
# `take` and `mut` (#20); the per-file verdicts over all 778 files are
# identical under trunk's grammar and the reserving one. Witnessed at the
# boundary: FLOOR=746 passes, FLOOR=747 fails "checkout suspect" on the
# same 746 files; and the ERROR branch on a scratch copy with #20's own
# shape planted (`x = take (v)` in a `fn main`): 747 gated and PASS under
# the old grammar — the blindness #20 names — and `FAIL: 1 file(s)`, the
# file named, under the new one.
#
# Re-measured 829 at v0.2.20 = `cdde128a` (2026-10-02, tl16) — 861 `.lu`
# files, the same 32 parse-tier counter-examples excluded, zero ERROR
# nodes, with a private TREE_SITTER_LIBDIR. wolf-lang's default branch had
# moved past the tag (s195, `6a57f943`) by the time this was written, but
# `git diff v0.2.20 origin/trunk -- corpus/ spec/` is empty, so the tag and
# the checkout gate the same 829. The corpus grew 83 files over
# v0.2.19..v0.2.20 (s186, s187, s189–s194, eg03: 76 `corpus/memory/`, 7
# `corpus/rows/`; none carries a parse-tier directive), and the receiver's
# release dispatch (run 36955900148) had already gated the same 829 against
# the old floor. The grammar did not move: `spec/grammar.ebnf` is blob
# `3f24d076` at v0.2.18, v0.2.19 and v0.2.20 (the cut's two rulings,
# `[mem.tier0.excl.4]` and `[type.row.else]`, are semantics over spellings
# the grammar already parsed), and the per-file verdicts over the 778 files
# both tags share are identical to tl15's, compared as path sets both ways
# (0 removed, 0 changed, exactly the 83 added, all parsing clean). Witnessed
# at the boundary: FLOOR=829 passes, FLOOR=830 fails "checkout suspect" on
# the same 829 files; and the ERROR branch on a scratch copy with
# `fn main() -> !int { let ( = }` planted: 830 gated, `FAIL: 1 file(s)`, the
# file named.
#
# Re-measured 969 at v0.2.25 = `6710f9e0` (2026-10-07, tl18) — 1007 `.lu`
# files, 38 parse-tier counter-examples excluded (tl16's 32 plus s203's six
# `rows/negative/first_*`, ruling #28), zero ERROR nodes, with a private
# TREE_SITTER_LIBDIR. Five releases since tl16: 146 files added, 5
# modified, 0 removed. The grammar DID move this time: v0.2.23 (kw09,
# wolf-lang `231219b6`) added `extern_let_item ::= 'extern' STRING 'let'
# IDENT ':' type TERM`, and the receiver went red on its two corpus files
# (`membrane/extern_let_image.lu`, `membrane/extern_let_not_ptr.lu`) from
# the v0.2.23 dispatch (run 37211326706) through v0.2.25's (run
# 37679728322) — tree-sitter-wolf#25. The rule `extern_let_declaration`
# parses both; no other file's verdict moves. Witnessed at the boundary:
# FLOOR=969 passes, FLOOR=970 fails "checkout suspect" on the same 969
# files; and the ERROR branch on a scratch copy with
# `fn main() -> !int { let ( = }` planted: 970 gated, `FAIL: 1 file(s)`,
# the file named.
#
# Re-measured 1019 at v0.2.26 = `89dc1394` (2026-10-09, tl19) — 1057 `.lu`
# files, the same 38 parse-tier counter-examples excluded, zero ERROR nodes,
# with a private TREE_SITTER_LIBDIR. One release since tl18: 50 files added
# (31 memory, 9 typecheck, 4 comptime, 3 os, 3 fs), 0 modified, 0 removed,
# none of the 50 excluded. The grammar did not move: `spec/grammar.ebnf` is
# blob `29d5de10` at v0.2.25 and v0.2.26, and the cut's three spellings —
# `-> never` (ruling #50), `!` on an integer (#51), `copy region { … }`
# (#56) — parse as the name, the unary operator and the `copy` prefix over a
# region block this grammar already had; the receiver at the tag (run
# 37963437735) gated all 1019 green against the old floor. Per-file verdicts
# against tl18's: 0 removed, 0 changed, exactly the 50 added, all clean.
# Witnessed at the boundary: FLOOR=1019 passes, FLOOR=1020 fails "checkout
# suspect" on the same 1019 files; a shrunk copy fails the committed
# default; and the ERROR branch on a scratch copy with
# `fn main() -> !int { let ( = }` planted: 1020 gated, `FAIL: 1 file(s)`,
# the file named.
#
# The gate checks out wolf-lang's DEFAULT BRANCH, so this floor tracks
# trunk and not a tag. Leaving it at a v0.2.2 measurement while trunk
# carried three more files would let the gate lose three files' worth of
# coverage without saying so, which is the whole failure the ratchet
# exists to prevent.
FLOOR="${FLOOR:-1019}"

total=0
skipped=0
failed=0

fail_list=$(mktemp)
trap 'rm -f "$fail_list"' EXIT

for f in $(find "$CORPUS" -name '*.lu' | LC_ALL=C sort); do
  # Parse-tier counter-example? (directive scan, header only)
  if head -n 20 "$f" | grep -q 'check: fail(E0[012]'; then
    skipped=$((skipped + 1))
    continue
  fi
  # Member of a directory-module counter-example (D59): the program's
  # directive lives in the module's entry.lu, and a deliberately
  # unparseable *member* (corpus/resolve/broken_sibling/mangled.lu) is
  # the very thing the entry's parse-tier `fail(...)` pins. Still by
  # directive, never by construct — the directive is just one file over.
  entry="$(dirname "$f")/entry.lu"
  if [ -f "$entry" ] && [ "$f" != "$entry" ] \
    && head -n 20 "$entry" | grep -q 'check: fail(E0[012]'; then
    skipped=$((skipped + 1))
    continue
  fi
  total=$((total + 1))
  # `tree-sitter parse -q` exits non-zero when the tree contains
  # ERROR/MISSING nodes.
  # $TS unquoted on purpose: it may be a multi-word command (npx tree-sitter)
  if ! $TS parse -q "$f" >/dev/null 2>&1; then
    failed=$((failed + 1))
    echo "$f" >>"$fail_list"
  fi
done

echo "wolf-lang corpus: $total files gated, $skipped parse-tier counter-examples excluded"
if [ "$failed" -ne 0 ]; then
  echo "FAIL: $failed file(s) with ERROR/MISSING nodes:"
  cat "$fail_list"
  exit 1
fi
if [ "$total" -lt "$FLOOR" ]; then
  echo "FAIL: only $total file(s) gated — the floor is $FLOOR; checkout suspect"
  exit 1
fi
echo "PASS: zero ERROR nodes across the corpus ($total files, floor $FLOOR)"
