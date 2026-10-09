# Acceptance Test Specification — template

The locked spec says **what must be true**. This document says **how anyone decides whether it is**
— with concrete data, a named environment, and a result someone can read afterwards.

It ships beside the spec as `docs/specs/<slug>.acceptance.md`, authored in Phase 4 SPECIFY at the
same time as L3 and promoted at LOCK with it. `spec-dialogue` **authors** it and leaves every result
`NOT_RUN`; it never executes it — the skill writes no code and runs no tests.

**Why a second document rather than a wider AC table.** An AC is a claim about the product; a test
case is a procedure against a build. They rot on different clocks: the AC changes when the feature
changes, the procedure changes when the environment, the fixture, or the tooling changes. Folded
together, an environment note edits the acceptance contract. Kept apart, `AC-n ← TC-n` is a link, and
`traceability.md` §2 checks it in both directions.

**The one rule that keeps them apart.** The test spec **never decides anything the spec left open.**
Writing `TC-007` and finding no stated behaviour for an expired token does not license a decision
here — it produces an `OQ-n` in the spec. A test document that answers its own questions is a shadow
spec, and the build will follow whichever of the two it read last.

---

**Language.** Same rule as the spec: the reader's language for the prose, verbatim for the IDs,
metadata keys, enum values, paths and automation references (`doc-quality.md` W14). A step someone
must follow under time pressure is the last place to make them translate.

## The document

```markdown
# Acceptance Test Specification — <Feature title>

| | |
|---|---|
| slug | <feature-slug> |
| spec source | `docs/specs/<slug>.md` as-of <YYYY-MM-DD> |
| status | draft \| locked \| executed |
| owner | <who runs this and reports the result> |
| as-of | <YYYY-MM-DD> |
| review trigger | <the event that makes this stale — usually "the spec changes"> |

## 1. Test scope
- **In scope** — the behaviour this suite decides.
- **Out of scope** — what deliberately is not tested here, and where it is tested instead (`N/A — nowhere else` is an acceptable, and useful, answer).
- **Not proven by this suite** — what passing everything here still does not establish. Stated up front rather than discovered at ship.

## 2. Entry & exit criteria
Exit criteria are the acceptance contract in one place: when this list is satisfied, the feature is
accepted. Anything that could block acceptance and is not on this list will not block it.

| | Criterion |
|---|-----------|
| **Entry** | the spec is `locked`; a build identifying itself by commit is deployed to the named environment — or, while its binding is `TBD`, to one shown to provide every §3 capability; fixtures loaded |
| **Exit** | every **must-have** `TC` is PASS · every `CFR` procedure has a recorded measurement meeting its target · no open defect at a blocking severity (§8) · every non-must-have failure is recorded as a defect, not dropped |

## 3. Environment
Under-specified environment is the most common reason a result cannot be reproduced or believed.

| Item | Value | How to obtain / set |
|------|-------|---------------------|
| Environment | staging \| local \| … | |
| Build under test | <commit / version> | |
| Data state | seeded \| production-like snapshot \| empty | |
| Accounts & roles | <role: account> per role the tests exercise | |
| Feature flags | <flag: state> | |
| External dependencies | live \| stubbed \| recorded — **per dependency** | |
| Clock / timezone / locale | | |

`N/A` on a row needs the reason: "no external dependency" is information; a blank cell is not.

**Nothing built yet is the normal case**, not an exception: the suite is authored at SPECIFY, before
any environment exists. Then `Value` states the **capabilities the environment must provide** — "a
tenant with two roles and a stubbed payment provider that can be forced to time out", each one
checkable; "staging-like" is not a capability — and the
concrete binding (host, URL, account name) is a `TBD(<owner>)` carried as a `before-ship` `OQ-n`
in the spec. That is legitimate only because the capability contract is settled (`spec-template.md`
Lock rule). Never invent a hostname, a staging URL or an account to make the row look filled — an
invented binding is a fabricated fact (`doc-quality.md` W5).

## 4. Test data
| Fixture | Purpose | Source | Reset procedure | Contains personal data |
|---------|---------|--------|-----------------|------------------------|

A fixture with no reset procedure makes the second run of the suite differ from the first, and the
difference will be read as a defect in the product.

## 5. Test cases

Every case names the AC it discharges. **Steps carry concrete values.** "Enter a valid email" is not
a step; "enter `a@example.com`" is — the difference is whether two people running this suite run the
same suite.

| ID | Verifies | Title | Precondition | Steps | Expected result | Mode | Automation ref | Must-have | Priority |
|----|----------|-------|--------------|-------|-----------------|------|----------------|-----------|----------|
| TC-001 | AC-001 | badge shows unread count | member `m1` with 3 unread | open the list | badge reads `3` | machine | `test/notif.spec.ts:12` | yes | HIGH |

A case that does not fit one line per cell moves to a block, in the same shape:

### TC-002 — <title>
- **Verifies:** `AC-002` (`REQ-001`)
- **Mode:** machine \| manual · **Must-have:** yes \| no · **Automation ref:** …
- **Precondition:** …
- **Steps:**
  1. … (concrete input)
  2. …
- **Expected result:** … (observable, and observable by whom)
- **Teardown:** … — or `none required`, said explicitly

Cover the **Behavior matrix** rows as well as the happy paths: an error path with an AC but no test
case is the gap the matrix exists to close, half-closed.

## 6. Non-functional procedures (`CFR-n`)
A cross-functional requirement needs a procedure that can decide its required outcome. Cite that
outcome from the spec; do not replace it with a different number or condition (`doc-quality.md` W10).
Quantitative procedures state workload, sample and measurement conditions. Categorical or normative
procedures identify the inspected surface, applicable criterion and pass/fail evidence; no invented
score, duration or percentage is needed. Tool or reviewer names alone do not define the observation.

| CFR | Measure / criterion | Required outcome (from spec) | Procedure | Tool / observer | Conditions / sample | Observed result | Verdict |
|-----|---------------------|------------------------------|-----------|-----------------|---------------------|-----------------|---------|
| CFR-001 | … | see spec CFR-001 | … | … | … | NOT_RUN | |

## 7. Coverage matrix
The `AC → TC` half of the chain `REQ → AC → TC` (`traceability.md` §2).

| AC | Must-have | Covered by | Mode | Gap |
|----|-----------|-----------|------|-----|
| AC-001 | yes | TC-001, TC-004 | machine | — |

- **Forward gap** — a must-have AC with no TC: the exit criteria cannot be evaluated, so acceptance cannot happen. This is a blocking defect of *this document*.
- **Backward gap** — a TC citing no AC: either an AC went unwritten, or the case tests something nobody asked for.

## 8. Defect handling
| Severity | Definition | Blocks exit |
|----------|-----------|-------------|
| S1 | a must-have AC is not met, or data is lost/corrupted | yes |
| S2 | a must-have AC is met only via a workaround | yes |
| S3 | a nice-to-have AC is not met | no — recorded |
| S4 | cosmetic or copy | no — recorded |

A failing **must-have** case is triaged as either a build defect (fix and re-run) or an
**unbuildable AC as written** — the latter returns to `spec-dialogue <slug>` for revision rather than
being reinterpreted here (`SKILL.md` § Handoff contract).

## 9. Execution record
Authored empty; filled by whoever runs the suite. One row per run — a re-run appends, never
overwrites, so a flaky case is visible as a case that changed verdict without a code change.

| Run | Date | Build | Executed by | Passed | Failed | Blocked | Skipped | Defects raised |
|-----|------|-------|-------------|--------|--------|---------|---------|----------------|
| 1 | | | | | | | | |

Per-case results live in the §5 table's own status column, or in the machine-readable ledger
(`traceability.md` §4) when the spec carries one.

## 10. Residual risk
What acceptance does **not** cover, stated plainly: untested combinations, environments not
exercised, load levels not reached, the manual cases whose oracle is one person's judgement. This
section is what stops "all green" from being read as "everything works".

## 11. Sign-off
| | |
|---|---|
| accepted by | <who> |
| date | <YYYY-MM-DD> |
| verdict | accepted \| accepted-with-defects (list them) \| rejected |
```

---

## Authoring rules

| # | Rule | Why |
|---|------|-----|
| T1 | Every `TC` names the `AC` it verifies | the chain `REQ → AC → TC` is what makes coverage checkable rather than asserted |
| T2 | Every **must-have** `AC` has ≥ 1 `TC` | a must-have criterion nobody can execute cannot gate acceptance, and will not |
| T3 | Steps carry concrete values, not descriptions of values | two people must run the same suite; "a valid input" is two suites |
| T4 | Expected results are observable, and say by whom | "the record is updated" is not observable; "the list shows `2 items`" is |
| T5 | The target of a `CFR` procedure is cited from the spec, never restated | a threshold written twice forks on the first edit (`doc-quality.md` W10) |
| T6 | The test spec decides nothing the spec left open | an unspecified behaviour discovered here becomes an `OQ-n` in the spec, not a decision here |
| T7 | Results are authored as `NOT_RUN` | `spec-dialogue` writes the suite, never its outcome; a pre-filled pass is a fabricated result (`doc-quality.md` W5) |
| T8 | Every section present, or `N/A` with a one-line reason | same tier discipline as the spec (`doc-quality.md` W12) |
| T9 | A second `TC` on the same `AC` exercises a **different** path, or it does not exist | duplicate coverage costs a run every time and raises confidence once; the suite is sized by the paths that can fail, not by the cases someone can write (`doc-quality.md` W9) |
| T10 | An environment that does not exist yet is specified by required capabilities, its binding left `TBD(<owner>)` | an invented staging URL is a fabricated fact; a capability list is a contract someone can stand up (`doc-quality.md` W5) |

## Failure Modes Prevented

| Failure | Mitigation |
|---------|------------|
| A must-have AC nobody can actually execute | T2 + the coverage matrix's forward gap |
| Two testers running two different suites | T3 concrete values, §3 environment, §4 fixtures |
| "All green" read as "everything works" | §10 residual risk + §1's *not proven by this suite* |
| A result nobody can reproduce | §3 environment table + §9 build-identified run record |
| The test document quietly answering an open question | T6 — it becomes an `OQ-n` in the spec instead |
| A threshold that drifts between spec and test | T5 cite-never-restate |
| A flaky case disappearing into a re-run | §9 appends runs rather than overwriting |
| Error paths specified but never tested | §5 covers the Behavior matrix rows, not just happy paths |
| A suite that is long rather than discriminating | T9 — a second case per AC only for a different path |
| A staging URL invented to fill the environment table | T10 — required capabilities now, the binding `TBD(<owner>)` until it exists |
