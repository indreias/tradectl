#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=1
HELPME_TXT="<orderID>
Cancel the specified order
Note: password will be read from terminal if not present into the .conf file"
helpMe $@

isNumber $1
ret_code=$?
exitOnError $ret_code "'$1' is not a valid orderID"

if isLoggedIn
then

info=$(OFFLINE=1 "$DIR_SELF/getActiveOrders.sh")
[ $(echo -e "$info" | wc -l) -lt 2 ] && exitOnError 90 "$info"
[ $(echo -e "$info" | grep "[[:space:]]$1[[:space:]]" | wc -l) -ne 1 ] && exitOnError 91 "Order ID '$1' not found into your active orders\n$info"

if [ -z "$PASS_ORDER" ] || [ "$PASS_ORDER" == "xxx" ]
then
  if [ -z "$PASS_LOGIN" ] || [ "$PASS_ORDER" == "xxx" ]
  then
    echo -n "Password: "
    read -s PASS_ORDER
    echo
    if [ -z "$PASS_ORDER" ]
    then
      echo "Empty password - nothing to do!"
      exit 92
    fi
  else
    PASS_ORDER="$PASS_LOGIN"
  fi
fi

echo -n "pw=$PASS_ORDER&banul=anulare&idord=A$1&timeStamp=$(date '+%s%N' | cut -c -13)" > "$FILE_MYDATA"
info=$(my_curl "$MY_URL/ashx/ordurm.ashx?hdlr=da" --data @"$FILE_MYDATA" -o $OUT_TMP)
ret_code=$?
exitOnError $ret_code "$info"


if [ $(grep -c 'ultima comanda</td><td>confirmare anulare' $OUT_TMP) -eq 1    -o \
     $(grep -c 'ultima comanda</td><td>DA anulare'         $OUT_TMP) -eq 1       ]
then
  msg="SUCCESS"
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code

fi
