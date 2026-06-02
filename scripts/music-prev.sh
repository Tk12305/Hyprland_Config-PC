#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'; exit 0; fi
if [ ! -f "/tmp/music_expanded" ]; then
    echo '{"text": "", "class": "hidden"}'; exit 0; fi
echo '{"text": "󰒮", "class": "playing"}'
