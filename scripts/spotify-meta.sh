#!/usr/bin/env bash

escape_json() {
  local text=$1
  text=${text//\\/\\\\}
  text=${text//\"/\\\"}
  text=${text//$'\n'/ }
  text=${text//$'\r'/ }
  printf '%s' "$text"
}

trim_label() {
  local text=$1
  local limit=$2
  if (( ${#text} <= limit )); then
    printf '%s' "$text"
  else
    printf '%s…' "${text:0:limit-1}"
  fi
}

status=$(playerctl -p spotify status 2>/dev/null || true)
if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
  echo '{"text":"","tooltip":"","class":"hidden"}'
  exit 0
fi

artist=$(playerctl -p spotify metadata artist 2>/dev/null || true)
title=$(playerctl -p spotify metadata title 2>/dev/null || true)
album=$(playerctl -p spotify metadata album 2>/dev/null || true)

label="$title"
if [[ -n "$artist" && -n "$title" ]]; then
  label="$artist - $title"
elif [[ -z "$label" ]]; then
  label="$artist"
fi

short=$(trim_label "$label" 34)
tooltip=$(escape_json "$artist - $title")
if [[ -n "$album" ]]; then
  tooltip="$tooltip\\n$(escape_json "$album")"
fi

class_name="playing"
if [[ "$status" == "Paused" ]]; then
  class_name="paused"
fi

printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' \
  "$(escape_json "$short")" \
  "$tooltip" \
  "$class_name"
