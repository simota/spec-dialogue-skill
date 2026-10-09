# Roles — the analytical lenses `spec-dialogue` runs

**Purpose:** `spec-dialogue`'s phases name lenses rather than tools. Each lens is a **framing question plus an output shape** — a stance you adopt, not a dependency you install. This file defines all 18 so the recipe runs with nothing but a text editor and a conversation.

**How to run a lens.** Two equivalent modes:

- **Sequential (always available).** Adopt one lens at a time. Announce it to yourself, answer only its framing question, produce only its output shape, then drop the stance before adopting the next. The discipline that makes this work is **not blending** — a "Subtraction pass" that also proposes additions has not run.
- **Parallel (when your harness offers subagents).** Spawn one agent per lens with the framing question as its brief and the output shape as its return contract. Independence improves the CHALLENGE phase and the refutation panel most; it matters least for the authoring lenses.

Each lens below is a `###` heading whose next line is its **Question:** — that shape is what
`make check` counts when it verifies the number this file claims to define. A `###` heading of
any other shape is prose, not a lens, and is not counted.

**Two rules bind every lens:**

1. **A lens produces material; it never talks to the user.** The dialogue is the hub's alone (`dialogue-protocol.md` § Wiring into `spec-dialogue`). A lens that asks the user a question has broken the one-focus-per-turn rule on the hub's behalf.
2. **A lens states its confidence and its evidence.** "This already exists in the codebase" and "I would guess this exists" are different findings, and only the first can block a direction.

---

## FRAME lenses

### Demand — the real job-to-be-done
**Question:** What is the user actually trying to get done, and what pain makes them ask for this *now*? What would they do if this feature did not exist?
**Output:** the job-to-be-done in one sentence · 2-4 latent needs the stated request does not name · the workaround the user has today.
**Discipline:** simulate the user rather than speaking for them; distinguish an observed pain from an assumed one, because the refutation panel will attack exactly that line. Also used in SPECIFY for a usability sanity-pass over a shaped UI flow.

### Research-grounding — what the real data says
**Question:** What do we actually know about these users from research, telemetry, support tickets, or interviews — and where does it contradict the stated request?
**Output:** grounded findings with their source · the contradiction list · what is unknown and would need research.
**Discipline:** only runs when real data exists. With no data, say so; do not synthesize a finding and present it as research. `doc-quality.md` W4/W5 govern the write-up.

### Persona — who exactly
**Question:** Which distinct user types does this serve, and how do their goals conflict?
**Output:** 2-3 personas with goal, context of use, and constraint · the conflict between them, named.
**Discipline:** run only when the audience is genuinely unclear. A persona invented to fill a template is noise; a persona that names a conflict ("the admin wants control, the end user wants speed") shapes the whole spec.

### Reuse-scan — what already ships
**Question:** Does a comparable feature, module, or pattern already exist in this codebase? What is reusable, and what technical constraints — stack, data model, integration points, existing conventions — bound the solution?
**Output:** existing assets with paths · reusable pieces · the constraint list · the "this is already 60% built" finding if there is one.
**Discipline:** **skip on greenfield.** On an existing codebase this is the highest-value lens in FRAME — it is what stops a spec that re-derives shipped code. Read the code; do not infer its contents from its names.

## EXPAND lenses

### Divergence — the option space
**Question (pass 1, propose):** What are genuinely different shapes this could take?
**Question (pass 2, reframe):** Which assumption in the framing, if dropped, opens a direction nobody has considered? What does another domain do about this exact problem?
**Output:** 3-5 candidate directions, each with a one-line rationale and rough shape, spanning genuinely different trade-offs.
**Discipline:** run both passes — a single propose pass yields three variations on one idea. Distinctness is the quality bar (D11): if two candidates differ only in wording, one of them is not a candidate. When a grounded constraint leaves fewer than three, return fewer and name the constraint — padding the list is the same defect as a duplicate.

### Market — prior art and differentiation
**Question:** Who already solves this, how, and what does that imply about which direction is worth building?
**Output:** the prior-art list · what each does well and badly · the differentiation gap, if any.
**Discipline:** claims about competitors are externally-checkable facts (W4) — sourced or flagged. "Nobody does this" is the single most common fabricated finding in a spec.

## CHALLENGE lenses

### Arbitration — is it necessary
**Question:** From several expert stances at once — is this direction the right one? What does each stance say the others are missing?
**Output:** the per-perspective read · where they conflict · the trade-off the user must actually decide.
**Discipline:** produce the disagreement, not a merged average. A single blended verdict has thrown away the information the lens exists to generate.

### Subtraction — is it over-scoped
**Question:** What can be cut and still deliver the job-to-be-done? Which requirement is here because it is needed, and which because it seemed natural to include?
**Output:** the cut list with a one-line justification each · the irreducible core.
**Discipline:** attack scope, never the direction — that is Arbitration's job. Safety, security, and compliance items are out of this lens's reach entirely (`refutation-protocol.md` §4).

### Impact — is it feasible
**Question:** What does this touch? Which dependency chains, which shared modules, which existing behaviors change under it?
**Output:** the blast radius · the risky integration points · a rough size class (contained / spreads / structural).
**Discipline:** vertical (what depends on what) and horizontal (what pattern must stay consistent) both. An estimate here is not a schedule — it is a feasibility signal for the pick.

### Pre-mortem — how it fails
**Question:** It is six months from now and this shipped and failed. What happened?
**Output:** ranked failure scenarios, each with its trigger, its early warning sign, and what would prevent it.
**Discipline:** run when stakes are high or the change is expensive to reverse. Failure modes with no early warning sign are the dangerous ones — mark them.

## SHAPE lenses

### Proposal — the structured synthesis
**Question:** What is the chosen direction, stated so someone who missed the conversation understands it?
**Output:** problem → proposed solution → in-scope → out-of-scope → assumptions → open questions.
**Discipline:** this is the last stop before authoring, so every item the dialogue raised must already sit in exactly one of in-scope / out-of-scope — the Quality Gate's Scope-coherence dimension checks exactly that.

### Prioritization — what is Must
**Question:** If this decomposes into sub-features, which are Must, Should, Could, Won't — and by what stated criterion?
**Output:** the MoSCoW table with the criterion named.
**Discipline:** run only when the direction genuinely decomposes. The Must set becomes the must-have AC flags (`traceability.md` §3), so this lens is not cosmetic — it decides what blocks ship.

## SPECIFY lenses

### Authoring — the staged spine
**Question:** How does this direction become L0 Vision → L1 Requirements → L2 Detail → Behavior matrix → L3 Acceptance Criteria, and the `TC-n` procedures that discharge them?
**Output:** the spec sections per `spec-template.md` and the companion suite per `acceptance-test-template.md`, each requirement, criterion and case carrying a stable ID.
**Discipline:** one layer at a time, top down. Writing L3 before L1 is settled produces criteria for requirements nobody agreed to. Every AC names the requirement it verifies as it is written — retrofitting the mapping afterward is how orphan criteria survive.

### API-detail — the interface
**Question:** What are the endpoints, payloads, error shapes, and versioning implications?
**Output:** the interface contract in L2, at the fidelity the reader needs to build against it.
**Discipline:** run only when the feature has an interface others consume. Signatures are externally-checkable facts (W4/W5) — verified against real code, or marked as proposed.

### Data-model — the storage
**Question:** What entities, relationships, migrations, and access constraints does this imply?
**Output:** the data-model section in L2 · the migration note · the isolation/permission implications.
**Discipline:** run only when the feature changes storage. An additive-vs-breaking migration distinction stated here saves an argument later.

### Verifiability — is each AC actually checkable
**Question:** For each AC — what exactly would someone run or look at to decide pass or fail, and does a `TC-n` actually spell it out? Could an implementation pass this AC while failing its requirement?
**Output:** per-AC verdict (verifiable / vague / no named oracle / oracle names a person but no observation or pass/fail rule / no test case / not entailing its requirement) with the specific defect named.
**Discipline:** this is the lock precondition's teeth. "The system is fast" fails; "p95 under 200 ms on the listed endpoint at 100 rps" passes. The entailment question (`traceability.md` §3) matters more than the wording one.

## LOCK lenses

### Adversarial-review — the spec as an artifact
**Question:** Read only this document, knowing nothing of the conversation. Where is it ambiguous, incomplete, contradictory, untestable, scope-incoherent, or padded with lines that change nothing?
**Output:** findings against the eight Quality-Gate dimensions, each pointing at a specific line.
**Discipline:** **the author never runs this on their own work.** With no separate agent available, run it as a distinct pass with the authoring context deliberately set aside — read the spec as a stranger would, from the document alone, and treat every place you have to remember the conversation to understand a line as a finding.

### Skeptic — kill the spec
**Question:** Assigned one of the four load-bearing claims — refute it.
**Output:** the refutation attempt, classified `refuted-on-evidence` (with the fact) or `unproven-because-new`.
**Discipline:** fully governed by `refutation-protocol.md`. Prompted to kill, not to evaluate; 2-4 independent skeptics on distinct claims; the evidence-vs-novelty distinction is what stops the panel from punishing ambition.
