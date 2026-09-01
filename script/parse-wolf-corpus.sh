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
# counter-examples excluded by directive.
FLOOR="${FLOOR:-454}"

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
