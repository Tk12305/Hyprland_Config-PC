#!/bin/bash
# Wraps spotify-art.sh output into JSON + CSS background-image for Waybar

COVER_CSS="$HOME/.config/waybar/albumart.css"
LAST_PATH_FILE="/tmp/waybar-spotify-last-path"
EMPTY_CSS='#custom-spotify-art { background-image: none; min-width: 0; margin: 0; padding: 0; }'

escape_json() {
    local text=$1
    text=${text//\\/\\\\}
    text=${text//\"/\\\"}
    text=${text//$'\n'/ }
    text=${text//$'\r'/ }
    printf '%s' "$text"
}

# Get art path and tooltip from original script
OUTPUT=$(bash ~/.config/waybar/scripts/spotify-art.sh)

if [[ -z "$OUTPUT" ]]; then
    CURRENT_CSS=$(cat "$COVER_CSS" 2>/dev/null)
    if [[ "$CURRENT_CSS" != "$EMPTY_CSS" ]]; then
        printf '%s\n' "$EMPTY_CSS" > "$COVER_CSS"
        if [[ -n "$CURRENT_CSS" ]]; then
            pkill -SIGUSR2 waybar 2>/dev/null
        fi
    fi
    rm -f "$LAST_PATH_FILE"
    echo '{"text": "", "class": "empty"}'
    exit 0
fi

ART_PATH=$(echo "$OUTPUT" | head -1)
TOOLTIP=$(echo "$OUTPUT" | tail -1)

LAST_PATH=$(cat "$LAST_PATH_FILE" 2>/dev/null)

if [[ "$ART_PATH" != "$LAST_PATH" ]]; then
    echo "$ART_PATH" > "$LAST_PATH_FILE"
    printf '#custom-spotify-art { background-image: url("%s"); background-size: cover; background-position: center; }\n' "$ART_PATH" > "$COVER_CSS"
    pkill -SIGUSR2 waybar 2>/dev/null
fi

printf '{"text":" ","tooltip":"%s","class":"active"}\n' "$(escape_json "$TOOLTIP")"
