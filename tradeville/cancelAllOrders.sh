#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=0
HELPME_TXT="[<shareSymbol>]
Cancel all orders (if no share symbol is supplied)"
helpMe $@

if isLoggedIn
then

info=$(my_curl "$MY_URL/ashx/ordine.ashx?hdlr=da" --data "somefakename=&anotherfakename=&hdlr=da&meniu=&anulare=da&comanda=DA&einpagregare=&simbao=$1&bdaa=DA&bnua=NU&timeStamp=$(date '+%s')" -o $OUT_TMP)
ret_code=$?
exitOnError $ret_code "$info"


if [ $(grep -c 'class="nusuntdate"' $OUT_TMP) -eq 1 ]
then
  msg="SUCCESS"
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code

fi
