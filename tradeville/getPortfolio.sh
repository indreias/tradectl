#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=0
HELPME_TXT="[details]
Get portfolio total vallue or get its details"
helpMe $@

if isLoggedIn
then

htmlNormalize "$OUT_HOME"

if [ "$1" == "details" ]
then
  info=$(htmlExtract "$OUT_HOME" 'id="ctl00_c_divPortfolioGrid"' "<table" "</table" 1 | sed '
s|<t[ab][^>]*>||g;s|</table>||g;
s|<tr class="total">.*</tr>||g;
s|<t[hd] [^>]*display:none[^>]*>[^<]*</t[hd]>||g;
s|<t[rhd] [a-zA-Z]*=[^>]*>||g;
s|<script[^<]*</script>||g;
s|<span[^>]*>||g;s|</span>||g;
s|<a[^>]*>||g;s|</a>||g;
s|&nbsp;||g;
s|</t[hd]>|\t|g;
s|</tr>|\n|g;
s|,||g;s|LEI|RON|g;
s|\t\t|\t-\t|g;
s|\t1.0000\t-\t|\t-\t-\t|;
s| piata||;s|Market ||;
s|Evolution|Evol|;s|Ticker ||' | sed 's|[[:space:]]*$||g;/^$/d')

else
  info=$(grep -m 1 'id="ctl00_c_lblPortfolioTotal"' "$OUT_HOME" | sed 's/^.*<span.*">//;s/<\/span>//;s/,//g')
fi

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
