#!/usr/bin/env bash

#
# TODO: let user specify start and stop date
#

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=0
HELPME_TXT="[<shareSymbol>] [<dataType>]
Get quotes for the mentioned share (or for all if not mentioned).
Available datatypes are:
    * AVG  - daily averages (default type)
    * TRAN - daily tranzactions"
helpMe $@

if isLoggedIn
then

if [ -z "$2" ]
then
  dataType="AVG"
else
  dataType=$2
fi

case $dataType in
  TRAN)	hData="data si ora tran";;
  *)    hData="data tran";;
esac

info=$(my_curl "$MY_URL/Trading/ReportsAndQuotes/DownloadMetaStockDisplay.aspx?DateStart=11/01/2017&DateStop=12/03/2017&AccountType=A&Symbol=$1&Ajusted=Y&Format=TXT&DataType=$dataType" -o - 2>&1)
ret_code=$?
exitOnError $ret_code "$info"

if [ -n "$info" ]
then
  msg="$info"
  ret_code=0
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg" | sed "s|data|$hData|;s|valoare|valoare tran|"
exit $ret_code

fi
