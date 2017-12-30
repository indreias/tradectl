#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=1
HELPME_TXT="<shareSymbol>
Get current market depth for the specified share."
helpMe $@

if isLoggedIn
then

info=$(my_curl "$MY_URL/UpdateAjax/Utils.ashx?method=MarketDepth&symbol=$1&levels=1000&grouped=0" -o "$OUT_TMP" 2>&1)
ret_code=$?
exitOnError $ret_code "$info"

info=$(cat "$OUT_TMP" | sed "s/<table.*<\/th><\/tr><tr align=\"right\">//;
     s/<\/td><tr class=\"total.*table>//;
     s/<td class=\"md_bid_cell_[lightdark]*\">/b /g;
     s/<\/td><td class='md_bid_cell_[lightdark]*'>/ /g;
     s/<\/td><td class='md_bid_cell_[lightdark]*' style=\"cursor:url('\.\.\/\.\.\/img\/hand2x\.cur'),pointer\">/ /g;
     s/<\/td><td class='md_ask_cell_[lightdark]*' style=\"cursor:url('\.\.\/\.\.\/img\/hand2x\.cur'),pointer\">/CRLFa /g;
     s/<\/td><td class='md_ask_cell_[lightdark]*'>/ /g;
     s/<\/td><tr align=\"right\">/CRLF/g;
     s/,//g;
     s/CRLF/\n/g" | grep -v '^a *$\|^b *$' | awk '{if ($1 == "b") print $1" "$4" "$3" "$2; else print $0}' | sort --key=2,2
)

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
