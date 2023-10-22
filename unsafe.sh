#!/bin/sh

# ANSI escape codes can have unintended and potentailly dangerous consequences, including unintented
# command execution. This file is designed to reduce that risk.

# Replace any \e characters with $ESCAPECHAR.
unsafe() {
	"$@" | /usr/bin/sed "s/$(printf "\e")/$(printf "%s" "${ESCAPECHAR-⎋}" | /usr/bin/sed 's/\//\\\//g')/g"
}

# Apply unsafe, but only if stdout is a tty.
term_unsafe() {
	if [ -t 1 ]; then
		unsafe "$@"
	else
		"$@"
	fi
}


# Apply unsafe by default to some commands

# Unsafe means no color
alias grep='term_unsafe grep --color=never'
alias cat='term_unsafe cat'
alias sed='term_unsafe sed'
alias tee='term_unsafe tee'

# If curl is installed
if command -v curl > /dev/null; then
	# The -s means silent, which turns off error messages and the progress bar. -S turns error
	# messages back on.
	alias curl='term_unsafe curl -s -S'
fi

# If jq is installed
if JQ_LOCATION="$(command -v jq)"; then
	# jq should be `term_unsafe` only if its output is raw or joined.
	alias jq='_jq'
	_jq() {
		use_unsafe=0
		for opt in "$@"; do
			case "$opt" in
				-r|--raw-output|-j|--join-output)
					use_unsafe=1
					;;
				*)
					;;
			esac
		done
		if [ "$use_unsafe" -eq 1 ]; then
			term_unsafe "$JQ_LOCATION" "$@"
		else
			"$JQ_LOCATION" "$@"
		fi
	}
fi

