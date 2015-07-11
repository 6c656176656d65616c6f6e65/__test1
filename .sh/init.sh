#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" == "${BASH_SOURCE[1]}" ]] && return 0 
# usage: . repo/.sh/init.sh
[ ${#BASH_SOURCE[@]} == 1 ] && echo "usage: . ${BASH_SOURCE[0]//~/\~}" && exit 1
# . /full/path/to/init.sh
[[ ${BASH_SOURCE[0]} != /* ]] && echo "ERROR: . ${BASH_SOURCE[0]}
usage: . ${PWD/~/\~}/${BASH_SOURCE[0]}" && exit
[[ $SHELL == *.sh ]] && echo "ERROR: \$SHELL=$SHELL. bash required" && exit 1

IFS=
[ -e ~/.shrc ] && . ~/.shrc || echo "ERROR: . ~/.shrc, \$? = $exit" 1>&2

# $1 - BASH_SOURCE tree
set "$(printf -- '%s\n' ${BASH_SOURCE[@]})" "$@"
set "$(echo $1 | grep -v ^\\.)" "${@:2}" # exclude relative, .git/hooks/pre-commit
set "$(echo $1 | while read l; do # paths Tree
	while [[ $l == ${BASH_SOURCE[0]%/*/*}/* ]]; do l="${l%/*}";[[ -n $l ]] && echo $l; done
done | sort | uniq)" "${@:2}"
# $2 - sh/, .sh/ folders
set "$1" "$(echo "${BASH_SOURCE[0]%/*}"; echo $1 | while read l; do
	[ -e "$l"/sh ] && echo "$l"/sh # sh/
	[[ $l != "${BASH_SOURCE[0]%/*/*}"/.sh ]] && [ -e "$l"/.sh ] && echo "$l"/.sh # .sh/ only for this repo
done | grep -v "${BASH_SOURCE[0]%/*/*}"/.sh)" "${@:2}"
set "$(eval "find '$(echo $2 | awk 1 ORS="' '" | sed 's/...$//')' -name '*.sh' -type f;
find '$(echo $1 | awk 1 ORS="' '" | sed 's/...$//')' -name config.sh -type f -maxdepth 1")" "${@:2}"
eval "shift 2;while IFS= read f; do
	. \"\$f\" || { echo \"ERROR, \${BASH_SOURCE[0]/\$HOME/\~}:
. \${f/\$HOME/\~}, \\\$? = \$?\" 1>&2; return 1; }
done <<< '$1'"
