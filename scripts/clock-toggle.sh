#!/usr/bin/env bash

STATE_FILE="/tmp/waybar-clock-alt"

mode="default"
if [[ -f "$STATE_FILE" ]]; then
  mode=$(cat "$STATE_FILE" 2>/dev/null || printf 'default')
fi

if [[ "$mode" == "alt" ]]; then
  printf 'default' > "$STATE_FILE"
else
  printf 'alt' > "$STATE_FILE"
fi
