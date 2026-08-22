# Document Quality — the spec as an artifact someone else must read

**Purpose:** The locked spec and its acceptance test specification are document deliverables. Code has tests; documents have readers — so quality means: the declared reader can make the declared decision from the artifact alone, every externally-checkable fact is grounded, and the document is internally coherent. These rules apply to both; where one names "the spec", read it as "each document".

**Read when:** authoring in Phase 4 SPECIFY, and again at the Spec Quality Gate. The seven gate dimensions in `SKILL.md` audit the spec's *logic*; this file audits it as *prose someone will read at 3 a.m. six months from now*.

---

## 1. Reader contract (W1–W3, W14)

| # | Rule | Discipline |
|---|------|-----------|
| W1 | **Audience and decision declared** | The spec states WHO reads it (role, expertise) and WHAT they do with it — implement it, review it, estimate it, argue with it. A technically perfect document aimed at the wrong reader is a miss. |
| W2 | **Register calibration** | Vocabulary and assumed context follow W1's reader. If both an executive and an implementer must read it, layer the structure (W7) — do not average the prose into something that serves neither. |
| W3 | **Freshness metadata** | The spec carries `as-of` date · owner · **review trigger** — the event or interval that makes it stale ("on pricing change", "when the auth provider is replaced"). Specs rot silently; the trigger makes rot detectable. A genuinely time-insensitive spec says `evergreen` instead. |
| W14 | **The reader's language** | Both documents are written in **the language the user is conversing in** — a spec its declared reader must translate before deciding anything fails W1 before it starts. What does *not* change with language is the machine-readable surface: stable IDs (`REQ-001`, `AC-001`, `TC-001`, `CFR-001`, `ASSUME-1`, `OQ-1`), metadata keys and their enum values (`status: locked`, `Mode: machine`, `Must-have: yes`), file paths, code identifiers, and Handoff Packet field names. Section headings are prose and may be translated; the IDs under them are not, because something downstream cites them. Where the codebase's vocabulary is in another language, W11 still wins — the document adapts to the code. |

## 2. Grounding (W4–W6) — plausible-but-fabricated is the document failure mode

| # | Rule | Discipline |
|---|------|-----------|
| W4 | **Every externally-checkable fact is grounded** | Market sizes, usage numbers, competitor behavior, dates, "studies show", API signatures, library capabilities — each is `sourced` (with the source), `ASSUMPTION` (flagged inline), or `research-to-do`. Internal propositions — the user's own plan, their priorities, the chosen direction — are exempt; the rule targets facts a reader could check and find false. |
| W5 | **UNKNOWN over fabrication** | A gap the dialogue could not close is written as `UNKNOWN` or `TBD(owner)`, never filled with a plausible guess. Specifics are where fabrication hides: numbers, product names, URLs, endpoint shapes, legal citations are **verified or flagged, never improvised**. |
| W6 | **Quote fidelity** | Anything presented as a quotation — of the user, of an existing spec, of a contract — is verbatim, or explicitly marked as paraphrase. Silent paraphrase inside quotation marks is fabrication with extra steps, and in a spec it becomes a requirement nobody agreed to. |

## 3. Readability (W7–W9) — the reader's time is the budget

| # | Rule | Discipline |
|---|------|-----------|
| W7 | **Summary-first, layered** | The spec opens with what its reader needs in ~5 lines, then layers detail. That is exactly what the L0 → L1 → L2 → L3 staging is for. Never make the reader excavate the conclusion. Tables for enumerable facts; prose for reasoning. |
| W8 | **Scannability envelope** | One idea per section; headings state findings, not topics. Section length matched to the reader's stake in it. A spec nobody finishes delivers nothing regardless of its accuracy. |
| W9 | **No padding** | Cover the substance and stop. Filler sections, restated summaries, and boilerplate are not thoroughness — they are the material W7 and W8 exist to prevent, and they dilute the parts a builder must not miss. If a template section has nothing in it, write `N/A` with a one-line reason rather than padding it into plausibility. |

## 4. Coherence (W10–W11)

| # | Rule | Discipline |
|---|------|-----------|
| W10 | **Single source of truth** | Every shared fact — a number, a date, a scope boundary, an entity name — is stated in exactly ONE place; everywhere else references it. Restated facts fork silently on the first edit, and the fork is invisible until a build follows the stale copy. |
| W11 | **Terminology ledger** | One concept, one term, spec-wide. Synonym drift ("user" / "member" / "account" for the same entity) is a defect, not style. On an existing codebase the spec adopts the code's established vocabulary — the document adapts to the code, not the reverse. |

## 5. Completeness (W12–W13)

| # | Rule | Discipline |
|---|------|-----------|
| W12 | **Template completeness, by tier** | The spec carries every section of `spec-template.md`, and its companion every section of `acceptance-test-template.md`. A **conditional** section may be `N/A` with a one-line reason; a **required** one may not — `N/A` on a required section is a lock failure, not a shortcut. A silently missing section reads as "considered and empty" when it means "never considered", and the reader cannot tell which. This is the cheapest check in the file and the one most often skipped. |
| W13 | **Unresolved-marker inventory** | Every `UNKNOWN`, `TBD(<owner>)` and open `ASSUME-n` anywhere in the document appears in Open Questions as an `OQ-n` with an owner and a `Resolve by` level. W5 makes a gap honest; W13 makes it **findable**. A `TBD` buried in an L2 table is indistinguishable from a decision nobody made, and the reader who needs it is the one least able to spot it. |

W13 is what the Quality Gate's **Resolvability** dimension scans for, and it is the rule that turns
"no open questions" from a claim into a check: the inventory is a grep, and its result is either
empty or a list with names against it.

## Failure Modes Prevented

| Failure | Mitigation |
|---------|------------|
| Technically perfect spec for the wrong reader | W1 audience+decision, W2 register, W14 language |
| A spec its reader has to translate before deciding | W14 — the documents follow the dialogue's language |
| Silent rot — facts age, nobody notices | W3 as-of + review trigger |
| **Plausible-but-fabricated specifics** (numbers, names, endpoints) | W4 grounding + W5 UNKNOWN-over-fabrication + W6 quote fidelity |
| Buried conclusions, spec nobody finishes | W7 summary-first + W8 scannability |
| Padding read as thoroughness | W9 no-padding |
| Shared facts forking on the first edit | W10 single source of truth |
| Synonym drift confusing the builder | W11 terminology ledger |
| Missing section read as "considered and empty" | W12 present-or-`N/A`+reason, by tier |
| A `TBD` buried mid-document, found by the build | W13 unresolved-marker inventory |

These rules **specialize** the Spec Quality Gate rather than replacing it: the gate's seven dimensions decide whether the spec is *right*; the W rules decide whether it can be *read and trusted*. Both are lock preconditions.
