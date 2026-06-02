#!/usr/bin/env bash

status=$(playerctl -p spotify status 2>/dev/null || true)

if [[ "$status" == "Paused" ]]; then
  printf '󰐊\n'
else
  printf '󰏤\n'
fi
