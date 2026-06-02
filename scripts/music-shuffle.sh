#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'; exit 0; fi
if [ ! -f "/tmp/music_expanded" ]; then
    echo '{"text": "", "class": "hidden"}'; exit 0; fi
SHUFFLE=$(playerctl -p spotify shuffle 2>/dev/null)
CLASS="shuffle-off"; [ "$SHUFFLE" = "On" ] && CLASS="shuffle-on"
echo "{\"text\": \"󰒝\", \"class\": \"${CLASS}\"}"
