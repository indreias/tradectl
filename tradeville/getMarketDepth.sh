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

info=$(cat "$OUT_TMP" | sed '
s|<table.*</th></tr>||g;s|<tr class="total".*$||;
s|<tr[^>]*>|\n|g;
s|<td[^>]*>||g;
s|<hr/>\([^<]*\)</td>\([^<]*\)</td>|:\2 (\1):|g;
s|</td>|:|g;s|,||g' | awk '
BEGIN{FS=":"}
{if ($2 != "")
    {print "b "$3" "$2" "$1}
 else
    {if ($1 != "") {print $1}}
}
{if ($4 != "") {print "a "$4" "$5" "$6}}' | sort -n --key=2,2 | sed 's|\(.*\)\( (.*)\)\(.*\)|\1\3\2|'
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
