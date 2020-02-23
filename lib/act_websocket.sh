#!/bin/bash
# act_overlay.sh v0.3.0
# act_websocket.sh v0.3.0
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
# --

function cleanup() {
  reset
  exit 0
}

trap cleanup SIGINT SIGTERM

s_base="$(dirname $0)"
s_cpu="$(uname -m)"
s_platform="$(uname -s | cut -d- -f1)"

source "$s_base"/../act_overlay.cfg

if [ "$s_platform" == "CYGWIN_NT" ]
then
  if [ "s_cpu" != "x86_64" ]
  then
    s_binary="$s_base/websocat_win64.exe"
  else
    s_binary="$s_base/websocat_win32.exe"
  fi
else
  s_binary="websocat"
fi

while true
do
	"$s_binary" -E --ping-interval 1 --ping-timeout 2 "$WS_PROTO"://"$WS"/MiniParse 2>/dev/null
	echo "ACTWS: Websocket lost, attempting reconnect"
	ret="$?"
	if [ "$ret" == "1" ]
	then
		exit 0
	fi
	sleep 1
done
