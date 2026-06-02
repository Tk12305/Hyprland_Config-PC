#!/bin/bash
COVER_CSS="$HOME/.config/waybar/albumart.css"
LAST_ART_FILE="/tmp/waybar_last_art_url"
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    rm -f "$LAST_ART_FILE" "/tmp/music_expanded"
    printf '#custom-music-art { background-image: none; }\n' > "$COVER_CSS"
    echo '{"text": "", "class": "stopped"}'
    exit 0
fi
TITLE=$(playerctl -p spotify metadata xesam:title 2>/dev/null)
ARTIST=$(playerctl -p spotify metadata xesam:artist 2>/dev/null)
ART_URL=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
LAST_ART=$(cat "$LAST_ART_FILE" 2>/dev/null)
if [ "$ART_URL" != "$LAST_ART" ] && [ -n "$ART_URL" ]; then
    echo "$ART_URL" > "$LAST_ART_FILE"
    curl -s "$ART_URL" -o /tmp/cover.jpg
    printf '#custom-music-art { background-image: url("/tmp/cover.jpg"); }\n' > "$COVER_CSS"
    pkill -SIGUSR2 waybar
fi
CLASS="playing"
[ -f "/tmp/music_expanded" ] && CLASS="playing expanded"
echo "{\"text\": \" \", \"tooltip\": \"${TITLE}\\n${ARTIST}\\nClick to toggle controls\", \"class\": \"${CLASS}\"}"
