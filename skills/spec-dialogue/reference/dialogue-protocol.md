# Dialogue Protocol — elicitation quality (D1–D16)

**Purpose:** The discipline for **how** the `spec-dialogue` recipe conducts its contract-level, human-in-the-loop dialogue. `SKILL.md` owns **when** the dialogue stops (checkpoints, gates); this file owns **how** to ask, how to process answers, and how to prove the locked spec rests on the user's elicited intent rather than silent assumptions. The deliverable of a dialogue recipe is only as good as the elicitation that produced it.

**Read when:** executing any phase of `spec-dialogue` — its checkpoints are contract-level dialogue, so this protocol is mandatory, not optional polish.

---

## 1. Question craft (D1–D5)

| # | Rule | Discipline |
|---|------|-----------|
| D1 | **One focus per turn** | Ask ONE question, or one batched multiple-choice covering ≤ 4 *independent* dimensions. Never a wall of open questions: each extra question halves the answer quality of all of them. |
| D2 | **Recognition over recall** | For preferences or a known design space, offer 2–4 genuinely distinct candidate answers and allow other answers. For factual input, inspect available sources first. If the option space itself is unknown (entity, customer segment, date, policy, owner), ask a short free-text question for the fact or its source; use factual candidates only when evidenced, never invented. A factual answer is evidence to attribute, not a product choice to ratify. |
| D3 | **Concrete anchor** | Ground abstract questions in a scenario: "walk me through the last time X happened" beats "what do you need from X". When the user speaks abstractly, ask for one concrete instance before persisting the abstraction. |
| D4 | **Polarity discipline** | No leading questions at divergence points (EXPAND, initial reactions to options) — the user's unprimed reaction is the data. Leading is *correct* when confirming a paraphrase ("so the job is X — right?"). Wrong polarity at the wrong point either contaminates divergence or slows convergence. |
| D5 | **Tacit-knowledge probes** | The user's tacit knowledge is load-bearing in FRAME. Elicit it with: **critical incident** ("when did this last fail or shine?"), **contrast** ("why X and not Y?"), **boundary** ("when would this answer be wrong?"), **history** ("what was true when this was built that isn't now?"). |

## 2. Answer processing (D6–D8)

| # | Rule | Discipline |
|---|------|-----------|
| D6 | **Paraphrase-back before persist** | Before writing any user decision to the draft, reflect it back in 1–2 lines in *different words* than the user used — echoing their words verbatim tests nothing. Persist only the confirmed paraphrase. **Protected terms are the exception:** a domain term the user defines or insists on ("delete marker — it does *not* mean permanent deletion"), or one already in the Glossary, is kept verbatim and the paraphrase goes *around* it — restate what it means and what it excludes, never swap in a synonym that blurs the distinction. The term then enters the Glossary with its `Not to be called` list. |
| D7 | **Vague-answer rule** | A low-information answer ("sounds fine", "whatever works") gets exactly ONE concretizing follow-up in D2/D3 form. If still vague, do not badger: record the point as an `ASSUME-n` entry (§3) with your chosen default and continue only independent work; an unresolved factual input remains unknown (D2/D9). |
| D8 | **Contradiction surfacing** | When a new answer conflicts with an earlier persisted decision, surface it immediately and explicitly ("this changes DEC-2 from X to Y — intentional?"). Never silently overwrite; never silently keep the old one. The resolution is itself a persisted decision. |

## 3. Assumption Ledger (D9)

Every unconfirmed decision default — skipped questions, D7 vague answers, or D15 delegated decisions — is recorded in the draft's **Assumption Ledger**. Sourced facts use `grounded` (D16), not user ratification. A missing factual input remains unknown and is sought from its source or recorded as an Open Question; a guessed fact does not become true through approval:

```
| ID | Assumption | Default chosen | Why | Status |
|----|-----------|----------------|-----|--------|
| ASSUME-1 | Notification delivery is best-effort | at-least-once NOT required | user skipped reliability Q | open |
```

- **Lifecycle:** `open` → `confirmed` (user ratifies at a checkpoint) → becomes a decision; or `open` → **Open Questions** at LOCK. `open` entries never silently disappear.
- **Checkpoint duty:** every checkpoint presentation shows the count of open assumptions and lists any *new* ones since the last checkpoint (delta-only, per D10).
- **Final-gate duty:** at LOCK, walk the remaining `open` entries with the user — each is either ratified or moved to Open Questions / Deferred Decisions. Parking preserves visibility, not permission to LOCK with a dependency unresolved (`spec-template.md`). This is what the Provenance Gate (§6) verifies.

## 4. Checkpoint presentation (D10–D12)

| # | Rule | Discipline |
|---|------|-----------|
| D10 | **Envelope + delta-only** | A checkpoint presentation fits ~15 lines. On iteration, present the **delta** since the last turn, never re-dump the whole artifact — the full state lives in the draft file the user can open. An unreadable checkpoint produces a rubber-stamp confirm, which is worse than no checkpoint. |
| D11 | **Option quality** | Options must be genuinely distinct, each with a one-line trade-off — and never padded: when only one or two are real, show one or two and name what closes the rest. During divergence, present them neutrally, without a recommendation or ranking (D4). Mark a recommendation and its reason only during convergence, after the user's unprimed reaction; a first reaction does not itself end divergence. A question asking the user to *pick* offers 2–4 options; a 5th means the framing is wrong. (EXPAND's 3–5 candidate *directions* are the material being explored, not a single pick question.) |
| D12 | **Orientation line** | Every checkpoint opens with one line of state: current phase · decisions locked so far (count) · open assumptions (count). The user steering a long dialogue must never have to ask "where are we?". |

## 5. Engagement calibration (D13–D15)

| # | Rule | Discipline |
|---|------|-----------|
| D13 | **Depth follows signal** | Rich, detailed answers → deepen (more D5 probes, finer options). Terse answers trending shorter → compress: batch dimensions into one question, propose defaults, lean on the Ledger. Matching the user's bandwidth is part of the contract, not a courtesy. |
| D14 | **Circling detection (all phases)** | If any dialogue point circles ≥ 2 rounds with no new information, name it and offer: (a) adopt the leading option, or (b) park it as `ASSUME-n` / Open Question and continue only independent work. Neither path waives LOCK preconditions. This generalizes the Phase 2 convergence check to every phase. |
| D15 | **Delegate mode** | When the user says "just decide" / "任せる", switch to propose-and-confirm: make the call, record it as `ASSUME-n (delegated)`, and continue. Contract-level checkpoints still fire — but they present the delegated decisions for ratification instead of asking the original questions. Delegation compresses the dialogue; it never deletes the checkpoints — and it never covers sign-off or the build-path choice, which stay the user's own words. |

## 6. Provenance Gate (D16)

Before LOCK, classify every **load-bearing element** of the spec (each L1 requirement, each L3 AC, each scope boundary) by provenance:

| Class | Meaning | Allowed in the locked spec? |
|-------|---------|-----------------------------|
| `elicited` | product preference or decision traceable to an explicit user utterance (confirmed meaning, D6) | yes |
| `ratified` | decision started as `ASSUME-n`, approved at a checkpoint | yes |
| `grounded` | factual claim or authoritative constraint supported by an inspected source or attributed first-hand testimony, with locator, version/date and applicability | yes, within that evidence's scope |
| `parked` | recorded in Open Questions / Deferred Decisions | only if non-blocking under `spec-template.md`'s dependency-based Lock rule |
| `silent` | no decision provenance or adequate factual support | **no — the gate fails** |

A `silent` decision needs targeted elicitation or a disclosed Ledger entry; a factual claim needs evidence or an Open Question. The gate re-runs. User approval cannot verify an external fact. An observation of existing behavior is not a decision to preserve it; a measured limit is not a chosen target. Split mixed claims into their factual support and product decision without multiplying requirement IDs. `derived from <ID>` inherits traceable support only when it adds no new choice or empirical premise.

## Failure Modes Prevented

| Failure | Mitigation |
|---------|------------|
| Wall-of-questions turn → shallow answers on all of them | D1 one focus per turn |
| Blank open questions → "I don't know, you decide" spirals | D2 recognition over recall, D3 concrete anchor |
| Leading questions contaminate divergence | D4 polarity discipline |
| Tacit knowledge never surfaces (the user didn't know it was relevant) | D5 probes (critical-incident / contrast / boundary / history) |
| Misheard decision persisted to the draft | D6 paraphrase-back in different words |
| Badgering a disengaged user / swallowing a vague answer as consent | D7 one follow-up then Ledger |
| Contradictory answers silently merged | D8 contradiction surfacing |
| **Silent assumptions ship inside a "perfect-looking" spec** | D9 Assumption Ledger + D16 Provenance Gate |
| Checkpoint fatigue → rubber-stamp confirms | D10 envelope/delta, D12 orientation, D13 calibration |
| Indistinct options → fake choice | D11 option quality |
| Endless circling on one point | D14 generalized circling detection |
| "Just decide" collapses the contract checkpoints | D15 delegate mode (compresses, never deletes) |

## Wiring into `spec-dialogue`

- **FRAME** — Socratic clarification runs D1–D8; D5's history and contrast probes are the tools that surface constraints the user forgot they had.
- **Every checkpoint** — D10–D12 (envelope, delta-only, orientation line), calibrated per D13.
- **The draft** — carries the Assumption Ledger (§3) as a named section from FRAME onward.
- **The Spec Quality Gate** — carries **Provenance** (D16) as one of its dimensions, alongside ambiguity, completeness, consistency, testability, scope coherence, economy and resolvability.

This protocol governs **your own conversation with the user**. It is not an instruction to pass to a spawned lens: lenses produce material; the dialogue that presents it is yours alone.
