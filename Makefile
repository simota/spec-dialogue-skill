# spec-dialogue — install by symlink
#
#   make link                     link into ~/.claude/skills/spec-dialogue
#   make link PROJECT=/path/repo  link into /path/repo/.claude/skills/spec-dialogue
#   make unlink                   remove the link (same PROJECT rule)
#   make status                   show where it is linked from
#
# The skill itself is `skills/spec-dialogue/` — that directory, not the repository root, is
# what gets linked, so the repo can carry a README and a test battery the skill does not ship.
#
# SKILLS_DIR overrides the destination directory outright:
#   make link SKILLS_DIR=~/.config/agents/skills

NAME    := spec-dialogue
REPO    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
SKILL   := $(REPO)/skills/$(NAME)
PROJECT ?=
PAGES    := $(REPO)/docs
PAGES_PORT ?= 8000

ifeq ($(strip $(PROJECT)),)
SKILLS_DIR ?= $(HOME)/.claude/skills
else
SKILLS_DIR ?= $(abspath $(PROJECT))/.claude/skills
endif

DEST := $(SKILLS_DIR)/$(NAME)

.PHONY: help link unlink status check test pages

help:
	@echo "make link      [PROJECT=<repo>] [SKILLS_DIR=<dir>]  symlink $(NAME) into a skills directory"
	@echo "make unlink    [PROJECT=<repo>] [SKILLS_DIR=<dir>]  remove that symlink"
	@echo "make status    [PROJECT=<repo>] [SKILLS_DIR=<dir>]  report the current link"
	@echo "make check                                          verify this skill is self-contained"
	@echo "make test                                           run the fixture battery over make check"
	@echo ""
	@echo "make pages                                          preview the docs/ site (PAGES_PORT=$(PAGES_PORT))"
	@echo ""
	@echo "repo:   $(REPO)"
	@echo "skill:  $(SKILL)"
	@echo "dest:   $(DEST)"

link:
	@set -e; \
	if [ -e "$(DEST)" ] && [ ! -L "$(DEST)" ]; then \
		echo "refusing: $(DEST) exists and is not a symlink — move it aside first"; exit 1; \
	fi; \
	if [ -L "$(DEST)" ] && [ "$$(readlink "$(DEST)")" = "$(SKILL)" ]; then \
		echo "already linked: $(DEST) -> $(SKILL)"; exit 0; \
	fi; \
	mkdir -p "$(SKILLS_DIR)"; \
	if [ -L "$(DEST)" ]; then \
		echo "replacing existing link ($$(readlink "$(DEST)"))"; rm "$(DEST)"; \
	fi; \
	ln -s "$(SKILL)" "$(DEST)"; \
	echo "linked: $(DEST) -> $(SKILL)"; \
	echo "invoke it with:  spec-dialogue   (or /spec-dialogue in a slash-command harness)"

unlink:
	@if [ -L "$(DEST)" ]; then \
		rm "$(DEST)"; echo "unlinked: $(DEST)"; \
	elif [ -e "$(DEST)" ]; then \
		echo "refusing: $(DEST) is not a symlink — leaving it alone"; exit 1; \
	else \
		echo "nothing to unlink at $(DEST)"; \
	fi

status:
	@if [ -L "$(DEST)" ]; then echo "linked: $(DEST) -> $$(readlink "$(DEST)")"; \
	elif [ -e "$(DEST)" ]; then echo "present but not a symlink: $(DEST)"; \
	else echo "not linked: $(DEST)"; fi

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
	if [ $$fail -eq 0 ]; then echo "self-contained: all references resolve inside $(SKILL), $$n lenses, $$d gate dimensions"; else exit 1; fi

# GitHub Pages serves docs/ as static files on `main`; this only previews the same tree locally,
# so what you see here is what the published site is.
pages:
	@echo "serving $(PAGES) at http://localhost:$(PAGES_PORT)/ — ctrl-c to stop"
	@python3 -m http.server $(PAGES_PORT) --directory "$(PAGES)"

# The check checks the skill; this checks the check.
test:
	@sh "$(REPO)/tools/check.sh"
