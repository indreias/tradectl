#!/bin/bash


if [ -z "$1" ]
then
  file_list=$(ls ./*.sh)
else
  file_list=$@
fi

for f in $file_list
do
  if [ "$(basename "$f")" != "$(basename "$0")" ]
  then
    echo -n $(basename "$f")
    info=$(cat $f | awk '{if (index($0,"HELPME_TXT")==1) h=1} {if (index($0,"helpMe")==1) h=0} {if (h==1) {{if (t==1) {printf "\t"}else{printf " "}}{print $0;t=1}}}' | sed 's/HELPME_TXT=//;s/"//')
    if [ -z "$info" ]
    then
      echo
    else
      echo -e "$info\n\t-------------------------------------------------------------------------------------------------------"
    fi
    echo
  fi
done
