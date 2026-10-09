#!/bin/sh
# Fixture battery for `make check`.
#
# `make check` is what backs this skill's self-containment premise, so the check itself needs
# a check: each case below mutates a throwaway copy of the tree and asserts the exit status.
# An edit to the check recipe that stops catching something fails here instead of passing quietly.
#
#   sh tools/check.sh
#
# Cases are named for what they inject. `want=ok` means the tree is clean and the check must
# pass; `want=fail` means the injected fault must be caught.

set -u

SRC=$(cd "$(dirname "$0")/.." && pwd)
SKILL=skills/spec-dialogue
TMP=$(mktemp -d "${TMPDIR:-/tmp}/spec-check.XXXXXX") || exit 1
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

# copy_ <name> — a throwaway copy of the tree, printed as a path. Every case mutates its own.
copy_() {
	d=$TMP/$(printf '%s' "$1" | tr -c 'a-zA-Z0-9' '_')
	rm -rf "$d"
	mkdir -p "$d/skills" || exit 1
	cp -R "$SRC/Makefile" "$SRC/README.md" "$SRC/docs" "$d/" || exit 1
	cp -R "$SRC/$SKILL" "$d/skills/" || exit 1
	printf '%s' "$d"
}

# case <name> <ok|fail> <setup-shell-run-inside-the-copy> [indir|foreign]
case_() {
	name=$1
	want=$2
	setup=$3
	where=${4:-indir}

	d=$(copy_ "$name")

	if [ -n "$setup" ]; then
		( cd "$d" && eval "$setup" ) || { printf 'SETUP  %s\n' "$name"; fail=$((fail + 1)); return; }
	fi

	if [ "$where" = foreign ]; then
		( cd / && make -f "$d/Makefile" check ) >/dev/null 2>&1
	else
		( cd "$d" && make check ) >/dev/null 2>&1
	fi
	got=$?

	if [ "$want" = ok ] && [ "$got" -eq 0 ]; then
		pass=$((pass + 1)); printf 'ok     %s\n' "$name"
	elif [ "$want" = fail ] && [ "$got" -ne 0 ]; then
		pass=$((pass + 1)); printf 'ok     %s\n' "$name"
	else
		fail=$((fail + 1)); printf 'FAIL   %s (want %s, exit %s)\n' "$name" "$want" "$got"
	fi
}

# --- the tree is clean -------------------------------------------------------
case_ 'clean tree'                       ok   ''
case_ 'clean tree, foreign cwd via -f'   ok   '' foreign

# --- a cited reference does not resolve --------------------------------------
case_ 'missing ref, lower-case name'     fail 'printf "See \`nonexistent-file.md\`.\n" >> $SKILL/SKILL.md'
case_ 'missing ref, capitalised name'    fail 'printf "See \`NOTREAL.md\`.\n" >> $SKILL/reference/roles.md'
case_ 'missing ref, new root .md'        fail 'printf "See \`nonexistent-file.md\`.\n" > CONTRIBUTING.md'
case_ 'missing ref, new .md in skill'    fail 'printf "See \`nonexistent-file.md\`.\n" > $SKILL/NOTES.md'
case_ 'reference dir deleted, foreign'   fail 'rm -rf $SKILL/reference' foreign
case_ 'roles.md deleted, foreign cwd'    fail 'rm $SKILL/reference/roles.md' foreign

# --- a reference file exists that SKILL.md never names ------------------------
case_ 'orphan file in reference/'        fail 'printf "# Orphan\n" > $SKILL/reference/orphan.md'
case_ 'orphan named by SKILL.md only'    ok   'printf "# Orphan\n" > $SKILL/reference/orphan.md
                                              printf "See \`reference/orphan.md\`.\n" >> $SKILL/SKILL.md'

# --- something points at a parent --------------------------------------------
case_ 'parent ref in SKILL.md'           fail 'printf "See \`../escape.md\`.\n" >> $SKILL/SKILL.md'
case_ 'parent ref in README.md'          fail 'printf "See \`../escape.md\`.\n" >> README.md'
case_ 'parent ref in new root .md'       fail 'printf "See \`../escape.md\`.\n" > CONTRIBUTING.md'

# --- a relative path in an install example is not a parent reference ----------
case_ 'relative PROJECT= in a fence'     ok   'printf "\n\`\`\`sh\nmake link PROJECT=../sibling-repo\n\`\`\`\n" >> README.md'

# --- the lens count drifts from what roles.md defines -------------------------
case_ 'lens count drifts in README.md'   fail 'sed "s/defines all 18/defines all 17/" README.md > _ && mv _ README.md'
case_ 'lens count drifts in a ref file'  fail 'printf "The 17 analytical lenses.\n" >> $SKILL/reference/doc-quality.md'
case_ 'prose drifts from the check'      fail 'for f in $SKILL/SKILL.md README.md $SKILL/reference/roles.md docs/index.html; do
                                                 sed "s/analytical lenses/lenses/g; s/defines all 18/defines them/" "$f" > _ && mv _ "$f"
                                               done'

# --- the Quality-Gate dimension count drifts from the table -------------------
case_ 'gate count drifts in SKILL.md'    fail 'sed "s/eight dimensions/six dimensions/" $SKILL/SKILL.md > _ && mv _ $SKILL/SKILL.md'
case_ 'gate count drifts in a ref file'  fail 'printf "The six-dimension gate.\n" >> $SKILL/reference/doc-quality.md'
case_ 'gate count drifts, word between'  fail 'sed "s/eight Quality-Gate dimensions/six Quality-Gate dimensions/" $SKILL/reference/roles.md > _ && mv _ $SKILL/reference/roles.md'
case_ 'gate prose drifts from the check' fail 'for f in $SKILL/SKILL.md README.md $SKILL/reference/doc-quality.md $SKILL/reference/roles.md docs/index.html; do
                                                 sed -E "s/[Ee]ight( [A-Za-z-]+)?[- ]dimension/the dimension/g; s/>8<\/b><span>gate dimensions/>8<\/b><span>gate axes/" "$f" > _ && mv _ "$f"
                                               done'
case_ 'a 9th dimension, prose stale'    fail 'awk "{print} /^\\| Resolvability \\|/{print \"| Fake | Does it? |\"}" $SKILL/SKILL.md > _ && mv _ $SKILL/SKILL.md'

# --- the published page drifts from what the skill defines --------------------
case_ 'lens count drifts in the page'    fail 'sed "s|>18</b><span>analytical lenses|>17</b><span>analytical lenses|" docs/index.html > _ && mv _ docs/index.html'
case_ 'gate count drifts in the page'    fail 'sed "s/eight-dimension/six-dimension/g" docs/index.html > _ && mv _ docs/index.html'
case_ 'gate digit drifts in the page'    fail 'sed "s|>8</b><span>gate dimensions|>9</b><span>gate dimensions|" docs/index.html > _ && mv _ docs/index.html'

# --- the install table drifts from where `make link` writes -------------------
case_ 'stale agy path in README.md'      fail 'sed "s|~/.gemini/antigravity-cli/skills|~/.gemini/config/skills|" README.md > _ && mv _ README.md'
case_ 'stale agy path in the page'       fail 'sed "s|~/.gemini/antigravity-cli/skills|~/.gemini/config/skills|" docs/index.html > _ && mv _ docs/index.html'
case_ 'install row dropped from README'  fail 'grep -v "^| \`claude\` |" README.md > _ && mv _ README.md'
case_ 'stale CLI home in README prose'   fail 'sed "s|conjure \`~/.gemini/antigravity-cli\`|conjure \`~/.gemini/config\`|" README.md > _ && mv _ README.md'
case_ 'stale \$HOME-form path in README' fail 'printf "Or copy it into \`\$HOME/.gemini/config/skills\`.\n" >> README.md'
case_ 'a path inside a skills dir is ok'  ok   'printf "It lands at \`~/.claude/skills/spec-dialogue\`.\n" >> README.md'
case_ 'stale $CODEX_HOME path in README' fail 'sed "s|\`\$CODEX_HOME/skills\`|\`\$CODEX_HOME/plugins\`|" README.md > _ && mv _ README.md'
case_ 'stale $CODEX_HOME path in page'   fail 'sed "s|<code>\$CODEX_HOME/skills</code>|<code>\$CODEX_HOME/plugins</code>|" docs/index.html > _ && mv _ docs/index.html'
case_ 'SKILLS_DIR= example is allowed'   ok   'printf "\n\`\`\`sh\nmake link SKILLS_DIR=~/.config/agents/skills\n\`\`\`\n" >> README.md'
case_ 'Makefile moves agy, docs stale'   fail 'sed "s|^GLOBAL_agy    := .*|GLOBAL_agy    := .gemini/elsewhere/skills|" Makefile > _ && mv _ Makefile'

# --- a non-lens heading must not inflate the count ----------------------------
case_ 'non-lens ### in roles.md'         ok   'printf "\n### Notes — not a lens\ntext\n" >> $SKILL/reference/roles.md'
case_ 'a 19th lens, prose not updated'   fail 'printf "\n### Fake — a lens\n**Question:** counts?\n" >> $SKILL/reference/roles.md'

# --- `make link` places the skill where each CLI actually reads it ------------
#
# The three CLIs look in three different directories, and a link recipe is exactly the kind of
# thing that is never watched failing: it either wrote a symlink somewhere or it did not. Each
# case below runs the real recipe against a throwaway HOME and then asserts the tree it left —
# a recipe that quietly links nothing, or links into a CLI that is not installed, fails here.
#
# Default fixture: claude and codex are installed (their home directories exist), agy is not.

# link_case <name> <ok|fail> <make-args> <assertion> [<setup>]
#   The assertion runs inside the copy with $H as the fake home and $S as the skill it should
#   point at; a non-zero exit fails the case even when make itself exited as expected.
link_case_() {
	name=$1
	want=$2
	margs=$3
	assert=$4
	setup=${5:-}

	d=$(copy_ "link_$name")
	H=$d/home
	mkdir -p "$H/.claude" "$H/.codex" || exit 1
	# make resolves its own directory physically, so the link it writes names the physical path.
	# Comparing against `$d` would fail on any machine where the scratch tree sits under a
	# symlink — /tmp on macOS, for one — for a reason that has nothing to do with the recipe.
	S=$(cd "$d/$SKILL" && pwd -P)

	if [ -n "$setup" ]; then
		( cd "$d" && H=$H S=$S eval "$setup" ) || { printf 'SETUP  %s\n' "$name"; fail=$((fail + 1)); return; }
	fi

	( cd "$d" && make HOME="$H" CODEX_HOME="$H/.codex" $margs ) >/dev/null 2>&1
	got=$?

	if [ "$want" = ok ] && [ "$got" -ne 0 ]; then
		fail=$((fail + 1)); printf 'FAIL   link: %s (make exited %s, want 0)\n' "$name" "$got"; return
	fi
	if [ "$want" = fail ] && [ "$got" -eq 0 ]; then
		fail=$((fail + 1)); printf 'FAIL   link: %s (make exited 0, want non-zero)\n' "$name"; return
	fi

	if ( cd "$d" && H=$H S=$S eval "$assert" ); then
		pass=$((pass + 1)); printf 'ok     link: %s\n' "$name"
	else
		fail=$((fail + 1)); printf 'FAIL   link: %s (make exited %s as expected, tree is wrong)\n' "$name" "$got"
	fi
}

link_case_ 'installed CLIs get a link'   ok   'link' \
	'[ "$(readlink "$H/.claude/skills/spec-dialogue")" = "$S" ] &&
	 [ "$(readlink "$H/.codex/skills/spec-dialogue")" = "$S" ]'

link_case_ 'an absent CLI is skipped'    ok   'link' \
	'[ ! -e "$H/.gemini" ]'

link_case_ 'agy installed, agy linked'   ok   'link' \
	'[ "$(readlink "$H/.gemini/antigravity-cli/skills/spec-dialogue")" = "$S" ]' \
	'mkdir -p "$H/.gemini/antigravity-cli"'

link_case_ 'no CLI installed at all'     fail 'link' \
	'[ ! -e "$H/.claude/skills" ]' \
	'rm -rf "$H/.claude" "$H/.codex"'

link_case_ 'linking twice is idempotent' ok   'link' \
	'[ "$(readlink "$H/.claude/skills/spec-dialogue")" = "$S" ]' \
	'make HOME="$H" CODEX_HOME="$H/.codex" link >/dev/null 2>&1'

link_case_ 'a foreign link is refused'   fail 'link' \
	'[ "$(readlink "$H/.codex/skills/spec-dialogue")" = /elsewhere ]' \
	'mkdir -p "$H/.codex/skills" && ln -s /elsewhere "$H/.codex/skills/spec-dialogue"'

link_case_ 'a real directory is refused' fail 'link' \
	'[ -f "$H/.codex/skills/spec-dialogue/keep-me" ]' \
	'mkdir -p "$H/.codex/skills/spec-dialogue" && : > "$H/.codex/skills/spec-dialogue/keep-me"'

link_case_ 'AGENT= links only that one'  ok   'link AGENT=codex' \
	'[ -L "$H/.codex/skills/spec-dialogue" ] && [ ! -e "$H/.claude/skills/spec-dialogue" ]'

link_case_ 'an unknown AGENT stops'      fail 'link AGENT=nope' \
	'[ ! -e "$H/.claude/skills/spec-dialogue" ]'

# codex and agy both read `<repo>/.agents/skills`, so a project link is two directories, not three.
link_case_ 'PROJECT= links the repo'     ok   'link PROJECT=proj' \
	'[ "$(readlink proj/.claude/skills/spec-dialogue)" = "$S" ] &&
	 [ "$(readlink proj/.agents/skills/spec-dialogue)" = "$S" ] &&
	 [ ! -e "$H/.claude/skills/spec-dialogue" ]' \
	'mkdir -p proj'

link_case_ 'SKILLS_DIR= overrides all'   ok   'link SKILLS_DIR=elsewhere/skills' \
	'[ "$(readlink elsewhere/skills/spec-dialogue)" = "$S" ] &&
	 [ ! -e "$H/.claude/skills/spec-dialogue" ]'

link_case_ 'unlink removes only ours'    ok   'unlink' \
	'[ ! -e "$H/.claude/skills/spec-dialogue" ] &&
	 [ "$(readlink "$H/.gemini/antigravity-cli/skills/spec-dialogue")" = /elsewhere ]' \
	'make HOME="$H" CODEX_HOME="$H/.codex" link >/dev/null 2>&1
	 mkdir -p "$H/.gemini/antigravity-cli/skills" && ln -s /elsewhere "$H/.gemini/antigravity-cli/skills/spec-dialogue"'


printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
