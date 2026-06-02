#!/bin/bash
STATE="/tmp/music_expanded"
if [ -f "$STATE" ]; then
    rm "$STATE"
else
    touch "$STATE"
fi
