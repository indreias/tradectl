#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=0
HELPME_TXT="[<user>]
Login with the user from command line (if provided), from .conf file (if present) or read from terminal
Note: password will be read from terminal if not present into the .conf file"
helpMe $@

if [ -z "$1" ]
then
  if [ -z "$USER" ]
  then
    echo -n "User: "
    read USER
    if [ -z "$USER" ]
    then
      echo "Empty user - nothing to do!"
      exit 90
    fi
  fi
else
  USER=$1
fi

if [ -z "$PASS_LOGIN" ]
then
  echo -n "Password: "
  read -s PASS_LOGIN
  echo
  if [ -z "$PASS_LOGIN" ]
  then
    echo "Empty password - nothing to do!"
    exit 91
  fi
fi

if [ -z "$MY_LANGUAGE" ]
then
  MY_LANGUAGE=RO
fi

[ -f "$FILE_COOKIE" ] && rm -f "$FILE_COOKIE"

echo -n "__EVENTTARGET=btnLogin&cont=$USER&pw=$PASS_LOGIN&platformType=rbSt20&btnLogin=Login" > "$FILE_MYDATA"
info=$(my_curl --cookie "limba20=$MY_LANGUAGE" "$MY_URL/Trading/Loginq.aspx" --data @"$FILE_MYDATA" -o "$OUT_HOME")
ret_code=$?
exitOnError $ret_code "$info"

if [ $(grep -c "Login_lblHomeNume" "$OUT_HOME") -eq 1 ]
then
  msg="SUCCESS"
  # Run in offline mode because we have the needed data
  info=$(OFFLINE=1 "$DIR_SELF/getPortfolio.sh")
  if [ -n "$info" ]; then msg="$msg\t$info"; fi
  ret_code=0
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code
