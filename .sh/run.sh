#!/usr/bin/env bash
# sh:init
{ set +x; } 2>/dev/null

# . path/to/this/sh.run.sh
[ ${#BASH_SOURCE[@]} == 1 ] && echo "usage: . ${BASH_SOURCE[0]//~/\~}" && exit
[[ ${BASH_SOURCE[0]} != /* ]] && echo "ERROR: . ${BASH_SOURCE[0]}
usage: . ${PWD/~/\~}/${BASH_SOURCE[0]}" && exit
[[ "${BASH_SOURCE[0]%/*}" == "${BASH_SOURCE[1]%/*}" ]] && return 0

if ! [ -e "${BASH_SOURCE[0]%/*}"/init.sh ]; then
	echo "ERROR: ${BASH_SOURCE[0]%/*}/init.sh NOT EXISTS" && return 1
fi
. "${BASH_SOURCE[0]%/*}"/init.sh "$@" || return $?
type sh.main &> /dev/null
if [[ $? != 0 ]]; then 
	echo "ERROR: ${BASH_SOURCE[0]/$HOME/\~}: 
function sh.main() { ... } not found in:"
	SOURCE="$(echo "${BASH_SOURCE[@]:1}" | tr ' /' '\n/' | grep -v "${BASH_SOURCE[0]%/*}" | head -1)"
	echo "${BASH_SOURCE[0]%/*}"
	while [[ -n $SOURCE ]]; do
		[ -d "$SOURCE"/sh ] && echo ${SOURCE//$HOME/\~}/sh
		[[ "$SOURCE" != "${BASH_SOURCE[0]%/*/*}"/* ]] && break
		SOURCE="${SOURCE%/*}";
	done
	echo
	unset SOURCE
	return 1
fi
if [ -p /dev/stdin ]; then
	cat - | sh.main "$@"
else
	sh.main "$@"
fi
exit=$?
unset -f sh.main
eval "unset exit; return $exit"

