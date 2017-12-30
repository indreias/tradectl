#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

if isLoggedIn
then

htmlNormalize "$OUT_HOME"

info=$(htmlExtract "$OUT_HOME" "ucActiveOrders" "<table" "</table" 1 | sed '
s|<t[ab][^>]*>||g;s|</table>||g;
s|<t[rhd] [a-zA-Z]*=[^>]*>||g;s|<t[hrd]>||g;
s|<br/>||;
s|OrderNo=|>|g;s|.\([0-9]*\).);"><span|>\1\t<span|g;
s|<script[^<]*</script>||g;
s|<span[^>]*>||g;s|</span>||g;
s|<input[^>]*>||g;
s|<div[^>]*>||g;s|</div>||g;
s|&Symbol=[^>]*>|\t|g;
s|<a[^>]*>||g;s|</a>||g;
s|<\/t[hd]>|\t|g;
s|</tr>|\n|g;
s|,||g;
s|Data|Data ordin|;s|Date|Order date|;
s|Ticker ||;
s|Tip|ID\tTip|;s|Type|ID\tType|;
s|Pret piata|Piata|;s|Market Price|Market|;
s|Pret|Ordin|;s|Price|Order|' | sed 's|[[:space:]]*$||g;/^$/d'
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
