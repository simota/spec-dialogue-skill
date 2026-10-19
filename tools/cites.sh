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
# - A code span opens on a run of backticks and closes on the next run of the same length, as
#   in CommonMark, so ``a `b` c`` is one span. A run with no partner is literal text.
# - A fence opens on ``` or ~~~ (three or more) and closes only on the same character, at least
#   as long, with nothing after it — a ~~~ line inside a ``` fence is content.
# - Code spans are read everywhere, fences included: the templates show real paths in fences.
# - Links are read outside fences and outside code spans only: there they are examples.
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
# spans(s): print every code span in s; return s with each span replaced by a space, so the text
# on either side cannot join into syntax that is not there — `[x]` + span + `(y)` is not a link.
function spans(s,    out, rest, p, n, body, closed, run) {
	out = ""
	while (match(s, /`+/)) {
		p = RSTART; n = RLENGTH
		out = out substr(s, 1, p - 1)
		rest = substr(s, p + n)
		body = ""; closed = 0
		while (match(rest, /`+/)) {
			run = RLENGTH
			if (run == n) {
				body = body substr(rest, 1, RSTART - 1)
				rest = substr(rest, RSTART + run)
				closed = 1
				break
			}
			body = body substr(rest, 1, RSTART + run - 1)
			rest = substr(rest, RSTART + run)
		}
		if (closed) {
			if (body ~ /^ .* $/ && body !~ /^ +$/) body = substr(body, 2, length(body) - 2)
			print FILENAME "|code|" body
			out = out " "
			s = rest
		} else {
			out = out substr(s, p, n)
			s = substr(s, p + n)
		}
	}
	return out s
}
FNR == 1 { fence = 0 }
{
	line = $0
	if (match(line, /^(   |  | )?(```+|~~~+)/)) {
		run = substr(line, RSTART, RLENGTH)
		sub(/^ +/, "", run)
		c = substr(run, 1, 1); n = length(run)
		tail = substr(line, RSTART + RLENGTH)
		if (!fence && !(c == "`" && tail ~ /`/)) { fence = 1; fc = c; fn = n; next }
		if (fence && c == fc && n >= fn && tail ~ /^[ \t]*$/) { fence = 0; next }
	}
	plain = spans(line)
	if (fence) next

	if (match(plain, /^(   |  | )?\[[^]]+\]:[ \t]*/)) {
		print FILENAME "|link|" dest(substr(plain, RSTART + RLENGTH))
		next
	}
	while (match(plain, /\]\([^)]*\)/)) {
		print FILENAME "|link|" dest(substr(plain, RSTART + 2, RLENGTH - 3))
		plain = substr(plain, RSTART + RLENGTH)
	}
}
' "$@"
