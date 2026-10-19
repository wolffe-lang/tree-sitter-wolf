#!/usr/bin/env python3
"""ci/tiers.py — whether a CI run ran every job green (tl28, ruling #92).

    ci/tiers.py verdict        (NEEDS: the `tier` job's `toJSON(needs)`)

tree-sitter-wolf has ONE tier, `full`. Its suite is one job, `gate`: the
generated parser in sync, the grammar's corpus, the queries loading, and
wolf-lang's whole corpus at zero ERROR nodes, on ubuntu, in about five
minutes. Every gate reads the grammar, so there is nothing a path could
leave out: no plan, and every run (a pull request's push, a push to trunk,
the daily schedule, a release's dispatch, a manual dispatch) runs it all.
The run's verdict job is still named `tier full`, so wolf/tools/lane-audit.sh
reads this repository the way it reads a tiered one.

`verdict` exits 0 when the tier job needs at least one job and every one of
them succeeded, 1 otherwise, and prints each job's result.
"""
import json
import os
import sys


def verdict(needs):
    if not needs:
        print("tier full: the tier job needs no job")
        return 1
    bad = 0
    print("tier full: %d job(s)" % len(needs))
    for job, r in needs.items():
        got = (r or {}).get("result")
        ok = got == "success"
        bad += not ok
        print("  %-18s %-9s %s" % (job, got, "ok" if ok else "WANTED success"))
    return 1 if bad else 0


def main():
    if sys.argv[1:] != ["verdict"]:
        print("usage: ci/tiers.py verdict", file=sys.stderr)
        sys.exit(2)
    sys.exit(verdict(json.loads(os.environ["NEEDS"])))


if __name__ == "__main__":
    main()
