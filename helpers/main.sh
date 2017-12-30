#!/usr/bin/env bash

#
# Main helper file
#

# Create temporary directory if not already exists
[ -d "$DIR_TEMP" ] || mkdir -p "$DIR_TEMP"

isNumber(){
# Check if provided argument is a number, when it will return 0
# $1 = value to check
  [ -z "$1" ] && return 1
  return $(echo -n "$1" | sed 's/[0-9]//g' | wc -m)
}

exitOnError(){
# Check for execution error and exit
# $1 = previous return code
# $2 = message to display
  if [ $1 -gt 0 ]
  then
    echo -e "ERROR\t$2"
    exit $1
  fi
}

helpMe(){
# Print help instructions and exit
# $@ = all options from the calling script
# HELPME_VAR = number of minimum arguments
# HELPME_TXT = text to be displayed
  if [ -z "$HELPME_VAR" ]
  then
    HELPME_VAR=0
  fi
  if [ $# -lt $HELPME_VAR ] || [ "$1" == "-h" ]||  [ "$1" == "--help" ]
  then
    if [ -n "$HELPME_TXT" ]
    then
      echo -e "Usage: $(basename $0) $HELPME_TXT"
    else
      echo "Execution interrupted on $(basename $0) - no help text available yet."
    fi
    exit 0
  fi
}

my_curl(){
# Main function for making web calls
  # Set data file permissions
  [ -f "$FILE_MYDATA" ] && chmod 400 "$FILE_MYDATA"
  # Customize the cURL command
  if [ "$OFFLINE" != "1" ]
  then
    t1=$(date '+%s.%N')
    curl $CURL_OPTIONS --user-agent "$USER_AGENT" $@ 2>&1
    rc=$?
    t2=$(date '+%s.%N')
    dt=$(echo "$t1 $t2" | awk '{printf "%.3f",$2-$1}')
    echo -e "$(date)\tdt:$dt\trc:$rc\t$@" >> /tmp/curl.log
  else
    rc=0
  fi
  # Remove data file
  [ -f "$FILE_MYDATA" ] && rm -f "$FILE_MYDATA"
  return $rc
}

htmlNormalize(){
# Normalize the HTML file
  [ -f "$1" ] || return 1
  sed -i 's|\r||g;s|^[[:space:]]*||g;s|[[:space:]]*$||g;/^$/d;s|</\([^>]*\)><|</\1>\n<|g' "$1" 2>/dev/null
}

htmlExtract(){
# Extract on one line the needed information
# $1 = file
# $2 = start string
# $3 = object start
# $4 = object stop
# $5 = all or only one
  awk -v select_text="$2" -v start_text="$3" -v stop_text="$4" -v items=$5 \
      '{if (index($0, select_text) > 0 && p==0) {start=1;myItems=myItems+1}}
       {if (start==1 && (items==0 || myItems==items))
	            { {if (index($0,start_text) > 0) {p=p+1}}
                      {if (p>=1) {print $0}}
                      {if (index($0,stop_text)> 0) {p=p-1;if (p==0) {start=0}}}
                    }
       }' "$1" | tr -d '\n'
}

isLoggedIn(){
# Check if the user is logged in or not
  info=$(OFFLINE=$OFFLINE "$DIR_SELF/isLoggedIn.sh" &>/dev/null)
  rc=$?
  if [ $rc -gt 0 ]
  then
    echo "ERROR: Not logged in!"
    exit $rc
  fi
}

# Export functions for which we need to capture their output
export -f my_curl htmlNormalize htmlExtract
