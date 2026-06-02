#!/bin/bash
COVER_CSS="$HOME/.config/waybar/albumart.css"
LAST_ART_FILE="/tmp/waybar_last_art_url"

if ! playerctl -p spotify status &>/dev/null 2>&1; then
    rm -f "$LAST_ART_FILE"
    printf '#custom-music { background-image: none; }\n' > "$COVER_CSS"
    echo '{"text": "", "class": "stopped"}'
    exit 0
fi

STATUS=$(playerctl -p spotify status 2>/dev/null)
TITLE=$(playerctl -p spotify metadata xesam:title 2>/dev/null)
ARTIST=$(playerctl -p spotify metadata xesam:artist 2>/dev/null)
ART_URL=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null)
LAST_ART=$(cat "$LAST_ART_FILE" 2>/dev/null)
SHUFFLE=$(playerctl -p spotify shuffle 2>/dev/null)
LOOP=$(playerctl -p spotify loop 2>/dev/null)

if [ "$ART_URL" != "$LAST_ART" ] && [ -n "$ART_URL" ]; then
    echo "$ART_URL" > "$LAST_ART_FILE"
    curl -s "$ART_URL" -o /tmp/cover.jpg
    printf '#custom-music { background-image: url("/tmp/cover.jpg"); background-size: 32px 32px; background-repeat: no-repeat; background-position: left center; }\n' > "$COVER_CSS"
    pkill -SIGUSR2 waybar
fi

PLAY_ICON="󰐊"
[ "$STATUS" = "Playing" ] && PLAY_ICON="󰏤"
LOOP_ICON="󰑗"
[ "$LOOP" = "Track" ]    && LOOP_ICON="󰑘"
[ "$LOOP" = "Playlist" ] && LOOP_ICON="󰑖"

CLASS="${STATUS,,}"
[ "$SHUFFLE" = "On" ]  && CLASS="$CLASS shuffle-on"
[ "$LOOP" != "None" ]  && CLASS="$CLASS loop-on"

SHORT=$(echo "$TITLE" | cut -c1-20)
[ ${#TITLE} -gt 20 ] && SHORT="${SHORT}…"

# Controls in text — invisible by default, shown on :hover via CSS
CONTROLS="󰒮  ${PLAY_ICON}  󰒭  󰒝  ${LOOP_ICON}  ${SHORT}"
echo "{\"text\": \"${CONTROLS}\", \"tooltip\": \"${TITLE}\\n${ARTIST}\", \"class\": \"${CLASS}\"}"
