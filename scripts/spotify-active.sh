#!/usr/bin/env bash

status=$(playerctl -p spotify status 2>/dev/null || true)
[[ "$status" == "Playing" || "$status" == "Paused" ]]
