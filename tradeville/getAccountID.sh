#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

if isLoggedIn
then

info=$(grep -m 1 Login_lblHomeNume "$OUT_HOME" | sed 's/.*(\(.*\)).*/\1/')

if [ -n "$info" ]
then
  msg="$info"
  ret_code=0
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code

fi
