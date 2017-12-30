#!/usr/bin/env bash

if [ $# -lt 2 ]
then
  cat << EOF
Usage: $(basename $0) <command> <trade>
Running the specified command (if exists) after initialization of the trade configuration
EOF
  exit 1
fi

myCMD=$1
shift

myCNF=$1
shift

. "$(dirname $0)/../$myCNF.conf" || exit 1


availableCMD=$(typeset -F | grep "[[:space:]]-fx[[:space:]]" | awk '{print "\t"$NF}' | sort)

if [ -z "$myCMD" -o $(echo -e "$availableCMD" | grep -c "[[:space:]]$myCMD$") -eq 0 ]
then
  echo "Available commands:"
  echo -e "$availableCMD"
  exit 1
fi

$myCMD $@
