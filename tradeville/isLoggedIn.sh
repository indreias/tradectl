#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

info=$(my_curl "$MY_URL/Trading/Home/Home.aspx" -o "$OUT_HOME")
ret_code=$?
exitOnError $ret_code "$info"

if [ $(grep -c "Login_lblHomeNume" "$OUT_HOME") -eq 1 ]
then
  msg="SUCCESS"
  ret_code=0
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code
