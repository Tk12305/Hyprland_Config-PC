#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'; exit 0; fi
if [ ! -f "/tmp/music_expanded" ]; then
    echo '{"text": "", "class": "hidden"}'; exit 0; fi
LOOP=$(playerctl -p spotify loop 2>/dev/null)
ICON="󰑗"; CLASS="loop-off"
[ "$LOOP" = "Track" ]    && ICON="󰑘" && CLASS="loop-on"
[ "$LOOP" = "Playlist" ] && ICON="󰑖" && CLASS="loop-on"
echo "{\"text\": \"${ICON}\", \"class\": \"${CLASS}\"}"
