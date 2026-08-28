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
  total=$((total + 1))
  # `tree-sitter parse -q` exits non-zero when the tree contains
  # ERROR/MISSING nodes.
  if ! "$TS" parse -q "$f" >/dev/null 2>&1; then
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
echo "PASS: zero ERROR nodes across the corpus"
