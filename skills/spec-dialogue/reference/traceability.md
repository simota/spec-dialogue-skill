# Traceability — the ID scheme the L1↔L3 mapping rests on

**Purpose:** One stable identifier scheme for requirements, acceptance criteria and test cases, so the locked spec's coverage claim is checkable and so whatever builds the feature can cite the spec instead of paraphrasing it.

**Read when:** authoring L1 and L3 in Phase 4 SPECIFY, or verifying the Quality Gate's Completeness dimension.

**Why it matters:** a spec is the source of truth only if the implementation is a *derived, traceable* artifact. Per-document ad-hoc numbering lets orphaned tests and untested requirements pass silently. One scheme closes the loop.

---

## 1. ID scheme

IDs are **stable** — never renumber. When a revision changes an item's meaning, supersede it (`REQ-004_v2`) rather than rewriting `REQ-004` in place; readers holding the old ID must be able to find out what happened to it.

| Prefix | Meaning | Where it lives | Format |
|--------|---------|----------------|--------|
| `REQ-{n}` | Functional requirement — a user-facing need | L1 | `REQ-001` |
| `CFR-{n}` | Cross-functional requirement — performance, security, accessibility, operability | L1 | `CFR-001` |
| `AC-{n}` | Acceptance criterion — the verifiable unit | L3 | `AC-001` |
| `TC-{n}` | Test case — the executable procedure that discharges an AC | `<slug>.acceptance.md` | `TC-001` |
| `ASSUME-{n}` | Open assumption (Assumption Ledger, `dialogue-protocol.md` §3) | draft + Open Questions | `ASSUME-1` |
| `OQ-{n}` | An unresolved question carrying an owner and a `Blocks` dependency | Open Questions | `OQ-1` |
| `DEC-{n}` | A decision persisted during the dialogue | draft | `DEC-2` |

**Optional feature-scoping.** In a repository that will hold many specs, scope AC IDs by feature — `AC-LOGIN-001` — so IDs stay unique when specs are read together. Pick one form per spec and stay in it.

## 2. The linking rule (bidirectional, mandatory)

The chain is two hops, and each hop is checked in both directions:

```
REQ-001 ─▶ AC-001, AC-002 ─▶ TC-001, TC-004
   ◀── every AC names the requirement it verifies ──
                 ◀── every TC names the criterion it discharges ──
```

**Hop 1 — `REQ`/`CFR` ↔ `AC`** (inside the spec)

- **Forward gap** — a `REQ`/`CFR` with no `AC`: an **unverifiable requirement**. The spec claims something it cannot prove was delivered.
- **Backward gap** — an `AC` citing no requirement: an **orphan criterion**. Either a requirement went unwritten, or the AC is scope creep that entered during authoring.

**Hop 2 — `AC` ↔ `TC`** (spec ↔ `docs/specs/<slug>.acceptance.md`)

- **Forward gap** — a **must-have** `AC` with no `TC`: an **unexecutable criterion**. Nobody can decide it, so it will not gate acceptance no matter what the spec says.
- **Backward gap** — a `TC` citing no `AC`: either a criterion went unwritten, or the case tests something nobody asked for.

Both hops are defects, not warnings. Both are exactly what the Quality Gate's **Completeness** dimension checks, and both are cheap to fix at SPECIFY and expensive to fix after a build has started against the spec.

The hop-2 forward direction is the one most often left implicit: an AC that reads as testable is not the same as an AC someone has written a procedure for. `acceptance-test-template.md` is where that procedure lives, and its coverage matrix is where the gap shows.

## 3. What an AC must do

An AC that "maps to" a requirement is not enough — it must **entail** it. The test:

> If an implementation passes `AC-n` and every other AC under `REQ-m`, is `REQ-m` necessarily satisfied?

If the answer is no, the AC set under that requirement is incomplete, and no amount of green checks will prove the feature works. This is the third load-bearing claim the pre-lock refutation panel attacks, and it is the most expensive defect a spec can ship — a build that satisfies its contract while missing the point.

### The shape

An AC is written as a **scenario**, not an adjective — `Given` a starting state, `When` an action,
`Then` an observable result. "The list is fast" and "errors are handled gracefully" are not
criteria; they are the ambiguity a criterion exists to remove. The three parts are the contract;
`spec-template.md` renders them as table columns for the common case and as a block for the rest.

**Invariants keep the shape without inventing an actor.** Some requirements are properties that
hold always rather than responses to an action — "the schema rejects nulls", "no endpoint returns
another tenant's rows". For these, `When` names the **check event** — `at build`, `on every write`,
`for every endpoint in the route table` — and `Then` the property. Inventing a user action to fill
`When` makes the criterion test that one action and nothing else, which is exactly the entailment
failure above.

Each AC additionally states:
- **Its verification mode** — machine-checkable (a test can assert it) or human-checkable (someone must look). "Verifiable in principle" is not a mode.
- **Its oracle** — the specific thing that decides pass or fail: a test file or case name, a dashboard query, a named reviewer **plus what they observe and the rule that turns it into a verdict**. "QA reviewer" alone is not an oracle — it names who looks, not what they look at or where the line between pass and fail sits; "QA reviewer compares the export against fixture `F-3`; any missing column fails" is. A mode without an oracle defers the hardest question — *who decides, by what?* — to whoever is under deadline pressure later.
- **Its must-have flag** — must-have ACs gate the build's completion; nice-to-have ACs do not. An unflagged AC set forces the builder to guess which failures block ship.

### Error paths are requirements too

The Behavior matrix in `spec-template.md` is part of this loop, not commentary on it: each row
names the requirement it qualifies **and** the AC that proves it. A described-but-untested error
path is the same forward gap as an untested requirement, and it is the gap builds discover in
production.

## 4. Optional machine-readable ledger

When the spec will drive a long or unattended build, emit `docs/specs/<slug>.traceability.yaml` alongside it so the coverage claim is checkable without re-parsing prose:

```yaml
version: 1
feature: <slug>
spec_source: docs/specs/<slug>.md
links:
  - req: REQ-001        # a REQ-n or a CFR-n — both carry ACs (§2)
    title: <one line>
    priority: CRITICAL | HIGH | MEDIUM | LOW
    acs:
      - id: AC-001
        must_have: true
        verification: machine | human
        oracle: <test file / dashboard query / named reviewer>
        tests: [TC-001, TC-004]   # the hop-2 link; empty on a must-have AC is a gap
        status: NOT_VERIFIED | PASS | FAIL
coverage:
  forward: <0.0-1.0>       # requirements with >= 1 AC / total requirements
  backward: <0.0-1.0>      # ACs citing a valid requirement / total ACs
  test_forward: <0.0-1.0>  # must-have ACs with >= 1 TC / total must-have ACs
  gaps: [<REQ/CFR with no AC>]
  orphans: [<AC citing no requirement>]
  untested: [<must-have AC with no TC>]
```

This is optional for a small spec and worth the cost for anything a build will run against unattended. `spec-dialogue` authors it and sets every status to `NOT_VERIFIED`; the build fills the statuses in.

## 5. Adoption checklist

- New criterion → give it an `AC-{n}`, a Given/When/Then, and the requirement it verifies. Never a bare bullet.
- Every requirement → at least one AC; an explicit `OQ-n` may explain a draft gap, but does not waive the LOCK precondition.
- Every AC → a verification mode, an oracle (observation + pass/fail rule, not just a name), and a must-have flag. An invariant names its check event in `When`.
- Every must-have AC → at least one `TC-{n}` in `docs/specs/<slug>.acceptance.md`.
- Every TC → the AC it discharges, concrete step values, and an observable expected result (`acceptance-test-template.md` T1–T4).
- Every Behavior-matrix row → a requirement in `Applies to` and an AC in `Verifies`.
- Meaning-changing revision → supersede, never renumber; wording-only edits retain the ID.
- Before LOCK → walk both hops, forward and backward; that walk *is* the Completeness check.
