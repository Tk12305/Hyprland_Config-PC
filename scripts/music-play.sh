#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'; exit 0; fi
if [ ! -f "/tmp/music_expanded" ]; then
    echo '{"text": "", "class": "hidden"}'; exit 0; fi
STATUS=$(playerctl -p spotify status 2>/dev/null)
ICON="󰐊"; [ "$STATUS" = "Playing" ] && ICON="󰏤"
echo "{\"text\": \"${ICON}\", \"class\": \"${STATUS,,}\"}"
