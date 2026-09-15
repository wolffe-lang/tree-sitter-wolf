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
# The gate checks out wolf-lang's DEFAULT BRANCH, so this floor tracks
# trunk and not a tag. Leaving it at a v0.2.2 measurement while trunk
# carried three more files would let the gate lose three files' worth of
# coverage without saying so, which is the whole failure the ratchet
# exists to prevent.
FLOOR="${FLOOR:-577}"

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
