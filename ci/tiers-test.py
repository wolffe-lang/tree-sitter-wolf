#!/usr/bin/env python3
"""ci/tiers-test.py — the wiring's own proof (tl28). python3 and bash only.

    ci/tiers-test.py

tree-sitter-wolf has one tier (ci/tiers.py), so this proves the shape around
it:

  T4  .github/workflows/ci.yml: a push on trunk alone, the pull request, the
      daily schedule, a dispatch whose tier input is full alone, the
      release's repository_dispatch; cancel-in-progress for pull requests
      only, every other run a group of its own run id; the `tier full` job
      last, needing the gate, running on `!cancelled()`, this file first and
      the verdict after; `notify` and `sleep-alarm` on their own conditions,
      never a pull request's or a push's.
  T6  the verdict: green when every job succeeded; red for a job failed,
      skipped or cancelled, and for a tier job that needs no job.
  T8  notify's script, read out of the workflow and run against a stand-in
      `gh`: no open issue opens one under the marker, labelled nightly-red;
      an open one gets a comment and no new issue; a label that already
      exists is no failure.

Exit 0 when every check passes, 1 otherwise.
"""
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
VERDICT = os.path.join(ROOT, "ci", "tiers.py")
WORKFLOW = os.path.join(ROOT, ".github", "workflows", "ci.yml")
fails = 0


def say(ok, what):
    global fails
    print("tiers-test: %s %s" % ("PASS" if ok else "FAIL", what))
    fails += not ok


wf = open(WORKFLOW, encoding="utf-8").read()
JOBS = re.findall(r"^  ([A-Za-z0-9_-]+):\s*$", wf[wf.index("\njobs:\n"):], re.M)
blocks = {}
for j in JOBS:
    m = re.search(r"^  %s:\s*\n(.*?)(?=^  [A-Za-z0-9_-]+:\s*$|\Z)" % re.escape(j), wf, re.M | re.S)
    blocks[j] = m.group(1) if m else ""

# --- T4 the wiring ---------------------------------------------------------------
say(JOBS == ["gate", "sleep-alarm", "notify", "tier"], "T4 the workflow's jobs: %s" % " ".join(JOBS))
t = blocks["tier"]
say("    name: tier full\n" in t and "    needs: [gate]\n" in t, "T4 the verdict job is named tier full and needs the gate")
say(re.findall(r"^    if: (.*)$", t, re.M) == ["${{ !cancelled() }}"], "T4 the tier job runs on !cancelled(), never always()")
say("        run: python3 ci/tiers-test.py\n" in t and "        run: python3 ci/tiers.py verdict\n" in t
    and t.index("ci/tiers-test.py") < t.index("ci/tiers.py verdict") and "          NEEDS: ${{ toJSON(needs) }}\n" in t,
    "T4 the tier job proves the wiring, then checks the verdict over toJSON(needs)")
say("  cancel-in-progress: ${{ github.event_name == 'pull_request' }}\n" in wf, "T4 cancel-in-progress for pull requests only")
g = re.search(r"^concurrency:\n  group: (.*)$", wf, re.M)
g = g.group(1) if g else ""
say(g.endswith("|| format('ci-{0}-{1}', github.event_name, github.run_id) }}") and "format('ci-pr-{0}', github.head_ref)" in g,
    "T4 a pull request's runs share a group per branch; every other run has a group of its own run id")
say("  push: {branches: [trunk]}\n" in wf, "T4 a push runs on trunk alone")
say(re.search(r"^  pull_request:\n", wf, re.M) is not None, "T4 a pull request runs")
say(re.search(r"^  schedule:\n    - cron: ", wf, re.M) is not None, "T4 the daily schedule runs")
say("  repository_dispatch:\n    types: [wolf-lang-corpus]\n" in wf, "T4 a release's dispatch runs")
say(re.search(r"^  workflow_dispatch:\n    inputs:\n      tier:\n", wf, re.M) is not None and "        options: [full]\n" in wf
    and "      sleep_warn_days:\n" in wf, "T4 a dispatch's tier input is full alone; sleep_warn_days stays")
n = blocks["notify"]
say("    needs: gate\n" in n and "failure()" in n and "github.event_name == 'schedule'" in n and "pull_request" not in n
    and "'push'" not in n and "      issues: write\n" in n, "T4 notify runs on an unattended red alone, with issues: write")
say("    if: github.event_name == 'schedule' || github.event_name == 'workflow_dispatch'\n" in blocks["sleep-alarm"],
    "T4 sleep-alarm runs on the schedule and a dispatch alone, as before")


# --- T6 the verdict -------------------------------------------------------------
def verdict(needs):
    r = subprocess.run([sys.executable, VERDICT, "verdict"], capture_output=True, text=True,
                       env=dict(os.environ, NEEDS=json.dumps(needs)))
    return r.returncode


for name, needs, want in [("every job succeeded", {"gate": {"result": "success"}}, 0),
                          ("the gate failed", {"gate": {"result": "failure"}}, 1),
                          ("the gate was skipped", {"gate": {"result": "skipped"}}, 1),
                          ("the gate was cancelled", {"gate": {"result": "cancelled"}}, 1),
                          ("the tier job needs no job", {}, 1)]:
    rc = verdict(needs)
    say(rc == want, "T6 %s: exit %d" % (name, rc))


# --- T8 notify's script -------------------------------------------------------------
def notify_script():
    lines = n.splitlines()
    for i, l in enumerate(lines):
        if l == "        run: |":
            out = []
            for m in lines[i + 1:]:
                if m.strip() and len(m) - len(m.lstrip()) < 10:
                    break
                out.append(m[10:])
            return "\n".join(out) + "\n"
    return None


FAKE_GH = r'''#!/usr/bin/env bash
printf '%s\n' "$*" >> "$FAKE_LOG"
case "$1 $2" in
  "label create") exit "${FAKE_LABEL_RC:-0}" ;;
  "issue list") printf '%s' "${FAKE_EXISTING:-}"; [ -n "${FAKE_EXISTING:-}" ] && echo; exit 0 ;;
esac
exit 0
'''


def notify(existing="", label_rc=0):
    d = tempfile.mkdtemp(prefix="tiers-test-gh-")
    try:
        with open(os.path.join(d, "gh"), "w") as f:
            f.write(FAKE_GH)
        os.chmod(os.path.join(d, "gh"), 0o755)
        with open(os.path.join(d, "notify.sh"), "w") as f:
            f.write(script)
        log = os.path.join(d, "log")
        env = dict(os.environ, PATH=d + os.pathsep + os.environ.get("PATH", ""), FAKE_LOG=log, FAKE_EXISTING=existing,
                   FAKE_LABEL_RC=str(label_rc), REPO="wolffe-lang/tree-sitter-wolf", EVENT="schedule",
                   RUN_URL="https://github.com/wolffe-lang/tree-sitter-wolf/actions/runs/1", GH_TOKEN="x")
        r = subprocess.run(["bash", os.path.join(d, "notify.sh")], capture_output=True, text=True, env=env)
        calls = open(log).read().splitlines() if os.path.exists(log) else []
        return r.returncode, calls
    finally:
        shutil.rmtree(d, ignore_errors=True)


script = notify_script()
say(script is not None and "MARKER='unattended CI run is red'" in script, "T8 notify's script is read out of the workflow")
if script:
    rc, calls = notify()
    creates = [c for c in calls if c.startswith("issue create")]
    say(rc == 0 and len(creates) == 1 and "--title CI: unattended CI run is red (" in creates[0] and "--label nightly-red" in creates[0]
        and not [c for c in calls if c.startswith("issue comment")], "T8 no open issue: one is opened under the marker, labelled nightly-red")
    say([c for c in calls if c.startswith("issue list") and 'in:title "unattended CI run is red"' in c],
        "T8 the dedupe asks for an open issue under the marker")
    rc, calls = notify(existing="41")
    say(rc == 0 and [c for c in calls if c.startswith("issue comment 41 ")] and not [c for c in calls if c.startswith("issue create")],
        "T8 an open issue: a comment on it, no new issue")
    rc, calls = notify(label_rc=1)
    say(rc == 0 and [c for c in calls if c.startswith("issue create")], "T8 a label that already exists is no failure")

print("tiers-test: %s" % ("PASS" if fails == 0 else "FAIL (%d)" % fails))
sys.exit(1 if fails else 0)
