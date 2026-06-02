#!/bin/bash
LOOP=$(playerctl -p spotify loop 2>/dev/null)
case "$LOOP" in
    None)     playerctl -p spotify loop Playlist ;;
    Playlist) playerctl -p spotify loop Track ;;
    Track)    playerctl -p spotify loop None ;;
esac
