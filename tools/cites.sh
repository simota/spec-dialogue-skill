#!/bin/sh
# cites.sh FILE... — list the paths a Markdown document cites, one per line:
#
#   <file>|code|<text of an inline code span>
#   <file>|link|<destination of a Markdown link or link definition>
#
# `make check` reads this list for both of its path checks — that every cited `.md` resolves
# inside the skill, and that nothing cited reaches through `../` — so the two checks agree on
# what a citation is. Matching a whole line instead pairs the closing backtick of one span with
# the opening of the next, and reads a `../` in a link's title as part of its target.
#
# - Code spans are read everywhere, fences included: the templates show real paths in fences.
# - Links are read outside fences only: a link inside a fence is an example, not a citation.
# - A link destination drops what Markdown allows around it — `<…>`, a title — so what is
#   printed is the target alone; a `#fragment` or `?query` is left for the caller to strip.
#
# POSIX awk only (no intervals, no gawk extensions): it runs under mawk, BSD awk and gawk.

awk '
function dest(t) {
	sub(/^[ \t]+/, "", t)
	if (t ~ /^</) { t = substr(t, 2); sub(/>.*/, "", t) }
	else sub(/[ \t].*/, "", t)
	return t
}
FNR == 1 { fence = 0 }
/^(   |  | )?(```|~~~)/ { fence = !fence; next }
{
	s = $0
	while (match(s, /`[^`]*`/)) {
		print FILENAME "|code|" substr(s, RSTART + 1, RLENGTH - 2)
		s = substr(s, RSTART + RLENGTH)
	}
	if (fence) next

	s = $0
	gsub(/`[^`]*`/, "", s)
	if (match(s, /^(   |  | )?\[[^]]+\]:[ \t]*/)) {
		print FILENAME "|link|" dest(substr(s, RSTART + RLENGTH))
		next
	}
	while (match(s, /\]\([^)]*\)/)) {
		print FILENAME "|link|" dest(substr(s, RSTART + 2, RLENGTH - 3))
		s = substr(s, RSTART + RLENGTH)
	}
}
' "$@"
