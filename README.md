# act_overlay.sh
ACT-OverlayPlugin (ngld) websocket client script in bash.

## Requirements
* jq

 https://stedolan.github.io/jq/
* GNU wget

 https://www.gnu.org/software/wget/
* bashsimplecurses

 https://github.com/metal3d/bashsimplecurses
* websocat

 https://github.com/vi/websocat
* cygwin, or any (recent enough) UNIX-like environment

bashsimplecurses and websocat win32/win64 binaries are downloaded on first run

## Running
* Edit 'act_overlay.cfg' to match your local configuration.

 Please note this file NEED to have UNIX-style line ending (LF).

 The default one points to `ws://127.0.0.1:10501`

* Run 'act_overlay.sh'
* Enjoy

## Desktop shortcut
* You can also create a desktop shortcut using a locally-adjusted variant of something like this

 C:\cygwin64\bin\mintty.exe -o Font="Liberation Mono" --fs 7 -B void --geometry 55x12+1642+634 /bin/bash -l -c '/path_to_script/act_overlay.sh'

## Why?
* Why not. Also, small window with fixed-width font and minimal visual clutter.
