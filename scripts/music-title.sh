#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'; exit 0; fi
if [ ! -f "/tmp/music_expanded" ]; then
    echo '{"text": "", "class": "hidden"}'; exit 0; fi
TITLE=$(playerctl -p spotify metadata xesam:title 2>/dev/null)
ARTIST=$(playerctl -p spotify metadata xesam:artist 2>/dev/null)
SHORT=$(echo "$TITLE" | cut -c1-20)
[ ${#TITLE} -gt 20 ] && SHORT="${SHORT}…"
echo "{\"text\": \"${SHORT}\", \"tooltip\": \"${TITLE}\\n${ARTIST}\", \"class\": \"playing\"}"
