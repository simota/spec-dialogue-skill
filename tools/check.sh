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

# case <name> <ok|fail> <setup-shell-run-inside-the-copy> [indir|foreign]
case_() {
	name=$1
	want=$2
	setup=$3
	where=${4:-indir}

	d=$TMP/$(printf '%s' "$name" | tr -c 'a-zA-Z0-9' '_')
	rm -rf "$d"
	mkdir -p "$d/skills" || exit 1
	cp -R "$SRC/Makefile" "$SRC/README.md" "$SRC/docs" "$d/" || exit 1
	cp -R "$SRC/$SKILL" "$d/skills/" || exit 1

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
case_ 'gate count drifts in SKILL.md'    fail 'sed "s/seven dimensions/six dimensions/" $SKILL/SKILL.md > _ && mv _ $SKILL/SKILL.md'
case_ 'gate count drifts in a ref file'  fail 'printf "The six-dimension gate.\n" >> $SKILL/reference/doc-quality.md'
case_ 'gate count drifts, word between'  fail 'sed "s/seven Quality-Gate dimensions/six Quality-Gate dimensions/" $SKILL/reference/roles.md > _ && mv _ $SKILL/reference/roles.md'
case_ 'gate prose drifts from the check' fail 'for f in $SKILL/SKILL.md README.md $SKILL/reference/doc-quality.md $SKILL/reference/roles.md docs/index.html; do
                                                 sed -E "s/[Ss]even( [A-Za-z-]+)?[- ]dimension/the dimension/g; s/>7<\/b><span>gate dimensions/>7<\/b><span>gate axes/" "$f" > _ && mv _ "$f"
                                               done'
case_ 'an 8th dimension, prose stale'    fail 'awk "{print} /^\\| Resolvability \\|/{print \"| Fake | Does it? |\"}" $SKILL/SKILL.md > _ && mv _ $SKILL/SKILL.md'

# --- the published page drifts from what the skill defines --------------------
case_ 'lens count drifts in the page'    fail 'sed "s|>18</b><span>analytical lenses|>17</b><span>analytical lenses|" docs/index.html > _ && mv _ docs/index.html'
case_ 'gate count drifts in the page'    fail 'sed "s/seven-dimension/six-dimension/g" docs/index.html > _ && mv _ docs/index.html'
case_ 'gate digit drifts in the page'    fail 'sed "s|>7</b><span>gate dimensions|>9</b><span>gate dimensions|" docs/index.html > _ && mv _ docs/index.html'

# --- a non-lens heading must not inflate the count ----------------------------
case_ 'non-lens ### in roles.md'         ok   'printf "\n### Notes — not a lens\ntext\n" >> $SKILL/reference/roles.md'
case_ 'a 19th lens, prose not updated'   fail 'printf "\n### Fake — a lens\n**Question:** counts?\n" >> $SKILL/reference/roles.md'

printf '\n%s passed, %s failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
