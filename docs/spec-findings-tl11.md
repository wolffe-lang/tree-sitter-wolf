# tl11 — the floor at 0.2.16, and a grammar that did not move

wolf-lang cut **0.2.16** on 2026-09-24 (`93a5fe50`, release 395302343). This
repository mirrors `spec/grammar.ebnf` and gates wolf-lang's corpus; this file
is the lane's record in the order the work happened.

## 2. Inputs, re-derived 2026-09-24 against origin

| input | contract said | measured | drift |
|---|---|---|---|
| tree-sitter-wolf trunk | `0baec4c` | `0baec4c` (`origin/trunk`, "changelog: tl09") | none |
| the floor's ratchet | "the orchestrator's grep returned nothing" | **located**: `script/parse-wolf-corpus.sh:107`, spelled `FLOOR="${FLOOR:-640}"` | see below |
| floor at tl09 | 640 at wolf-lang trunk `6d2aa72`; 634 at the v0.2.15 tag | both quoted verbatim in the script's own comment (lines 71–82) | none |
| corpus size | 666 → 690 `.lu` between the tags | **666** at `2e4ca769`, **690** at `93a5fe50` | none |
| the receiver already ran | run 35952891188 | confirmed below | none |

**Why the grep found nothing, which is worth a sentence.** The ratchet is not a
constant with `FLOOR` or `RATCHET` in a name anyone would grep for in a config
file — it is a **shell default-value expansion on one line of a POSIX `sh`
script**, `FLOOR="${FLOOR:-640}"`, and the number lives inside `${…:-…}`. A
grep for `floor =` or `ratchet` matches the 88 lines of comment ABOVE it (which
are the ratchet's whole history, every re-measurement since le03) and not the
line that decides anything. The comment is the documentation; line 107 is the
gate. This is wave-45's seventh false-signal shape in miniature — *grep for
what is missing, and check the grep can see where it lives* — and the null
result was evidence about the pattern, not about the repository.

**The dispatch is not this lane's item, and it worked.** wolf-lang's
grammar-mirror dispatch fired on the `v0.2.16` tag and this repository's
receiver ran as **`repository_dispatch`** run **35952891188**, conclusion
success, nine seconds after the tag. Nine seconds is the SENDER-side receipt
job, not a corpus parse: a corpus parse takes minutes (tl09's took 3m23s), so
by the rule that a fast green on a slow job is a defect report, **that run's
nine seconds must not be read as "the corpus was gated"**. It is read here only
as what it is — the dispatch path delivering. The secret is
`TREE_SITTER_WOLF_DISPATCH_TOKEN`, which is tl09's correction to the contract
that named `WOLF_CI_TOKEN`; a token that had lapsed would produce a green of
the same length, so the corpus number below is measured on this branch and not
inferred from that run.

## 3. Prediction, committed before anything is measured or regenerated

Written with `script/parse-wolf-corpus.sh` still reading `FLOOR:-640` and before
`tree-sitter generate` or the corpus gate was run at the new pin.

### The floor

wolf-lang's **default branch is AT the tag** — `origin/trunk` resolves to
`93a5fe50`, the same commit `v0.2.16^{commit}` peels to. Unlike the last two
bumps there is no gap between "the number the gate will meet" and "the number
the release-day dispatch ran", so the two-numbers paragraph the ratchet grew at
tl09 should collapse to one.

**Predicted: 32 parse-tier counter-examples excluded — unchanged — so 690 − 32
= 658 files gated, at the tag and at trunk alike, zero ERROR nodes, and the
floor ratchets 640 → 658.**

The exclusion is by directive and only ever matches `check: fail(E0[012]` —
grammar, lexer and parser tier. Every refusal 0.2.16 adds that I can name from
the release notes sits at a LATER tier and is therefore gated rather than
excluded: `corpus/rows/negative/error_alias_private/` is E0304,
`corpus/memory/move_field_use_after.lu` is E1001,
`corpus/typecheck/list_lit_elem_unfit.lu` is E0415 and
`corpus/strings/trim_cutset_refused.lu` is E0402. So the 24 new files should
land 24-for-24 in the gated column.

**Falsifiers:** any gated count other than 658; any exclusion count other than
32; any file with an ERROR or MISSING node.

### The grammar

**Predicted: no drift at all, and `src/` is reproduced byte-identically.**
`spec/grammar.ebnf` is unchanged across `2e4ca769..93a5fe50` — `git diff
--quiet` exits **0** and the blob sha is `4b2ed9939875a8a7d65924449fbd2ba29a3fcd56`
on both sides, which is the stronger of the two checks because it cannot be
fooled by a whitespace filter. So no production moved, the external scanner
pays nothing, no word terminal and no symbolic terminal joins the inventory,
and `tree-sitter generate` must leave `grammar.json`, `node-types.json`,
`parser.c` and `scanner.c` byte-identical. The `FORMAT_SPEC` write-out that
cost tl09 five contextual rulings was the PREVIOUS release's and does not
recur.

**Falsifier:** one byte of `src/` rewritten by a regenerate at this pin.

**And the corollary the contract names: nothing is regenerated that a
no-change would leave byte-identical.** The regenerate is run as a CHECK — to
prove the claim above — and its output is not committed, because a commit of
identical bytes is a claim that something moved.

### The boundaries

The floor is not asserted from one green. It is witnessed at **N pass and N+1
fail** — the "checkout suspect" branch of the gate — at the tag and at trunk
both, as the ratchet's own comment has required since tl08.
