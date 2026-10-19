# tl28 — the prediction, before the first change (ruling #92)

Written before any tl28 change to this repository is committed, against
trunk `0c18cfb`.

**Before** (the ten completed push/pull_request runs of `CI` up to the
2026-10-19 ones): one job, `gate`, on ubuntu; **4.8 job-minutes** a run
(median 4.7) and **5.5 minutes of wall** (median; max 12.7). Its four gates
all read the grammar, so its suite cannot be split by path: tl28 gives it no
plan and no pr tier.

**After, predicted:**

1. Every run, a pull request's push included, is `tier full`: the gate (4
   to 6 job-minutes) and the verdict (under 1, the wiring test inside it):
   **5 to 7 job-minutes, about 6 minutes of wall**. The verdict costs one
   short ubuntu job a run; nothing is saved but a superseded run's slot.
2. A superseded pull-request run is cancelled by the next push.
3. The planted break (a gate step made to fail) reds `tier full`.
4. An unattended red (the schedule, a release's dispatch, a manual
   dispatch) opens notify's issue as before, now labelled `nightly-red`.
