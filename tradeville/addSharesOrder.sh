#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=4
HELPME_TXT="<orderType> <shareSymbol> <price> <quantity>
Add new order for the mentioned share.
Available orderType are:
    * buy 
    * sell

Note: currently only OPEN orders are supported"
helpMe $@

case "$1" in
  buy)	action=C;;
  sell)	action=V;;
  *)	exitOnError 1 "orderType '$1' not supported yet";;
esac

shareSymbol=$2
price=$3
quantity=$4
valability=$(date '+%m/%d/%Y')

if isLoggedIn
then

info=$(my_curl "$MY_URL/Trading/Transaction/NewOrderShares.aspx" -o "$OUT_TMP")
ret_code=$?
exitOnError $ret_code "$info"
newOrderGUID=$(grep hidNewOrderGUID "$OUT_TMP" | grep "value=" | sed 's/^.*value="\(.*\)" .*$/\1/')

# Run in offline mode because we have the needed data
myAccountID=$(OFFLINE=1 "$DIR_SELF/getAccountID.sh")

if [ -n "$newOrderGUID" ]
then
  info=$(my_curl "$MY_URL/UpdateAjax/Utils.ashx?method=AddSharesOrder&symbol=$shareSymbol&hasDetails=0&obs=&isHidden=0&smsAlertChecked=0&tradingAccount=$myAccountID&atMarket=0&price=$price&action=$action&allQuantity=0&quantity=$quantity&valabType=open&valabValue=$valability&conditionType=0&conditionValue=&isCondOrder=0&hidNewOrderGUID=$newOrderGUID&visibleQuantity=0&validMode=0&uniqueParam=$(date '+%s')" -o "$OUT_TMP")
  msg="$newOrderGUID|"$(cat "$OUT_TMP" | sed 's/\..*/\./')
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code

fi
