# Adversarial Refutation Protocol

**Purpose:** The discipline for **stress-testing a high-stakes claim with a panel of independent skeptics before committing to it**. A claim survives only if it withstands a genuine attempt to refute it. `spec-dialogue` uses it once — the pre-lock panel that attacks the four load-bearing claims a locked spec silently asserts.

**Read when:** running the pre-lock refutation panel (`SKILL.md` § Pre-lock refutation panel).

---

## 1. The panel

- **2-4 independent skeptics**, each attacking from a **distinct angle**, not several copies of the same objection. One skeptic per assigned claim — a skeptic carrying two claims blends the angles the panel exists to keep apart. Independence is the whole point: a single reviewer rationalizes; a diverse panel surfaces failure modes redundancy can't.
- **Diversify the priors where you can.** If your harness offers subagents or a second model, give each skeptic a different one — model monoculture defeats the panel, because the same priors produce the same blind spots. Where only one engine is available, diversify by **assigned angle and by evidence source**: one skeptic argues from the codebase, one from the user's own stated constraints, one from prior art, one from the spec document alone. Four sources for four claims — a panel larger than its list of sources has a skeptic improvising one. Record which angle each skeptic ran.
- **Each skeptic is prompted to actively REFUTE**, from its assigned angle. A skeptic asked to "evaluate" will hedge; one asked to "kill this claim" finds the real weakness.

For `spec-dialogue`, the angles are fixed by the four load-bearing claims: problem reality · direction dominance · AC entailment · scope separability.

---

## 2. The evidence-vs-novelty discipline (the load-bearing nuance)

The panel must **kill weak claims, not bold ones.** The distinction that does this work:

- **Refuted-on-evidence** — a *concrete* fact defeats the claim: a comparable feature already ships, the cited pain is contradicted by measured behavior, a specific delivery blocker exists, an AC demonstrably passes on a non-conforming implementation. This is a real refutation.
- **Unproven-because-new** — there is no data *because no one has built it yet*. "We have no proof it works" is the **signature of a genuine novel bet**, not grounds for rejection.

**Default-to-refuted-when-uncertain applies only to *evidence claims*** — it must **not** kill a claim merely for being ambitious or unvalidated. A claim that survives evidence-based refutation but remains unproven-because-new routes to **LOCK-with-flag**, the flag naming the assumption it rests on and, where possible, the observation that would falsify it after ship.

> The gate exists to stop *plausible-but-wrong* from being locked, not to enforce conservatism. Penalizing a feature for lacking proof that can only exist post-launch is the exact failure this protocol guards against.

---

## 3. Verdict aggregation

- **Majority on evidence decides.** Majority refuted-on-evidence → **back to the earliest invalidated decision** (`SKILL.md` § Draft persistence & resume) — not a park, because the spec is defective rather than incomplete. Majority merely-unproven → **LOCK-with-flag**.
- **Carry forward the survivors' failures.** Record which refutations the spec survived and which it failed, and whether each open risk is "refuted-on-evidence" or "unproven-because-new". On a loop back to CHALLENGE, **carry refuted directions forward as exclusions** while the defeating evidence still applies, so the reframe does not re-derive an already-refuted option from unchanged premises.
- **Surface, don't bury.** The Open Questions section states the surviving and failed refutations so the sign-off is auditable. A panel whose findings do not appear in the locked document did not run.

---

## 4. Hard exclusions (never decide on a panel vote alone)

- **Safety-critical scope** (auth, encryption, input validation, anything with a regulatory obligation) is **not cut from a spec on a skeptic panel's vote** — a panel does not authorize removing a control. Park it and escalate to a human with the relevant authority.
- **Confidence `< 60%`** → do not act on the destructive reading; route to "defer + gather evidence" and park it as an Open Question.
- **A verdict flips on new evidence, never on pressure.** Objection from the author, the user, or a louder panel member is not a refutation — only a fact that was not in the record is. Evidence updates the verdict no matter who supplies it, **including the party being refuted**; unaccompanied objection does not. Name the triggering evidence, or do not flip.

Parking under this protocol does not waive the dependency-based Lock rule (`spec-template.md`). An unresolved mandatory control or acceptance dependency still blocks LOCK.

**Three ways over-correcting fails.** The goal is independence from pressure, not refusal to move:

- **Contrarian drift** — objecting by default, hedging every claim, second-guessing the user inside their own domain. Disagreement has become the posture rather than the finding.
- **Disclaimer substitution** — "the final call is yours" appended to output that already narrowed the options. Returning responsibility in words while removing it in substance.
- **False neutrality** — presenting two sides where the evidence is not two-sided. Declining to flip must not flatten a real evidence gap into a balanced-looking summary.
