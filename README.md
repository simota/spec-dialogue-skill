# spec-dialogue — a standalone specification skill

Turn a rough feature idea into a **locked, acceptance-criteria-bearing specification** — and the **acceptance test specification** that says how anyone decides whether it was met — through deep human-in-the-loop dialogue. Six phases, checkpoints you cannot skip, an adversarial quality gate, and explicit sign-off. **Writes no code and runs no tests.**

Extracted from a larger orchestration suite and made **fully self-contained**: no other skill, agent, registry, or repository is required. Everything it depends on is in `reference/`.

## Install

The skill lives at `skills/spec-dialogue/`; that directory is what gets linked, not the repository
root — the README and the test battery stay behind.

```sh
make link                      # every agent CLI installed here
make link AGENT=codex          # just one — claude | codex | agy
make link PROJECT=/path/repo   # that repository, instead of the home directories
make status                    # where is it linked?
make unlink                    # remove the links that point at this repo
make check                     # verify every reference resolves inside the skill directory
make test                      # run the fixture battery over `make check` and `make link`
```

Three CLIs read a `SKILL.md` with YAML frontmatter, and each looks somewhere different:

| Agent | Global | Inside a project |
|-------|--------|------------------|
| `claude` | `~/.claude/skills` | `<repo>/.claude/skills` |
| `codex` | `$CODEX_HOME/skills`, default `~/.codex/skills` | `<repo>/.agents/skills` |
| `agy` | `~/.gemini/config/skills` | `<repo>/.agents/skills` |

`make link` symlinks `skills/spec-dialogue/` into each of them, so a `git pull` here updates every
installed copy at once. A CLI whose own directory does not exist is **skipped, not created** — linking
does not conjure `~/.gemini/config` for someone who has never run agy — and `codex` and `agy` share
`.agents/skills` inside a project, so one link there serves both.

Nothing at the destination is ever overwritten: a real directory, or a symlink into some other
checkout, is refused and left alone, and `make unlink` removes only the links pointing at this repo.
Override the destination outright with `SKILLS_DIR=<dir>` when your runtime keeps skills somewhere
none of the three names.

## Use

```
spec-dialogue                      # new dialogue
spec-dialogue depth=light          # small, bounded change — fewer turns, same lock preconditions
spec-dialogue depth=deep           # high-stakes or contested — extended divergence, full skeptic panel
spec-dialogue resume [<slug>]      # re-enter from the last checkpoint
spec-dialogue <slug-or-path>       # re-open a locked spec for revision
```

The dialogue writes `docs/specs/<slug>.draft.md` incrementally and promotes it to `docs/specs/<slug>.md` at sign-off, together with its companion `docs/specs/<slug>.acceptance.md` — the `TC-n` test cases, the environment and fixtures they need, and the exit criteria that define acceptance. Every result is left `NOT_RUN`: the skill writes the suite, never its outcome.

## Layout

| Path | Purpose |
|------|---------|
| `Makefile` | `link` / `unlink` / `status` per agent CLI, plus `check` / `test` |
| `tools/check.sh` | The fixture battery `make test` runs — what keeps `make check` and `make link` honest |
| `skills/spec-dialogue/` | The skill itself — the directory `make link` symlinks |
| `docs/index.html` | The published site — one self-contained page explaining the workflow |

Paths below are relative to `skills/spec-dialogue/`.

| File | What it holds |
|------|---------------|
| `SKILL.md` | The recipe: phase contract, depth modes, quality gate, refutation panel, handoff |
| `reference/dialogue-protocol.md` | D1–D16 — question craft, answer processing, Assumption Ledger, Provenance Gate |
| `reference/roles.md` | The 18 analytical lenses, each defined inline |
| `reference/refutation-protocol.md` | Skeptic-panel composition, evidence-vs-novelty, aggregation, exclusions |
| `reference/traceability.md` | `REQ-n` / `AC-n` / `TC-n` / `OQ-n` ID scheme, the AC shape, and the two-hop `REQ → AC → TC` linking rule |
| `reference/doc-quality.md` | W1–W15 — reader contract, grounding, readability, coherence, completeness, precision |
| `reference/spec-template.md` | The spec document template — section tiers, Behavior matrix, Given/When/Then ACs — and the Spec Handoff Packet |
| `reference/acceptance-test-template.md` | The companion acceptance test specification — `TC-n` cases, environment, fixtures, exit criteria, defect severities, sign-off |

## Docs site

`docs/index.html` is a single self-contained page that explains the skill — the six phases and their
checkpoints, the return edges a failing gate takes, the two documents it emits, the `REQ → AC → TC`
chain, the eight-dimension gate, the refutation panel's four claims, and what actually blocks a lock.
No build step, no dependencies, one file.

```sh
make pages   # serve docs/ at http://localhost:8000 to preview
```

To publish it: **Settings → Pages → Source: Deploy from a branch → `main` / `/docs`**. The site then
lives at `https://<owner>.github.io/<repo>/`.

The page is explanatory only; `skills/spec-dialogue/SKILL.md` and its `reference/` files stay
canonical. Nothing generates the page, so nothing silently drifts without a diff to review — and
`make check` reads the page with its tags stripped, so the two counts it states — 18 lenses and
eight gate dimensions, in the fact strip and in the prose alike — cannot drift from what
`reference/roles.md` and `SKILL.md` actually define.

## The idea

Most spec tooling treats user confirmation as a gate around autonomous work. `spec-dialogue` inverts it: **the back-and-forth is the work**, and the document is its crystallized output. Three things make that hold up rather than drift:

- **Checkpoints are contract-level.** Even an autonomous caller stops at them. A single-pass spec that reports itself as dialogue is the failure this exists to prevent.
- **Every criterion is testable and traceable.** The difference between a spec and a wish is that a machine or a human can decide pass or fail — and that a green criterion actually entails the requirement it claims to verify. Each AC is a Given/When/Then scenario with a **named oracle**: the thing that decides.
- **Every must-have criterion has a procedure behind it.** An AC that reads as testable is not the same as an AC someone has written concrete steps, data and an environment for — and the difference only surfaces when you try to write them. That happens at SPECIFY, while the AC can still be rewritten.
- **The gaps are shaped as blank cells, not silence.** A spec is rarely wrong because someone wrote a falsehood; it is wrong because nobody wrote the empty-state behaviour or the latency number. The template's fixed slots — the Behavior matrix, the four L2 tables, the measured `CFR-n` — turn a forgotten question into a visible hole.
- **Nothing is silent.** Every load-bearing element of the locked spec is traceable to something the user said, ratified, or explicitly parked. The Provenance Gate blocks the lock otherwise.

## Runs anywhere

The phases name **lenses** — a framing question plus an output shape — not tools. Adopt them in sequence yourself, or spawn them as parallel subagents if your harness has them. Both are correct; `reference/roles.md` defines all 18.
