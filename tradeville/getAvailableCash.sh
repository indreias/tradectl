#!/usr/bin/env bash

. "$(dirname $0)/../tradeville.conf"

HELPME_VAR=0
HELPME_TXT="[<currency>]
Get available cash (in all currencies) or only for a selected one, like USD"
helpMe $@

if isLoggedIn
then

info=$(my_curl "$MY_URL/Trading/MyAccount/ManageAccount.aspx" -o "$OUT_TMP" 2>&1)
ret_code=$?
exitOnError $ret_code "$info"

htmlNormalize "$OUT_TMP"

info=$(htmlExtract "$OUT_TMP" 'refreshButtonBright' "<table" "</table" 0 |  sed 's|<t[ab][^>]*>||g;s|</table>|\n|g' | sed ' 
s|<tr[^>]*><td colspan=.*$||;
s|.*<tr[^>]*><td[^>]*>||g;s|</tr>||g;
s|<script[^<]*</script>||g;
s|<span[^>]*>||g;s|</span>||g;
s|<img[^>]*/>||g;
s|</div>||g;
s|<td[^>]*>||g;
s|>-</td||g;s|\(</td>\)*|\1|g;s|</td>|\t|g;
s|,||g;s/[lL][eE][iI]/RON/g' |  awk '{print $1"\t"$(NF-1)}')

if [ -n "$info" ]
then
  if [ -n "$1" ]
  then
    if [ $(echo "$1" | tr '[a-z]' '[A-Z]') == "LEI" ]
    then
      myCurrency="RON"
    else
      myCurrency="$1"
    fi
    msg=$(echo -e "$info" | grep -i "$myCurrency" | awk '{print $2}')
    if [ -z "$msg" ]
    then
      msg="-0.00"
    fi
  else
    msg="$info"
  fi
  ret_code=0
else
  msg="FAILURE\tcode:99"
  ret_code=99
fi

echo -e "$msg"
exit $ret_code

fi
