#!/bin/bash
# act_overlay.sh v0.3.0
#
# This program is free software. It comes without any warranty, to
# the extent permitted by applicable law. You can redistribute it
# and/or modify it under the terms of the Do What The Fuck You Want
# To Public License, Version 2, as published by Sam Hocevar. See
# http://sam.zoy.org/wtfpl/COPYING for more details.
# --

# Feel free to change to another source
WEBSOCAT_BASE="https://github.com/vi/websocat/releases/download/v1.5.0"
CURSES_BASE="https://raw.githubusercontent.com/metal3d/bashsimplecurses/master/"

s_base="$(dirname $0)"

echo "ACT Overlay initalizing..."
echo "Checking depdencies.."

echo -n "jq"
jq -V &>/dev/null
i_ret="$?"
if [ "$i_ret" != 0 ]
then
  echo -n "[NOK] "
  exit 1
else
  echo -n "[OK] "
fi

echo -n "wget"
wget -V &>/dev/null
i_ret="$?"
if [ "$i_ret" != 0 ]
then
  echo -n "[NOK] "
  exit 1
else
  echo -n "[OK] "
fi

echo -n "websocat(in path)"
s_platform="$(uname -s | cut -d- -f1)"
websocat -V &>/dev/null
i_ret="$?"
if [ "$i_ret" != 0 ]
then
    if [ "$s_platform" != "CYGWIN_NT" ]
    then
      echo "[NOK]"
      exit 1
    else
      echo "[NOK, but ignoring on cygwin]"
    fi
else
  echo "[OK]"
fi

echo "Checking simple_curses.sh library..."
if [ ! -f "$s_base"/lib/simple_curses.sh ]
then
  echo "* Downloading..."
  wget "$CURSES_BASE"/simple_curses.sh -q -O "$s_base"/lib/simple_curses.sh
  ret="$?"
  if [ "$ret" != 0 ]
  then
    echo "Error downloading simple_curses.sh"
    exit 1
  fi
fi

echo "Checking websocat Windows binaries..."
if [ ! -f "$s_base"/lib/websocat_win32.exe ]
then
  echo "* Downloading i386 binary"
  wget "$WEBSOCAT_BASE"/websocat_win32.exe -q -O "$s_base"/lib/websocat_win32.exe
  ret="$?"
  if [ "$ret" != 0 ]
  then
    echo "Error downloading websocat (i386)"
    exit 1
  fi
fi

if [ ! -f "$s_base"/lib/websocat_win64.exe ]
then
  echo "* Downloading x86_64 binary"
  wget "$WEBSOCAT_BASE"/websocat_win64.exe -q -O "$s_base"/lib/websocat_win64.exe
  ret="$?"
  if [ "$ret" != 0 ]
  then
    echo "Error downloading websocat (x86_64)"
    exit 1
  fi
fi
chmod +x "$s_base"/lib/websocat_win32.exe
chmod +x "$s_base"/lib/websocat_win64.exe

if [ "$1" == "-c" ]
then
  exit 0
fi

echo "All good, starting"
sleep 1
bash "$s_base"/lib/act_websocket.sh | bash "$s_base"/lib/act_parse.sh
