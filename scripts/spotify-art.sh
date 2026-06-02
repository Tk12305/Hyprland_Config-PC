#!/usr/bin/env bash

CACHE_DIR="/tmp/waybar-spotify"
URL_FILE="$CACHE_DIR/art.url"

mkdir -p "$CACHE_DIR"

status=$(playerctl -p spotify status 2>/dev/null || true)
if [[ "$status" != "Playing" && "$status" != "Paused" ]]; then
  rm -f "$CACHE_DIR"/art-* "$URL_FILE"
  printf '\n'
  exit 0
fi

art_url=$(playerctl -p spotify metadata mpris:artUrl 2>/dev/null || true)
title=$(playerctl -p spotify metadata title 2>/dev/null || true)
artist=$(playerctl -p spotify metadata artist 2>/dev/null || true)

if [[ -z "$art_url" ]]; then
  rm -f "$CACHE_DIR"/art-* "$URL_FILE"
  printf '\n'
  exit 0
fi

if [[ "$art_url" == file://* ]]; then
  path=${art_url#file://}
  printf '%s\n%s - %s\n' "$path" "$artist" "$title"
  exit 0
fi

previous_url=""
if [[ -f "$URL_FILE" ]]; then
  previous_url=$(cat "$URL_FILE")
fi

url_hash=$(printf '%s' "$art_url" | sha256sum | awk '{print $1}')
ART_FILE="$CACHE_DIR/art-$url_hash"

if [[ "$art_url" != "$previous_url" || ! -s "$ART_FILE" ]]; then
  if curl -fsL "$art_url" -o "$ART_FILE"; then
    printf '%s' "$art_url" > "$URL_FILE"
    find "$CACHE_DIR" -maxdepth 1 -type f -name 'art-*' ! -name "art-$url_hash" -delete 2>/dev/null
  fi
fi

if [[ -s "$ART_FILE" ]]; then
  printf '%s\n%s - %s\n' "$ART_FILE" "$artist" "$title"
fi
