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
# pass; `want=fail` means the injected fault must be caught — by the check itself, so the run
# must print a `MISS` line: a syntax error or a missing file also exits non-zero, and is not a
# catch. A case with a setup must also leave its copy different from the clean tree, so a
# mutation that silently matched nothing cannot pass for either verdict.

set -u

# The battery drives make itself; a caller's `make test AGENT=codex` or an exported PROJECT
# would otherwise leak into every nested make and retarget the links the cases assert on.
unset MAKEFLAGS MAKELEVEL MFLAGS AGENT PROJECT SKILLS_DIR CODEX_HOME

SRC=$(cd "$(dirname "$0")/.." && pwd)
SKILL=skills/spec-dialogue
TMP=$(mktemp -d "${TMPDIR:-/tmp}/spec-check.XXXXXX") || exit 1
trap 'rm -rf "$TMP"' EXIT

pass=0
fail=0

# copy_ <dir> — a throwaway copy of the tree at <dir>. Every case mutates its own.
#
# It sets nothing and prints nothing: the caller passes the directory and checks the status.
# A copy that cannot be made stops the whole battery, because every setup below is a mutation
# meant for a copy — `rm -rf $SKILL/reference`, `sed … > _ && mv` — and run anywhere else it
# would be run on the real tree.
copy_() {
	rm -rf "$1" &&
	mkdir -p "$1/skills" &&
	cp -R "$SRC/Makefile" "$SRC/README.md" "$SRC/docs" "$1/" &&
	mkdir -p "$1/tools" && cp "$SRC/tools/cites.sh" "$1/tools/" &&
	cp -R "$SRC/$SKILL" "$1/skills/" &&
	[ -f "$1/Makefile" ] && [ -f "$1/tools/cites.sh" ] && [ -d "$1/$SKILL" ] || {
		printf 'ABORT  could not build a fixture copy at %s — stopping before any setup runs\n' "$1" >&2
		exit 2
	}
}

# fixture_ <name> — sets $d to a fresh copy for the case <name>.
fixture_() {
	d=$TMP/$(printf '%s' "$1" | tr -c 'a-zA-Z0-9' '_')
	copy_ "$d"
}

# changed_ — true when the copy at $d differs from the clean tree.
CLEAN=$TMP/_clean
copy_ "$CLEAN"
changed_() {
	! diff -r "$CLEAN" "$d" >/dev/null 2>&1
}

# case <name> <ok|fail> <setup-shell-run-inside-the-copy> [indir|foreign]
case_() {
	name=$1
	want=$2
	setup=$3
	where=${4:-indir}

	fixture_ "$name"

	if [ -n "$setup" ]; then
		( cd "$d" && eval "$setup" ) || { printf 'SETUP  %s\n' "$name"; fail=$((fail + 1)); return; }
		changed_ || { printf 'FAIL   %s (setup left the tree unchanged)\n' "$name"; fail=$((fail + 1)); return; }
	fi

	err=$TMP/stderr
	if [ "$where" = foreign ]; then
		( cd / && make -f "$d/Makefile" check ) >/dev/null 2>"$err"
	else
		( cd "$d" && make check ) >/dev/null 2>"$err"
	fi
	got=$?

	if [ "$want" = ok ] && [ "$got" -eq 0 ]; then
		pass=$((pass + 1)); printf 'ok     %s\n' "$name"
	elif [ "$want" = fail ] && [ "$got" -ne 0 ] && grep -q '^MISS ' "$err"; then
		pass=$((pass + 1)); printf 'ok     %s\n' "$name"
	elif [ "$want" = fail ] && [ "$got" -ne 0 ]; then
		fail=$((fail + 1)); printf 'FAIL   %s (exit %s, but no MISS — the check did not catch it)\n' "$name" "$got"
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

# --- a scan must not read outside what it claims to read ----------------------
case_ 'a word ending in -ten is no count' ok   'printf "Weigh the written dimension too.\n" >> $SKILL/SKILL.md'
case_ 'gate count drifts to five'        fail 'sed "s/eight dimensions/five dimensions/" $SKILL/SKILL.md > _ && mv _ $SKILL/SKILL.md'
case_ 'missing ref via markdown link'    fail 'printf "See [roles](reference/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'missing ref, link with #fragment' fail 'printf "See [d](reference/does-not-exist.md#details).\n" >> $SKILL/SKILL.md'
case_ 'good ref, link with #fragment'    ok   'printf "See [r](reference/roles.md#demand).\n" >> $SKILL/SKILL.md'
case_ 'missing ref, link with a title'   fail 'printf "See [d](reference/does-not-exist.md \"Details\").\n" >> $SKILL/SKILL.md'
case_ 'missing ref, angle-bracket link'  fail 'printf "See [d](<reference/does-not-exist.md>).\n" >> $SKILL/SKILL.md'
case_ 'good ref, link with title + frag' ok   'printf "See [r](reference/roles.md#demand \"Roles\").\n" >> $SKILL/SKILL.md'
case_ 'missing ref, code span + #frag'  fail 'printf "See \`reference/missing.md#frag\`.\n" >> $SKILL/SKILL.md'
case_ 'good ref, code span + #frag'     ok   'printf "See \`reference/roles.md#demand\`.\n" >> $SKILL/SKILL.md'
case_ 'missing ref, reference-style link' fail 'printf "See [x][id].\n\n[id]: reference/missing.md\n" >> $SKILL/SKILL.md'
case_ 'missing ref, ./ link'             fail 'printf "See [x](./reference/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'absolute .md link escapes'        fail 'printf "See [x](/etc/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'missing ref, spaced link target'  fail 'printf "See [x]( reference/missing.md ).\n" >> $SKILL/SKILL.md'
case_ 'good ref, ./ link'                ok   'printf "See [x](./reference/roles.md).\n" >> $SKILL/SKILL.md'
case_ 'a URL ending in .md is not local' ok   'printf "See [x](https://example.com/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'an example link in a fence'       ok   'printf "\n\`\`\`markdown\n[x](reference/example.md)\n\`\`\`\n" >> $SKILL/SKILL.md'
case_ 'missing ref, double-backtick span' fail 'printf "See \`\`reference/missing.md\`\`.\n" >> $SKILL/SKILL.md'
case_ 'a link shown in a double-backtick span' ok 'printf "Write \`\` [x](reference/missing.md) \`\` literally.\n" >> $SKILL/SKILL.md'
case_ 'a ~~~ line inside a backtick fence' fail 'printf "\n\`\`\`\n~~~\n\`\`\`\n\nSee [x](reference/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'a longer fence holds a shorter one' fail 'printf "\n\`\`\`\`\n\`\`\`\n\`\`\`\`\n\nSee [x](reference/missing.md).\n" >> $SKILL/SKILL.md'
case_ 'a span between [x] and (y) is no link' ok 'printf "See [label]\`code\`(reference/missing.md) as prose.\n" >> $SKILL/SKILL.md'
case_ 'a span inside link text still links' fail 'printf "See [a \`b\` c](reference/missing.md).\n" >> $SKILL/SKILL.md'
case_ '../ mid-way through a code span'  fail 'printf "Run \`make link PROJECT=../sibling\`.\n" >> $SKILL/SKILL.md'
case_ '../ only in a link title'         ok   'printf "See [x](reference/roles.md \"see ../notes\").\n" >> $SKILL/SKILL.md'
case_ '../ between two code spans'       ok   'printf "See \`a\` then ../ then \`b\`.\n" >> $SKILL/SKILL.md'
case_ 'parent ref via markdown link'     fail 'printf "See [up](../escape.md).\n" >> $SKILL/SKILL.md'
case_ 'a ../ outside any code span'      ok   'printf "Run \`make link\` from the repo, or ../ it.\n" >> README.md'
case_ 'a path inside $CODEX_HOME/skills' ok   'printf "It lands at \`\$CODEX_HOME/skills/spec-dialogue\`.\n" >> README.md'

# --- the page's figures follow the colour theme -------------------------------
case_ 'single-quoted hex in a page SVG'  fail 'sed "s|style=\"fill:var(--gate)\"|fill='"'"'#9E3B26'"'"'|" docs/index.html > _ && mv _ docs/index.html'
case_ 'hex inside an SVG style attr'     fail 'sed "s|style=\"fill:var(--gate)\"|style=\"fill:#9E3B26\"|" docs/index.html > _ && mv _ docs/index.html'
case_ 'fixed hex colour in a page SVG'   fail 'sed "s|style=\"fill:var(--gate)\"|fill=\"#9E3B26\"|" docs/index.html > _ && cmp -s _ docs/index.html && exit 1; mv _ docs/index.html'

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

	fixture_ "link_$name"
	H=$d/home
	mkdir -p "$H/.claude" "$H/.codex" || exit 2
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


# cmd_case <name> <ok|fail> <command> <assertion>
#   For what link_case_ cannot express — a caller's environment, or a path make cannot carry.
#   Both run inside a fresh copy with $H as a fake home and $S as the skill's physical path.
cmd_case_() {
	name=$1; want=$2; cmd=$3; assert=$4
	fixture_ "cmd_$name"
	H=$d/home
	mkdir -p "$H/.claude" "$H/.codex" || exit 2
	S=$(cd "$d/$SKILL" && pwd -P)
	( cd "$d" && H=$H S=$S eval "$cmd" ) >/dev/null 2>&1
	got=$?
	if { [ "$want" = ok ] && [ "$got" -ne 0 ]; } || { [ "$want" = fail ] && [ "$got" -eq 0 ]; }; then
		fail=$((fail + 1)); printf 'FAIL   cmd: %s (exit %s, want %s)\n' "$name" "$got" "$want"; return
	fi
	if ( cd "$d" && H=$H S=$S eval "$assert" ); then
		pass=$((pass + 1)); printf 'ok     cmd: %s\n' "$name"
	else
		fail=$((fail + 1)); printf 'FAIL   cmd: %s (exit %s as expected, tree is wrong)\n' "$name" "$got"
	fi
}

# An exported PROJECT is an everyday shell variable; only `make link PROJECT=…` may retarget.
cmd_case_ 'an exported PROJECT is ignored'   ok \
	'mkdir -p proj && PROJECT=proj make HOME="$H" CODEX_HOME="$H/.codex" link' \
	'[ -L "$H/.claude/skills/spec-dialogue" ] && [ ! -e proj/.claude ]'

cmd_case_ 'an exported AGENT is ignored'     ok \
	'AGENT=codex make HOME="$H" CODEX_HOME="$H/.codex" link' \
	'[ -L "$H/.claude/skills/spec-dialogue" ] && [ -L "$H/.codex/skills/spec-dialogue" ]'

# A spaced path to some *other* checkout must not be shortened to its last word and used.
cmd_case_ 'a spaced -f path never retargets'  fail \
	'cp -R "$PWD" ../src_$$ && mkdir -p x "sib x" && cp -R ../src_$$ x/repo && cp -R ../src_$$ "sib x/repo" &&
	 make -f "sib x/repo/Makefile" HOME="$H" AGENT=claude link' \
	'[ -z "$(find "$H" -name spec-dialogue)" ]'

# help needs no destination, so a spaced HOME must not stop it.
cmd_case_ 'help works under a spaced HOME'    ok \
	'make HOME="$H/sp ace" help' \
	'true'

# A link written through another path to this same checkout is still ours.
cmd_case_ 'a link via an alias path is ours' ok \
	'ln -s "$PWD" ../alias_$$ && make -f "../alias_$$/Makefile" HOME="$H" CODEX_HOME="$H/.codex" AGENT=claude link &&
	 make HOME="$H" CODEX_HOME="$H/.codex" AGENT=claude link &&
	 make HOME="$H" CODEX_HOME="$H/.codex" AGENT=claude unlink' \
	'[ ! -e "$H/.claude/skills/spec-dialogue" ] && [ ! -L "$H/.claude/skills/spec-dialogue" ]'

# make splits words on spaces; a spaced HOME must stop, never half-link into a sibling.
cmd_case_ 'a HOME with a space stops'        fail \
	'mkdir -p "$H/sp ace/.claude" "$H/sp" && make HOME="$H/sp ace" AGENT=claude link' \
	'[ ! -e "$H/sp/.claude" ] && [ -z "$(find "$H" -name spec-dialogue)" ]'

cmd_case_ 'a repo path with a space stops'   fail \
	'mkdir -p "../sp ace_$$" && cp -R . "../sp ace_$$/r" && cd / && make -f "$OLDPWD/../sp ace_$$/r/Makefile" HOME="$H" AGENT=claude link' \
	'[ -z "$(find "$H" -name spec-dialogue)" ]'

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
