#!/bin/bash
if ! playerctl -p spotify status &>/dev/null 2>&1; then
    echo '{"text": "", "class": "stopped"}'
    exit 0
fi
echo '{"text": "󰒮", "class": "playing"}'
