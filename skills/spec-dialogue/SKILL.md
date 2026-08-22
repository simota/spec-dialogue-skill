---
name: spec-dialogue
description: "Refining a rough feature idea into a locked, acceptance-criteria-bearing specification plus its acceptance test specification, through deep human-in-the-loop dialogue: problem framing, option divergence, stress-tested convergence, staged authoring, adversarial quality gate, explicit sign-off. Stops at the documents — writes no code and runs no tests."
---

<!--
CAPABILITIES_SUMMARY:
- problem_framing: Establish and confirm a shared problem statement before any option generation
- option_divergence: Generate 3-5 candidate directions and steer them with the user across multiple turns
- adversarial_convergence: Narrow to one direction under necessity / scope / feasibility / failure pressure
- staged_authoring: L0 Vision -> L1 Requirements -> L2 Detail -> Behavior matrix -> L3 Acceptance Criteria with REQ<->AC traceability
- quality_gate: Seven-dimension independent review of the spec as an artifact (lock precondition)
- refutation_panel: Refute-polarity skeptic panel against the four load-bearing claims a locked spec asserts
- draft_persistence: Incremental draft writes with phase markers and resume from the last checkpoint
- acceptance_test_spec: A companion docs/specs/<slug>.acceptance.md authored with the spec — TC-n cases, environment, fixtures, exit criteria, results left NOT_RUN
- handoff_packet: Machine-consumable contract emitted at LOCK for whatever builds the spec

PROJECT_AFFINITY: universal
-->

# spec-dialogue

> **"The dialogue is the work. The document is its crystallized output."**

Take a rough feature idea — possibly as vague as "I want notifications" — and refine it **through deep human-in-the-loop dialogue** into a finalized, acceptance-criteria-bearing specification the user explicitly signs off on, together with the **acceptance test specification** that says how anyone decides whether it was met. **Stops at the documents; writes no code and runs no tests.**

**Principles:** Problem before solution · Diverge before converging · Every criterion testable · No silent assumptions · The user signs, not the agent

This skill is **fully self-contained**. It needs no other skill, agent, registry, or repository. Everything it depends on lives in `reference/` next to this file:

| File | What it holds |
|------|---------------|
| `reference/dialogue-protocol.md` | D1–D16 — how to ask, how to process answers, the Assumption Ledger, the Provenance Gate |
| `reference/roles.md` | The 18 analytical lenses this recipe uses, each defined inline |
| `reference/refutation-protocol.md` | Skeptic-panel composition, evidence-vs-novelty, aggregation |
| `reference/traceability.md` | The `REQ-n` / `AC-n` ID scheme the L1↔L3 mapping rests on |
| `reference/doc-quality.md` | Document-deliverable discipline (reader contract, grounding, readability) |
| `reference/spec-template.md` | The spec document template and the Spec Handoff Packet |
| `reference/acceptance-test-template.md` | The companion acceptance test specification — `TC-n` cases, environment, fixtures, exit criteria, sign-off |

## Trigger Guidance

Use `spec-dialogue` when:
- a feature idea exists but is not yet buildable, and the user wants to **think it through in conversation**
- the deliverable needed is a **specification with acceptance criteria**, not code and not a verdict
- several plausible directions exist and the choice between them should be made deliberately
- a locked spec needs revising because reality moved

Do **not** use `spec-dialogue` when:
- the user wants code now and the shape is already settled — this skill writes none
- the open question is *which* feature to build at all — decide that first, then spec the winner
- the deliverable is a whole-repository architecture document rather than one feature
- an existing feature needs excavating and explaining — that is archaeology, not specification

## Execution model

`spec-dialogue` is **interactive by contract.** The phase-boundary checkpoints below are part of the recipe, not a mode setting: even when the caller is running autonomously ("just do it", batch mode, an unattended runner), `spec-dialogue` still stops at each checkpoint for the user to steer. A lighter touch is acceptable — confirm only at FRAME, the CHALLENGE pick, and LOCK — but **never silently drop a checkpoint.** A single-pass spec that reports itself as dialogue is the failure this recipe exists to prevent.

**Output language.** The dialogue and both documents are written in **the language the user is using**. What stays verbatim regardless of language is the machine-readable surface — stable IDs (`REQ-n`, `CFR-n`, `AC-n`, `TC-n`, `ASSUME-n`, `OQ-n`), metadata keys and their enum values, file paths, code identifiers, and Handoff Packet field names — because something downstream cites them (`reference/doc-quality.md` W14).

**Lenses, not dependencies.** Phases below name analytical lenses (Demand, Divergence, Subtraction, …). Each is defined in `reference/roles.md` as a role with its own framing question and output shape. Adopt them **in sequence yourself**, or spawn them as parallel subagents if your harness offers a subagent tool — the recipe is correct either way. Nothing here requires a specific agent, model, or tool to exist.

### Depth modes (`spec-dialogue depth=light|standard|deep`)

`spec-dialogue` is deliberately heavy by interaction turns, and that heaviness is wrong for a small, well-understood feature — a user forced through six phases for a settings toggle abandons the recipe and specs nothing. Depth scales the *dialogue*, never the lock preconditions:

| Depth | When | Phases | Panel | Turns |
|-------|------|--------|-------|-------|
| `light` | one bounded change, the problem is already agreed, no real option space | FRAME → SPECIFY → LOCK (EXPAND/CHALLENGE/SHAPE collapse into one confirm) | skipped | ~3-5 |
| `standard` (default) | a normal feature with genuine alternatives | all six | 2 skeptics (claims 1, 3) | ~8-15 |
| `deep` | high-stakes, contested, or expensive-to-reverse; a spec several teams will build against | all six + extended EXPAND | 4 skeptics (one per claim) | ~15-30 |

**Invariant across all three:** testable L3 ACs, the Spec Quality Gate, the Provenance Gate, and explicit sign-off are lock preconditions at every depth — `light` buys fewer *turns*, never a weaker *lock*. Propose a depth at FRAME with your reason and let the user override; an unstated depth defaults to `standard`. A `light` run that discovers a real option space **escalates to `standard` and says so** rather than under-specifying.

---

## Phase contract

`FRAME → EXPAND → CHALLENGE → SHAPE → SPECIFY → LOCK`

### Phase 0 — FRAME (problem before solution)

Establish the shared problem statement **before** any option generation.

- **Demand lens** surfaces the real job-to-be-done and the latent pain behind the request.
- **+Research-grounding lens** when real user-research data exists.
- **+Persona lens** when the audience is unclear.
- **+Reuse-scan lens on an existing codebase (skip greenfield)** — before fixing the problem, survey what already ships: does a comparable feature/module/pattern exist, which assets are reusable, and what technical constraints (current stack, data model, integration points) bound the solution. This grounds the spec in the real codebase and prevents an out-of-context spec that re-derives shipped code.

Then drive Socratic clarification with the user per `reference/dialogue-protocol.md` (D1–D8: one focus per turn, recognition over recall, concrete anchors, tacit-knowledge probes, paraphrase-back before persisting), covering: who is this for · what job does it do · what does success look like · what is explicitly out of scope · what constraints (tech / time / compliance) bound it. All dialogue throughout the recipe follows that protocol — checkpoints per D10–D12 (envelope / delta-only / orientation line), engagement calibration per D13–D15, undecided gaps tracked in the draft's **Assumption Ledger** (D9).

- **Checkpoint (mandatory):** present a 3-5 line problem statement, carrying any reuse/constraint findings; the user confirms or corrects it. Option generation **cannot start** until the problem statement is confirmed.
- **Draft init:** on confirmation, write `docs/specs/<slug>.draft.md` (status `draft`, L0 Vision + reuse/constraint findings filled). See **Draft persistence & resume**.

### Phase 1 — EXPAND (diverge)

Generate the option space. Run the **Divergence lens twice with different framings** — once in propose mode (what could this be), once in reframe mode (challenge the assumptions, borrow from another domain). Produce **3-5 candidate directions**, each with a one-line rationale and rough shape. **+Market lens** when differentiation or prior art matters.

- **Checkpoint:** present the candidates; the user reacts, eliminates, combines, or adds. Expect **multiple turns** here — this is the divergent heart of the dialogue. Do not converge prematurely. Keep polarity neutral (D4): a leading question here contaminates the data. On checkpoint pass, append the surviving candidates to the draft.

### Phase 2 — CHALLENGE (stress-test + converge)

Narrow to ONE direction *with the user*, under four distinct pressures: **Arbitration lens** (is it necessary — multi-perspective trade-off), **Subtraction lens** (is it over-scoped — YAGNI), **Impact lens** (is it feasible — blast radius and dependencies), **+Pre-mortem lens** (how does it fail — when stakes are high).

- **Checkpoint (mandatory):** the user makes the **explicit pick** of the single direction to specify. Carry forward rejected directions as recorded "considered but rejected" so the dialogue does not re-derive them. Record the pick and the rejected list to the draft.
- **Convergence check:** before looping back to EXPAND, ask "are we converging, or circling?" If circling ≥ 2 rounds with no new information, offer to (a) lock the leading candidate, or (b) park the disagreement as an Open Question and proceed. Never loop indefinitely.

### Phase 3 — SHAPE (proposal)

The **Proposal lens** synthesizes the chosen direction into a structured proposal: problem → proposed solution → in-scope → out-of-scope → assumptions → open questions. **+Prioritization lens** when the direction decomposes into sub-features needing MoSCoW ordering.

- **Checkpoint:** present the proposal; capture the user's edits section by section, then write the agreed sections to the draft.

### Phase 4 — SPECIFY (authoring with mandatory acceptance criteria)

The **Authoring lens** carries the spine — staged elaboration L0 Vision → L1 Requirements → L2 Detail → Behavior matrix → L3 Acceptance Criteria. **+API-detail lens** and **+Data-model lens** when the spec needs interface or storage detail. Author against `reference/spec-template.md` so the artifact is downstream-consumable, and iterate with the user **section by section**, persisting each agreed section to the draft.

- Give every L3 acceptance criterion a **traceable ID (`AC-001`, `AC-002`, … per `reference/traceability.md` §1) mapped to the L1 requirement it verifies**, written as a **Given / When / Then scenario with a named oracle** — the thing that decides pass or fail. This traceability is what the Quality Gate's Completeness check verifies and what any downstream build consumes as its verification contract.
- **Walk the Behavior matrix explicitly with the user.** Its six condition classes — empty state, invalid input, unauthorized, dependency unavailable, concurrent modification, limit exceeded — are the questions a spec forgets and a build discovers. A class that genuinely does not apply is struck out **with a reason**; a class nobody discussed becomes an `OQ-n`, never a blank.
- **Every cross-functional requirement carries a number.** `CFR-n` states its metric, its target, and how it is measured; an adjective in that table is a Testability failure, not a requirement.
- **Lock preconditions (all three mandatory, verified at LOCK):** (1) the spec carries **testable L3 acceptance criteria** — the difference between a spec and a wish; the **Verifiability lens** sanity-checks that each AC is actually checkable by a machine or a human. (2) **every must-have AC is discharged by at least one `TC-n`** in the acceptance test specification (`reference/traceability.md` §2, hop 2). (3) the spec **passes the Spec Quality Gate** (below).
- **Author the acceptance test specification alongside L3**, not after it. `docs/specs/<slug>.acceptance.md` per `reference/acceptance-test-template.md`: a `TC-n` for every must-have AC, with concrete step values, a named environment, fixtures and their reset, exit criteria, and defect severities. Writing the procedure is what exposes an AC that only *reads* as testable — which is why it happens at SPECIFY, while the AC can still be rewritten, rather than at build time. **Every result is authored `NOT_RUN`**: `spec-dialogue` writes the suite, never its outcome.
- **The test spec decides nothing the spec left open.** A behaviour discovered missing while writing a case becomes an `OQ-n` in the spec (`reference/acceptance-test-template.md` T6), never a decision made in the test document.
- **+Demand lens** for a quick usability sanity-pass on the shaped flow when there is a UI surface.

### Phase 5 — LOCK (sign-off + persist, no code)

**Gate:** do not present for sign-off until **all three lock preconditions pass** — testable L3 ACs, a `TC-n` behind every must-have AC, **and** the Spec Quality Gate. Then present the complete spec and require the user's **explicit sign-off** ("lock it"). On sign-off:

- **Finalize both documents:** promote `docs/specs/<slug>.draft.md` to the locked `docs/specs/<slug>.md` (status `locked`; override the path on request), following `reference/spec-template.md`, and promote the companion `docs/specs/<slug>.acceptance.md` to `locked` with it. The two are locked together — an accepted spec whose test procedure is still a draft has no executable definition of done. Include an explicit **Open Questions / Deferred Decisions** section — parked items, including any Quality-Gate findings downgraded rather than fixed, are recorded, never silently dropped. Archive or remove the `.draft.md` once promoted.
- **Build-path selection (mandatory checkpoint):** before recommending a handoff, ask the user **how** they want the locked spec built. Present the choice in terms of the build's shape, not a tool name:

  | Path | Pick when | What the spec provides |
  |------|-----------|------------------------|
  | **Unattended loop** — turn the spec into a self-driving runner whose completion contract is the L3 AC set | the build is long-running / multi-session / the user wants to leave it alone; checkpoint-resume matters | the AC set becomes the machine-checkable DONE gate |
  | **One-shot autonomous build** — design → implement → verify → ship in a single sustained run | the build is bounded and the user is present for it | the AC set is the ship gate |
  | **Supervised build** — a human-in-the-loop implementation pass | the change is small, risky, or needs judgment per step | the AC set is the review checklist |

  Both autonomous paths consume the same L3 ACs; the difference is attendance and resumability. If your environment has a specific runner or build skill for the chosen shape, name it here — but the spec is complete and consumable without one.
- Emit the **Spec Handoff Packet** (`reference/spec-template.md` § Handoff Packet) as a **recommendation, not execution** — `spec-dialogue` writes no code. The build-path selection is a contract-level checkpoint and cannot be auto-picked, even under an autonomous caller.

---

## Draft persistence & resume

`spec-dialogue`'s value is a long multi-turn dialogue, so it must survive interruption. Its bound is structural, not a rubric loop: the Phase 2 convergence check ends exploration, and the explicit **LOCK gate** ends the recipe — a dialogue that will not converge exits with the open questions listed, never by burning turns. Each phase's checkpoint above states what gets written to `docs/specs/<slug>.draft.md` at that boundary, plus a **current-phase marker** and the **Assumption Ledger** delta (`reference/dialogue-protocol.md` §3). From SPECIFY onward the acceptance test specification is written incrementally beside it and resumes with it.

- **Invocation forms:** `spec-dialogue` (new dialogue) · `spec-dialogue resume [<slug>]` (re-enter from the last checkpoint; omitted `<slug>` → most-recent draft) · `spec-dialogue <slug-or-path>` (re-open a locked spec for revision — re-enters at SPECIFY and re-runs the lock preconditions before re-locking).
- **Resume behavior:** read the draft, replay the current-phase marker, summarize decisions-so-far back to the user in 3-5 lines for confirmation, then continue from that checkpoint. Never silently restart from FRAME.

## Spec Quality Gate (lock precondition)

Before sign-off, the spec is adversarially reviewed **as an artifact, by a reviewer that is not its author** — the **Adversarial-review lens**, plus the Verifiability lens for AC checkability and the Arbitration lens where requirements trade off. "Independent" is load-bearing: the spec's author never scores its own gate, and the gate is never implemented by telling the authoring pass to re-check itself. Where no separate agent is available, run the gate as a **distinct pass with the authoring context set aside** — read the spec as a stranger would, from the document alone.

The gate scores seven dimensions; each must pass, or its finding is explicitly downgraded into Open Questions (never silently passed):

| Dimension | Question |
|-----------|----------|
| Ambiguity | Is any requirement/AC open to more than one reasonable interpretation? |
| Completeness | Does every in-scope requirement have ≥ 1 L3 AC, and every must-have AC ≥ 1 `TC`? (both hops of `REQ → AC → TC`) |
| Consistency | Do scope, requirements, and ACs contradict each other anywhere? |
| Testability | Is every AC verifiable by a machine or a human? |
| Scope coherence | Are in-scope / out-of-scope collectively exhaustive and mutually exclusive? |
| Provenance | Is every load-bearing element `elicited` / `ratified` / `parked` — none `silent`? (`reference/dialogue-protocol.md` D16; open `ASSUME-n` entries are walked with the user here) |
| Resolvability | Does every `UNKNOWN` / `TBD` / open `ASSUME-n` in the document appear in Open Questions with an owner and a `Resolve by` level — and is no remaining question marked `before-build`? (`reference/doc-quality.md` W13) |

The spec is also a **document deliverable**: `reference/doc-quality.md` adds the dimensions this gate does not natively carry (freshness metadata, grounding of externally-checkable facts, summary-first readability). A gate failure routes back to SPECIFY for a fix, or — with the user's agreement — the gap is parked in Open Questions. The gate is a **lock precondition**: an autonomous caller cannot skip it.

### Pre-lock refutation panel (refute-polarity)

The seven dimensions above audit the spec **as a document**. They do not ask the harder question: *should this be locked at all?* A spec that is internally consistent, fully traceable, and completely wrong passes every one of them. So before sign-off, a skeptic panel runs per `reference/refutation-protocol.md` — **refute-polarity, 2-4 independent skeptics**, each prompted to kill the spec rather than evaluate it. The four **load-bearing claims** a locked spec silently asserts:

| Claim under attack | Skeptic angle |
|--------------------|---------------|
| **The problem is real** | "the stated pain is assumed, not evidenced — no user, telemetry, or research anchor backs it" |
| **This direction beats the rejected ones** | "a direction dropped in CHALLENGE is strictly better under the stated constraints" (re-opens the considered-but-rejected list against the *final* scope, which moved after the pick) |
| **The ACs actually prove the requirements** | "AC-n passes on an implementation that does not satisfy REQ-m" — a green AC that does not entail its requirement is the most expensive defect a spec can ship |
| **The scope boundary holds** | "an out-of-scope item is load-bearing for an in-scope requirement" — the boundary is not actually separable |

Aggregation follows the protocol §3: **majority refuted-on-evidence → back to CHALLENGE or SPECIFY** (not a park); majority **merely-unproven-because-new → LOCK-with-flag**, the flag recorded in Open Questions with the assumption it rests on. The evidence-vs-novelty discipline (§2) is load-bearing here — a genuinely novel feature must not be blocked for lacking evidence that can only exist after it ships; only an evidence-based refutation blocks. Hard exclusions per §4 apply unchanged.

Panel size scales with depth: `light` skips the panel, `standard` runs 2 skeptics on claims 1 and 3, `deep` runs 4 — one per claim, so no claim goes unattacked and no skeptic blends two angles.

## Scale

**Roughly 3-13 lens passes**, multiplied by dialogue turns — depth-dependent: `light` 3-5 · `standard` 5-9 · `deep` 8-13. These are planning figures, not bounds: a phase runs the lenses it needs. The reuse-scan in FRAME, the review lens in the Quality Gate, and the 2-4 refutation skeptics are the conditional additions. Light by fan-out, deliberately heavy by interaction turns — the value is in the conversation depth.

## Failure Modes Prevented

| Failure | Mitigation |
|---------|-----------|
| Spec a half-baked idea | FRAME checkpoint requires a confirmed problem statement before options |
| Endless circling | Phase 2 convergence check + explicit LOCK gate |
| Spec without acceptance criteria | Phase 4 mandates testable L3 ACs as a lock precondition |
| Silently dropped open questions | locked spec carries an explicit Open Questions / Deferred Decisions section |
| Jumping to build | `spec-dialogue` writes no code; it hands off |
| Single-pass spec masquerading as dialogue | human-in-the-loop at every phase boundary; an autonomous caller cannot skip contract-level checkpoints |
| Reinvent the wheel / out-of-context spec | FRAME's reuse-scan (skipped only for greenfield) |
| Lost dialogue on interruption | incremental draft persistence + `spec-dialogue resume` |
| Locking a low-quality spec | seven-dimension Quality Gate as a lock precondition |
| Downstream can't consume the spec | standard template + L1↔L3 AC traceability |
| Silent assumptions inside a signed spec | Assumption Ledger (D9) + Provenance Gate (D16) blocks LOCK on any `silent` element |
| Wall-of-questions, leading questions, rubber-stamp checkpoints, swallowed vague answers | `reference/dialogue-protocol.md` D1–D15 |
| An internally-perfect but wrong spec | pre-lock refutation panel — the seven document dimensions cannot catch this |
| Ceremony driving users away from specifying at all | depth modes scale the dialogue without weakening any lock precondition |
| Error paths described in prose and never tested | Behavior matrix rows cite a requirement *and* an AC (`reference/traceability.md` §3) |
| A cross-functional requirement that is an adjective | `CFR-n` carries metric / target / measurement, or fails Testability |
| A `TBD` buried mid-document, found by the build | Resolvability dimension + the Open Questions inventory rule (W13) |
| Ambiguity surviving in free-form detail prose | L2 is four fixed slots, each filled or `N/A` with a reason |
| Synonym drift between spec and code | Glossary with a `Not to be called` column (`reference/doc-quality.md` W11) |
| Downstream re-derives the dialogue | Spec Handoff Packet carries the settled state in machine-consumable fields |
| A must-have AC nobody can actually execute | hop-2 lock precondition: every must-have AC carries a `TC-n` |
| "Testable in principle" discovered at build time | the procedure is written at SPECIFY, while the AC can still be rewritten |
| Acceptance run nobody can reproduce | the test spec's environment, fixture and build-identified run record |
| "All green" read as "everything works" | the test spec's residual-risk and not-proven-by-this-suite sections |
| The test document quietly answering an open spec question | T6 — it becomes an `OQ-n` in the spec instead |
| Downstream silently reinterprets an unbuildable AC | contract rule routes it back to `spec-dialogue <slug>` for revision |

## Handoff contract

`spec-dialogue` is upstream of whatever builds the feature, and a handoff that ships only a file path forces the builder to re-derive what the dialogue already settled. The **Spec Handoff Packet** (`reference/spec-template.md` § Handoff Packet) is the contract, emitted at LOCK.

**Contract rule:** a downstream build that receives the packet **does not re-open the settled decisions** — it may surface a contradiction it discovers against real code, but re-litigating the direction is drift. Conversely, a build that finds a **must-have AC unbuildable as written** returns to `spec-dialogue <slug>` for revision — re-entering at SPECIFY, re-running the lock preconditions — rather than quietly reinterpreting it.

## Chain template

`FRAME (Demand +Research?/Persona? +Reuse-scan? + ✓depth-mode + Socratic dialogue) → ✓confirm-problem + draft-init → EXPAND (Divergence ×2 +Market?) → ✓steer + draft → CHALLENGE (Arbitration + Subtraction + Impact +Pre-mortem?) → ✓pick + convergence-check + draft → SHAPE (Proposal +Prioritization?) → ✓edit + draft → SPECIFY (Authoring +API?/Data-model? +Verifiability +Demand? + acceptance-test authoring) → ✓iterate + draft → LOCK (✓quality-gate: Review +Verifiability +Arbitration? → ✓refutation-panel: 2-4 skeptics [skipped at depth=light] → ✓sign-off → promote draft to docs/specs/<slug>.md + docs/specs/<slug>.acceptance.md → ✓build-path → emit Spec Handoff Packet) [NO CODE, NO TEST EXECUTION]`

Gate content is not restated in the chain — the seven Quality-Gate dimensions live in § Spec Quality Gate, the panel's polarity and four claims in § Pre-lock refutation panel, the mandatory traceable L3 ACs in Phase 4.

Resumable: `spec-dialogue resume [<slug>]` re-enters from the draft's current-phase marker; `spec-dialogue <slug-or-path>` re-opens a locked spec for revision.
