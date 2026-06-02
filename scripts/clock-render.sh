#!/usr/bin/env bash

STATE_FILE="/tmp/waybar-clock-alt"

escape_json() {
  local text=$1
  text=${text//\\/\\\\}
  text=${text//\"/\\\"}
  text=${text//$'\n'/\\n}
  text=${text//$'\r'/ }
  printf '%s' "$text"
}

mode="default"
if [[ -f "$STATE_FILE" ]]; then
  mode=$(cat "$STATE_FILE" 2>/dev/null || printf 'default')
fi

if [[ "$mode" == "alt" ]]; then
  text=$(date '+%H:%M:%S')
else
  text=$(date '+%a %d %b  %H:%M')
fi

month_header=$(date '+%B %Y')
calendar=$(cal)
tooltip=$(printf '<big>%s</big>\n<tt><small>%s</small></tt>' "$month_header" "$calendar")

status=$(playerctl -p spotify status 2>/dev/null || true)
class_name="idle"
if [[ "$status" == "Playing" ]]; then
  class_name="playing"
elif [[ "$status" == "Paused" ]]; then
  class_name="paused"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(escape_json "$text")" \
  "$(escape_json "$tooltip")" \
  "$class_name"
