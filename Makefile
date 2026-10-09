# spec-dialogue — install by symlink
#
#   make link                     link into every agent CLI installed here
#   make link AGENT=codex         link into one of them (claude | codex | agy)
#   make link PROJECT=/path/repo  link into that repository instead of the home directories
#   make unlink                   remove only the links pointing at this repo (same rules)
#   make status                   show where the skill is linked
#
# The skill itself is `skills/spec-dialogue/` — that directory, not the repository root, is
# what gets linked, so the repo can carry a README and a test battery the skill does not ship.
#
# Three CLIs read a `SKILL.md` with YAML frontmatter, and each looks somewhere different:
#
#   agent   global                              project
#   claude  ~/.claude/skills                    <repo>/.claude/skills
#   codex   $$CODEX_HOME/skills  (~/.codex)     <repo>/.agents/skills
#   agy     ~/.gemini/antigravity-cli/skills    <repo>/.agents/skills
#
# codex and agy share `.agents/skills` at project scope, so one link there serves both — the
# duplicate collapses in `$(sort ...)` below rather than in a special case.
#
# Each target carries the directory that must already exist for it to be written, as
# `guard|destination`. Globally the guard is the CLI's own home: a missing `~/.gemini/antigravity-cli`
# means agy is not installed here, and `make link` skips it rather than conjuring the tree for
# a CLI the user does not run. Under PROJECT= the guard is the repository root instead — there
# `.claude/` and `.agents/` are exactly what we are expected to create.
#
# SKILLS_DIR overrides the destination outright, for a runtime none of the three names:
#   make link SKILLS_DIR=~/.config/agents/skills
# A directory named that explicitly is not a probe for an installed CLI, so it has no guard to
# skip on — `/` stands in — and is created in full rather than reported missing.

NAME    := spec-dialogue
REPO    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SKILL   := $(REPO)/skills/$(NAME)
PROJECT ?=
AGENT   ?= claude codex agy
PAGES    := $(REPO)/docs
PAGES_PORT ?= 8000

# Each CLI's global skills directory, relative to $(HOME). The targets below are built from these,
# and `make check` reads the same list to verify that the README and the published page document
# the directories `make link` actually writes — an install table that names a stale path sends
# readers to a directory their CLI never reads, and nothing else would notice.
GLOBAL_claude := .claude/skills
GLOBAL_codex  := .codex/skills
GLOBAL_agy    := .gemini/antigravity-cli/skills
# codex reads $CODEX_HOME rather than a fixed directory; GLOBAL_codex is its default.
CODEX_HOME ?= $(HOME)/$(patsubst %/,%,$(dir $(GLOBAL_codex)))

GLOBALS       := $(foreach g,$(GLOBAL_claude) $(GLOBAL_codex) $(GLOBAL_agy),'~/$(g)')

# A `~` reaches make quoted, so nothing ever expands it: `PROJECT=~/repo` would resolve against
# the current directory. Expand a leading `~/` here, before anything builds a path out of it.
tilde     = $(abspath $(patsubst ~/%,$(HOME)/%,$(1)))
PROJECTD := $(call tilde,$(PROJECT))
SKILLSD  := $(call tilde,$(SKILLS_DIR))

ifeq ($(strip $(PROJECT)),)
# The guard is the CLI's home: the global skills directory with its last component dropped.
cli_home   = $(HOME)/$(patsubst %/,%,$(dir $(GLOBAL_$(1))))
tgt_claude := $(call cli_home,claude)|$(HOME)/$(GLOBAL_claude)
tgt_codex  := $(CODEX_HOME)|$(CODEX_HOME)/skills
tgt_agy    := $(call cli_home,agy)|$(HOME)/$(GLOBAL_agy)
else
tgt_claude := $(PROJECTD)|$(PROJECTD)/.claude/skills
tgt_codex  := $(PROJECTD)|$(PROJECTD)/.agents/skills
tgt_agy    := $(PROJECTD)|$(PROJECTD)/.agents/skills
endif

# An unknown AGENT is a typo, and a typo that silently links nothing is worse than a stop.
UNKNOWN := $(filter-out claude codex agy,$(AGENT))
ifneq ($(UNKNOWN),)
$(error unknown AGENT: $(UNKNOWN) — pick from: claude codex agy)
endif

ifeq ($(strip $(SKILLS_DIR)),)
TARGETS := $(sort $(foreach a,$(AGENT),$(tgt_$(a))))
else
TARGETS := /|$(SKILLSD)
endif

# `guard|destination` carries a `|`, which the shell reads as a pipe in an unquoted `for` list.
QTARGETS := $(foreach t,$(TARGETS),'$(t)')

.PHONY: help link unlink status check test pages

help:
	@echo "make link      [AGENT=<a>] [PROJECT=<repo>] [SKILLS_DIR=<dir>]  symlink $(NAME) into each skills directory"
	@echo "make unlink    [AGENT=<a>] [PROJECT=<repo>] [SKILLS_DIR=<dir>]  remove the links this repo owns"
	@echo "make status    [AGENT=<a>] [PROJECT=<repo>] [SKILLS_DIR=<dir>]  report each destination"
	@echo "make check                                                      verify this skill is self-contained"
	@echo "make test                                                       run the fixture battery over make check and make link"
	@echo ""
	@echo "make pages                                                      preview the docs/ site (PAGES_PORT=$(PAGES_PORT))"
	@echo ""
	@echo "agents: $(AGENT)   (claude | codex | agy)"
	@echo "repo:   $(REPO)"
	@echo "skill:  $(SKILL)"
	@$(foreach t,$(TARGETS),echo "dest:   $(word 2,$(subst |, ,$(t)))/$(NAME)";)

# A destination that is already our link is reported and counted, not relinked. Anything else
# occupying the name — a real directory, or a link into some other checkout — is refused and
# left alone: the one thing `make link` must never do is delete a skill it did not install.
link:
	@n=0; \
	for t in $(QTARGETS); do \
		guard=$${t%%|*}; dir=$${t##*|}; d="$$dir/$(NAME)"; \
		if [ ! -d "$$guard" ]; then echo "skip     $$d — $$guard does not exist"; continue; fi; \
		if [ -L "$$d" ]; then \
			if [ "$$(readlink "$$d")" = "$(SKILL)" ]; then echo "ok       $$d already linked"; n=$$((n+1)); continue; fi; \
			echo "refusing $$d is a symlink to $$(readlink "$$d") — resolve it, then re-run" >&2; exit 1; \
		elif [ -e "$$d" ]; then \
			echo "refusing $$d exists and is not a symlink — move it aside first" >&2; exit 1; \
		fi; \
		mkdir -p "$$dir" && ln -s "$(SKILL)" "$$d" || exit 1; \
		echo "linked   $$d -> $(SKILL)"; n=$$((n+1)); \
	done; \
	if [ $$n -eq 0 ]; then echo "nothing linked — no skills directory found for: $(AGENT)" >&2; exit 1; fi; \
	echo "invoke it with:  spec-dialogue   (or /spec-dialogue in a slash-command harness)"

unlink:
	@for t in $(QTARGETS); do \
		dir=$${t##*|}; d="$$dir/$(NAME)"; \
		if [ -L "$$d" ] && [ "$$(readlink "$$d")" = "$(SKILL)" ]; then rm "$$d"; echo "unlinked $$d"; \
		elif [ -L "$$d" ]; then echo "skip     $$d — links to $$(readlink "$$d"), not this repo"; \
		elif [ -e "$$d" ]; then echo "skip     $$d — not a symlink, leaving it alone"; \
		else echo "none     $$d"; fi; \
	done

status:
	@echo "skill    $(SKILL)"
	@for t in $(QTARGETS); do \
		dir=$${t##*|}; d="$$dir/$(NAME)"; \
		if [ -L "$$d" ]; then echo "link     $$d -> $$(readlink "$$d")"; \
		elif [ -e "$$d" ]; then echo "other    $$d exists and is not a symlink"; \
		else echo "none     $$d"; fi; \
	done

# Self-containment is this skill's whole premise: every path it cites must resolve inside
# `skills/$(NAME)/`, every file in reference/ must be named by SKILL.md, no cited path may reach
# through a parent, and the lens count the prose claims
# must match what reference/roles.md actually defines — counted as `### ` headings whose next line
# is `**Question:**`, so a note added to roles.md does not inflate it. The same rule covers the
# Quality Gate: the dimension count the prose claims must match the rows SKILL.md tabulates, since
# a gate that grows a dimension nobody renamed the prose for is a gate half the readers do not run.
# The prose writes that count in words, so the check maps six..ten rather than pretending prose says
# `7`. The published page writes it as a digit in its fact strip, which the word scan cannot see, so
# a second scan reads the digit — anchored to the phrase `N gate dimensions` rather than to any
# markup, and safe against a bare `4 independent dimensions` elsewhere in the prose. Both count scans
# read docs/index.html with its tags stripped: a page that says six while the gate has seven is the
# drift a reader is most likely to meet and least able to check. `tools/check.sh` is the battery that keeps this recipe honest — run `make test`
# after editing anything below.
#
# The reference sweep runs the other direction from the citation scan — cited-but-missing is one
# failure, present-but-uncited is the other, and only the first is visible to someone reading.
#
# The install-path scan reads README.md and docs/index.html (tags stripped) for every home-relative
# path they show — `~/.x`, `$HOME/.x`, `${HOME}/.x` — and holds it against GLOBAL_*. A documented
# path that is neither a global skills directory, one of its parents (a CLI home), nor something
# inside one is a stale path; a global skills directory that either page fails to document is the
# other failure.
#
# DOCS is one list for every scan that reads prose: a check that names its own subset is how a file
# quietly escapes every one of them. It spans the repo README as well as the skill, because the README
# cites the same reference files and repeats the same lens count. The shell globs it after the cd,
# so `make -f <path>/Makefile check` from another directory reads the skill's files rather than
# nothing. Every cited name still has to resolve inside the skill directory — the README may point
# into it, never the other way.
DOCS := *.md skills/$(NAME)/*.md skills/$(NAME)/reference/*.md

check:
	@cd "$(REPO)" || exit 1; \
	fail=0; \
	misses=$$( \
		for f in $(DOCS); do \
			grep -ohE '`(reference/)?[A-Za-z][A-Za-z0-9._-]*\.md`' "$$f" | tr -d '`' | sort -u | while read -r ref; do \
				[ -f "$(SKILL)/$$ref" ] || [ -f "$(SKILL)/reference/$$ref" ] || echo "MISS $$f -> $$ref"; \
			done; \
		done); \
	if [ -n "$$misses" ]; then echo "$$misses" >&2; fail=1; fi; \
	for f in "$(SKILL)"/reference/*.md; do \
		[ -e "$$f" ] || continue; \
		b=$$(basename "$$f"); \
		grep -q "reference/$$b" "$(SKILL)/SKILL.md" || { echo "MISS reference/$$b exists but SKILL.md never names it" >&2; fail=1; }; \
	done; \
	if grep -nE '`[^`]*\.\./' $(DOCS) >&2; then \
		echo "MISS a cited path reaches through a parent directory" >&2; fail=1; \
	fi; \
	claimsrc=$$( cat $(DOCS); [ -f docs/index.html ] && sed 's/<[^>]*>/ /g' docs/index.html | tr -s ' ' ); \
	d=; \
	if [ -f "$(SKILL)/SKILL.md" ]; then \
		d=$$(awk '/^\| Dimension \| Question \|/{t=1;next} t&&/^\|---/{next} t&&/^\|/{c++;next} t{exit} END{print c+0}' "$(SKILL)/SKILL.md"); \
		dclaimed=$$(printf '%s' "$$claimsrc" | grep -oiE '(six|seven|eight|nine|ten)( [A-Za-z-]+)?[- ]dimension' | tr 'A-Z' 'a-z' | cut -d- -f1 | cut -d' ' -f1 | sort -u); \
		ddigits=$$(printf '%s' "$$claimsrc" | grep -oE '[0-9]+ gate dimensions' | grep -oE '[0-9]+' | sort -u); \
		if [ -z "$$dclaimed$$ddigits" ]; then \
			echo "MISS no Quality-Gate dimension-count claim found — this check has drifted from the prose" >&2; fail=1; \
		fi; \
		for c in $$dclaimed; do \
			case $$c in six) v=6;; seven) v=7;; eight) v=8;; nine) v=9;; ten) v=10;; *) v=0;; esac; \
			[ "$$v" = "$$d" ] || { echo "MISS gate-dimension count claims $$c ($$v), SKILL.md tabulates $$d" >&2; fail=1; }; \
		done; \
		for c in $$ddigits; do \
			[ "$$c" = "$$d" ] || { echo "MISS gate-dimension count claims $$c, SKILL.md tabulates $$d" >&2; fail=1; }; \
		done; \
	fi; \
	n=; \
	if [ -f "$(SKILL)/reference/roles.md" ]; then \
		n=$$(awk '/^### /{h=1;next} h&&/^\*\*Question/{c++;h=0} h&&NF{h=0} END{print c+0}' "$(SKILL)/reference/roles.md"); \
		claimed=$$(printf '%s' "$$claimsrc" | grep -oE '[0-9]+ analytical lenses|defines all [0-9]+' | grep -oE '[0-9]+' | sort -u); \
		if [ -z "$$claimed" ]; then \
			echo "MISS no lens-count claim found — this check has drifted from the prose" >&2; fail=1; \
		fi; \
		for c in $$claimed; do \
			[ "$$c" = "$$n" ] || { echo "MISS lens count claims $$c, reference/roles.md defines $$n" >&2; fail=1; }; \
		done; \
	fi; \
	for f in README.md docs/index.html; do \
		[ -f "$$f" ] || continue; \
		paths=$$(sed 's/<[^>]*>/ /g' "$$f" | grep -oE '(~|\$$HOME|\$$\{HOME\})/\.[A-Za-z0-9._/-]*[A-Za-z0-9_-]' | sed 's|^[^/]*/|~/|' | sort -u); \
		for p in $$paths; do \
			ok=; \
			for g in $(GLOBALS); do \
				case "$$p" in "$$g"|"$$g"/*) ok=1;; esac; \
				case "$$g" in "$$p"/*) ok=1;; esac; \
			done; \
			[ -n "$$ok" ] || { echo "MISS $$f documents $$p, which is not on any path make link writes" >&2; fail=1; }; \
		done; \
		for g in $(GLOBALS); do \
			printf '%s\n' "$$paths" | grep -qxF "$$g" || { echo "MISS $$f never documents $$g, where make link writes" >&2; fail=1; }; \
		done; \
	done; \
	if [ $$fail -eq 0 ]; then echo "self-contained: all references resolve inside $(SKILL), $$n lenses, $$d gate dimensions"; else exit 1; fi

# GitHub Pages serves docs/ as static files on `main`; this only previews the same tree locally,
# so what you see here is what the published site is.
pages:
	@echo "serving $(PAGES) at http://localhost:$(PAGES_PORT)/ — ctrl-c to stop"
	@python3 -m http.server $(PAGES_PORT) --directory "$(PAGES)"

# The check checks the skill; this checks the check.
test:
	@sh "$(REPO)/tools/check.sh"
