#!/bin/bash
# act_overlay.sh v0.3.0
# act_parse v0.3.0
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
# --

source $(dirname "$0")/simple_curses.sh

# sometime, cygwin fails to fork.
# don't display any errors so the rendering is not currupted
exec 2>/dev/null

tput civis
stty -echo
umask 0177
s_buffer=$(mktemp)
s_render=$(mktemp)
s_json=$(mktemp)
b_init=0

function cleanup {
  echo -en "\e[0m"
  rm -f "$s_buffer" "$s_render" "$s_json"
  stty echo
  tput reset
  exit 0
}

function colortitle {
  read s_line
  echo -en "\e[1m\e[34m"
  echo "$s_line" \
    | sed 's/Duration:/\x1B[1m\x1B[32mDuration:\x1B[1m\x1B[33m/g' \
    | sed 's/\/ TDPS:/\x1B[1m\x1B[32m\/ TDPS:\x1B[1m\x1B[33m/g' \
    | sed 's/\/ THPS:/\x1B[1m\x1B[32m\/ THPS:\x1B[1m\x1B[33m/g'
}

function colortable {
  echo -en "\e[0m"
  let i_ln=1
  while read s_line
  do
    if [ $i_ln -eq 1 ]
    then
      echo -e "\e[31m$s_line"
    else
      if [ $i_ln -eq $i_players ]
      then
        echo -en "\e[97m${s_line}"
      else
        echo -e "\e[97m${s_line}"
      fi
    fi
    let i_ln++
  done
}

trap cleanup SIGINT SIGTERM

main() {
  # get buffer
  > "$s_json"
  while read -r -t 0.1 "s_jsondata"
  do
    if [ "$s_jsondata" == "" ]
    then
      return
    fi
    echo "$s_jsondata" >> "$s_json"
  done

  jsondata=""
  while read -r "s_jsondata"
  do
    s_type=$(echo "$s_jsondata" | jq -r '.msgtype')

    if [ "$s_type" == "CombatData" ]
    then
      b_init=1
      # extract header data
      s_title=$(echo "$s_jsondata" | jq -r '.msg.Encounter' | jq -c -r \
        '. | "\(.title)"')
      s_duration=$(echo "$s_jsondata" | jq -r '.msg.Encounter' | jq -c -r \
        '. | "\(.duration)"')
      s_tdps=$(echo "$s_jsondata" | jq -r '.msg.Encounter' "$s_jsonline" | jq -c -r \
        '. | "\(.ENCDPS)"')
      s_thps=$(echo "$s_jsondata" | jq -r '.msg.Encounter' | jq -c -r \
        '. | "\(.ENCHPS)"')

      i_min=$(echo "$s_duration" | cut -d: -f1)
      i_sec=$(echo "$s_duration" | cut -d: -f2)

      echo "Name;DPS;HPS;Job;DMG%;CRIT%;DH%;Hits" > "$s_render"
      # extract combatant data
      echo "$s_jsondata" | jq -r '.msg.Combatant' | jq -c -r \
        'keys[] as $k | "\($k);\(.[$k] | .ENCDPS);\(.[$k] | .ENCHPS);\(.[$k] | .Job);\(.[$k] | ."damage%");\(.[$k] | ."crithit%");\(.[$k] | .DirectHitPct);\(.[$k] | .hits)"' \
        | sort -t';' -k2 -nr \
        | awk -F ';' '// { printf("%s;%s;%s;%s;%s;%s;%s;%s\n", substr($1,1,12), $2, $3, $4, $5, $6, $7, $8 ) }' | head -n9 | grep -v '^Coup\ Net' | sed 's/\+Infini/∞/g' >> "$s_render"

      i_players=$(wc -l "$s_render" | cut -f1 -d" ")
    fi
  done < "$s_json"

  if [ "$b_init" == "1" ]
  then
    echo "Encounter: $s_title" | colortitle
    echo "Duration: $s_duration / TDPS: $s_tdps / THPS: $s_thps" | colortitle
    column -t -s ";" "$s_render" | colortable
  else
    echo "ACT Overlay initialized, no data received yet"
  fi
}

main_loop 1
