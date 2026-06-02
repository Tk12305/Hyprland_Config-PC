#!/usr/bin/env bash

shuffle=$(playerctl -p spotify shuffle 2>/dev/null || true)

if [[ "$shuffle" == "On" ]]; then
  echo '{"text":"󰒟","class":"on"}'
else
  echo '{"text":"󰒞","class":"off"}'
fi
