# Spec document template & Handoff Packet

Both the draft (`docs/specs/<slug>.draft.md`) and the locked spec (`docs/specs/<slug>.md`) follow **one** structure, so promotion at LOCK is a status change plus the sections that were still empty — not a rewrite.

The spec ships with a **companion**: `docs/specs/<slug>.acceptance.md`, the Acceptance Test Specification (`acceptance-test-template.md`). The spec says what must be true; the companion says how anyone decides whether it is. They are authored together in Phase 4 and locked together, linked by `AC-n ← TC-n`.

The structure exists to make *unstated* things visible. A spec is rarely wrong because someone wrote a falsehood; it is wrong because nobody wrote the empty-state behaviour, the latency number, or the word "member" meaning two different things. Every table below is shaped so that a gap in it is a **blank cell**, not silence — and so that each fact has exactly one cell. Prose between the tables carries reasoning that changes a build decision; it never restates what a cell already says, and a cell never holds a hedge where a value belongs (`doc-quality.md` W9, W15).

---

**Language.** The document is written in the language the user is conversing in; the IDs, metadata
keys, enum values and paths below stay verbatim (`doc-quality.md` W14). The skeleton that follows is
in English because the structure is the contract — the prose in it is not.

## Section tiers

Every section is present, or marked `N/A` with a one-line reason (`doc-quality.md` W12). The tier decides which of the two is acceptable:

| Tier | Sections | Rule |
|------|----------|------|
| **Required** — at every depth | L0, Glossary, L1, Behavior matrix, L3, Scope, Considered but rejected, Assumption Ledger, Open Questions, Build-path decision | must carry content; `N/A` here is a lock failure |
| **Required companion** | `docs/specs/<slug>.acceptance.md` per `acceptance-test-template.md` | every must-have AC carries ≥ 1 `TC` |
| **Conditional** — when the feature has one | L2.1–L2.4, Dependencies & integration points, Migration & rollout | `N/A` + a one-line reason is a complete answer |

`depth=light` buys fewer dialogue *turns*, never fewer *sections*: a settings toggle still has an empty state, still has a term that means one thing, and still has an acceptance criterion — and someone still has to be able to run it. The companion's *size* scales with the AC count; its existence does not scale with depth.

---

## The document

```markdown
# <Feature title>

| | |
|---|---|
| slug | <feature-slug> |
| status | draft \| locked |
| owner | <who answers questions about this> |
| as-of | <YYYY-MM-DD> |
| review trigger | <the event or interval that makes this stale, or `evergreen`> |
| depth | light \| standard \| deep |
| current phase | FRAME \| EXPAND \| CHALLENGE \| SHAPE \| SPECIFY \| LOCK   <!-- draft only; removed at promotion -->
| build path | <filled at LOCK> |

## L0 — Vision
- **Problem** — what is wrong today, and for whom.
- **Audience** — who this is for.
- **Job to be done** — one sentence.
- **Success definition** — how we will know it worked, in terms someone could measure.
- **Existing assets & constraints** — the reuse-scan findings from FRAME (paths, reusable pieces, technical bounds). `N/A — greenfield` when there is no codebase.

## Glossary
One concept, one term, spec-wide (`doc-quality.md` W11). On an existing codebase the spec adopts
the code's vocabulary rather than inventing a parallel one.

| Term | Definition | Not to be called | Code identifier |
|------|-----------|------------------|-----------------|
| Member | … | user, account | `Member` |

The **Not to be called** column is what makes synonym drift detectable: a reviewer can grep for the
banned words instead of noticing the drift by feel.

## L1 — Requirements

### Functional (`REQ-n`)
| ID | Requirement | Priority | Source |
|----|-------------|----------|--------|
| REQ-001 | … | CRITICAL | elicited (turn 4) \| ratified \| derived from REQ-002 |

### Cross-functional (`CFR-n`)
A cross-functional requirement without a number is an opinion. Every row states what is measured,
the threshold, and where the measurement comes from — an empty `Target` or `Measured how` fails the
Quality Gate's Testability dimension rather than passing as prose.

| ID | Requirement | Metric | Target | Measured how | Priority | Source |
|----|-------------|--------|--------|--------------|----------|--------|
| CFR-001 | the list loads fast | p95 latency | ≤ 300 ms | existing APM dashboard `<name>` | HIGH | ratified |

`Source` on both tables is what the Provenance Gate reads (`dialogue-protocol.md` D16) — every
load-bearing row is `elicited` / `ratified` / `derived from <ID>` / `parked (OQ-n)`, never blank.
See `traceability.md` §1 for the ID scheme.

## L2 — Detail
The layer a builder reads to know *how*, not *whether*. Free prose here is where ambiguity
survives a review, so it is four fixed slots — each either filled or `N/A` with a reason.

### L2.1 Data model
| Entity | Field | Type | Constraints | Default | Nullable | Owned by |
|--------|-------|------|-------------|---------|----------|----------|

### L2.2 Interface contract
| Operation | Trigger | Input | Output | Errors | Idempotent | Auth |
|-----------|---------|-------|--------|--------|------------|------|

### L2.3 State & transitions
| From | Event | To | Guard | Side effect |
|------|-------|----|-------|-------------|

`N/A — stateless` when the feature holds no state worth a diagram.

### L2.4 Validation rules
| Field | Rule | On violation | Message source |
|-------|------|--------------|----------------|

## Behavior matrix
The conditions a spec forgets. Each row names the requirement it qualifies and the AC that proves
it; a condition with no row is an **open question**, not an undefined behaviour — move it to Open
Questions rather than deleting the row.

The six condition classes below are a fixed checklist. Strike one out only with a stated reason
(`N/A — the feature has no external dependency`), never by omission.

| Condition | Applies to | Expected behavior | User-visible | Verifies |
|-----------|-----------|-------------------|--------------|----------|
| Empty state (no data) | REQ-001 | … | … | AC-004 |
| Invalid input | REQ-001 | … | … | AC-005 |
| Unauthorized / insufficient permission | REQ-002 | … | … | AC-006 |
| Dependency unavailable or timed out | REQ-001 | … | … | AC-007 |
| Concurrent modification | REQ-003 | … | … | AC-008 |
| Limit exceeded / rate limited | CFR-002 | … | … | AC-009 |

## Dependencies & integration points
What this feature rests on and does not control. The last two columns are the ones that get
discovered during the build when they are missing here.

| Dependency | Kind | We control? | Contract / version | Failure mode | Fallback |
|------------|------|-------------|--------------------|--------------|----------|

## Migration & rollout
- **Existing data** — migrated, backward-compatible, or breaking. State which.
- **Staged release** — flag, audience, and the condition for widening.
- **Rollback** — the procedure, and the point past which a data change stops being reversible.

The irreversibility line is cheap to decide here and expensive to discover later; `N/A` needs the
reason, not just the marker.

## L3 — Acceptance Criteria
Each criterion is a scenario, not an adjective. `Oracle` names what decides pass or fail — a test
file, a dashboard query, a named reviewer — because "verifiable in principle" is not a mode
(`traceability.md` §3). Every requirement above appears at least once in **Verifies**.

| ID | Given | When | Then | Verifies | Mode | Oracle | Must-have |
|----|-------|------|------|----------|------|--------|-----------|
| AC-001 | a member with 3 unread items | they open the list | the badge reads `3` | REQ-001 | machine | `test/notif.spec.ts` | yes |

Every **must-have** AC is discharged by at least one `TC-n` in `docs/specs/<slug>.acceptance.md`
(`traceability.md` §2, hop 2). An AC that reads as testable but that nobody has written a procedure
for is not yet a gate.

A criterion whose cells do not fit on one line gets a block below the table under its own `### AC-n`
heading, in the same Given / When / Then shape — the shape is the contract, the table is a
convenience.

## Scope
- **In scope** — …
- **Out of scope** — …

Collectively exhaustive and mutually exclusive. An out-of-scope item that an in-scope requirement
depends on is a boundary defect, and the refutation panel attacks exactly that.

## Considered but rejected
Directions dropped in CHALLENGE, one line each on why — so a resume or revision does not re-derive them.

## Assumption Ledger
`dialogue-protocol.md` §3. Draft-time this is live; at LOCK every remaining `open` entry is either
ratified into a decision or moved to Open Questions as an `OQ-n`.

| ID | Assumption | Default chosen | Why | Status |
|----|-----------|----------------|-----|--------|

## Open Questions / Deferred Decisions
Every unresolved thing in the document, in one place with an owner. Parked items, Quality-Gate
findings downgraded rather than fixed, and any `LOCK-with-flag` refutation with the assumption it
rests on. Nothing is dropped silently.

| ID | Question | Blocks | Owner | Resolve by | Impact if wrong |
|----|----------|--------|-------|-----------|-----------------|
| OQ-1 | … | REQ-003 \| nothing | <who> | before-build \| before-ship \| deferred | … |

**Lock rule.** `Resolve by` is the load-bearing column — it is what the lock is decided on. A spec
may be `locked` with open questions, but not with one whose `Resolve by` is `before-build`, because
that spec cannot be handed to a build. Either resolve it, or lower it to `before-ship` / `deferred`
with the user's agreement and say so. `Blocks` names what the question hangs over, so a reader can
tell which requirement is standing on an unanswered question; it never sets the level itself.

**Inventory rule.** Every `UNKNOWN`, `TBD(<owner>)` and open `ASSUME-n` anywhere in this document
appears here as an `OQ-n`. A marker buried in L2 that never reaches this table is the failure this
section exists to prevent — it is what the Quality Gate's **Resolvability** dimension scans for.

## Build-path decision
Recorded at LOCK: unattended loop \| one-shot autonomous build \| supervised build, plus the
reason. See `SKILL.md` Phase 5.
```

The L1↔L3 traceability — every requirement has an AC, every AC names a requirement — is exactly what the Quality Gate's Completeness dimension verifies and what the build consumes as its verification contract. The Behavior matrix extends the same loop sideways: each row cites a requirement **and** an AC, so an error path cannot be described in prose and then go untested.

---

## Spec Handoff Packet

Emitted at LOCK. A handoff that ships only a file path forces whatever builds the feature to re-derive what the dialogue already settled, so the packet carries the settled state in consumable fields.

| Field | Content |
|-------|---------|
| `spec_path` | the locked `docs/specs/<slug>.md` (status `locked`) |
| `acceptance_criteria` | the L3 AC set with IDs, Given/When/Then, requirement mapping, verification mode, oracle, and **must-have flags** — this is the build's completion contract |
| `acceptance_test_path` | the locked `docs/specs/<slug>.acceptance.md` — the executable half of the contract, with every result `NOT_RUN`. Its §2 exit criteria are what "done" means; its §3 environment is what the build must stand up to prove it |
| `behavior_matrix` | the condition rows with their requirement and AC mapping — the error paths the build must not invent for itself |
| `glossary` | the terminology ledger, so the build names things the way the spec does |
| `non_goals` | the out-of-scope list, verbatim — carried into the scope bound of every downstream work item |
| `dependencies` | the integration points, their contracts, and the declared fallback for each |
| `assumption_ledger` | remaining `ASSUME-n` entries and their status — risk input for the build |
| `open_questions` | the `OQ-n` set with `Blocks` / `Owner` / `Resolve by` — never silently dropped downstream, and never containing a `before-build` entry at LOCK |
| `refutation_flags` | any `LOCK-with-flag` claim and the assumption it rests on — each is a kill-criterion candidate for the build |
| `reuse_findings` | the existing-asset and constraint map from FRAME, so the build skips re-scanning |
| `build_path` | the path chosen at LOCK |

**Contract rule.** A build that receives the packet **does not re-open the settled decisions** — it may surface a contradiction it discovers against real code, but re-litigating the direction is drift. A build that finds a **must-have AC unbuildable as written** returns to `spec-dialogue <slug>` for revision, re-entering at SPECIFY and re-running the lock preconditions, rather than quietly reinterpreting it.
