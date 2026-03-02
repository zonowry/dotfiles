#!/usr/bin/env bash
wayfreeze & PID=$!; sleep .1; grim -t ppm -g "$(slurp -o -d -F monospace)" - | wl-copy; kill $PID; 

wl-paste | satty --filename - --copy-command="wl-copy" --annotation-size-factor 0.5 --output-filename="$(xdg-user-dir PICTURES)/Screenshots/Screenshot from %Y-%m-%d %H:%M:%S.png" --actions-on-enter="save-to-clipboard,exit" --brush-smooth-history-size 2 --disable-notifications
