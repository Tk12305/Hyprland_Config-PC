#!/usr/bin/env bash
# rofi-wifi-menu — nmcli-based WiFi manager matching lunar.rasi theme

ROFI_CMD="rofi -dmenu -theme ~/.config/rofi/lunar.rasi"

notify() {
    notify-send "WiFi" "$1" --icon=network-wireless 2>/dev/null || true
}

get_status() {
    nmcli -t -f WIFI g | grep -qi enabled && echo "on" || echo "off"
}

toggle_wifi() {
    if [ "$(get_status)" = "on" ]; then
        nmcli radio wifi off
        notify "WiFi disabled"
    else
        nmcli radio wifi on
        notify "WiFi enabled"
        sleep 2
    fi
}

scan_networks() {
    nmcli -t -f SSID,SIGNAL,SECURITY,IN-USE dev wifi list 2>/dev/null \
        | awk -F: '
            {
                ssid=$1; signal=$2; sec=$3; active=$4
                if (ssid == "") next
                bar=""
                s=signal+0
                if (s>=80) bar="▂▄▆█"
                else if (s>=60) bar="▂▄▆_"
                else if (s>=40) bar="▂▄__"
                else if (s>=20) bar="▂___"
                else            bar="____"
                lock=(sec != "--" && sec != "") ? " 󰌾" : "  "
                star=(active=="*") ? " ✔" : "  "
                printf "%s%s%s  %s\n", star, bar, lock, ssid
            }' \
        | sort -r
}

get_connected_ssid() {
    nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '/^yes/{print $2; exit}'
}

disconnect_current() {
    local ssid; ssid=$(get_connected_ssid)
    if [ -n "$ssid" ]; then
        nmcli con down id "$ssid" 2>/dev/null \
            || nmcli dev disconnect "$(nmcli -t -f DEVICE,STATE dev | awk -F: '/connected/{print $1; exit}')"
        notify "Disconnected from $ssid"
    else
        notify "Not connected to any network"
    fi
}

connect_to() {
    local ssid="$1"
    if nmcli con up id "$ssid" 2>/dev/null; then
        notify "Connected to $ssid"
        return
    fi
    local sec; sec=$(nmcli -t -f SSID,SECURITY dev wifi list \
        | awk -F: -v s="$ssid" '$1==s{print $2; exit}')
    if [ -n "$sec" ] && [ "$sec" != "--" ]; then
        local pass; pass=$(echo "" | $ROFI_CMD \
            -p "Password for $ssid" \
            -password)
        [ -z "$pass" ] && { notify "No password entered"; return; }
        if nmcli dev wifi connect "$ssid" password "$pass" 2>/dev/null; then
            notify "Connected to $ssid"
        else
            notify "Failed to connect to $ssid"
        fi
    else
        if nmcli dev wifi connect "$ssid" 2>/dev/null; then
            notify "Connected to $ssid"
        else
            notify "Failed to connect to $ssid"
        fi
    fi
}

main() {
    local wifi_status; wifi_status=$(get_status)
    local connected_ssid; connected_ssid=$(get_connected_ssid)

    if [ "$wifi_status" = "on" ]; then
        toggle_label="󰤭  Disable WiFi"
    else
        toggle_label="󰤨  Enable WiFi"
    fi

    local disconnect_label="󰤮  Disconnect"
    local rescan_label="󰑐  Rescan"
    local separator="──────────────────────────"

    local network_list=""
    if [ "$wifi_status" = "on" ]; then
        network_list=$(scan_networks)
    fi

    local menu_header
    if [ -n "$connected_ssid" ]; then
        menu_header="󰤨  Connected: $connected_ssid"
    else
        menu_header="󰤭  Not connected"
    fi

    local chosen
    if [ "$wifi_status" = "on" ] && [ -n "$network_list" ]; then
        chosen=$(printf '%s\n%s\n%s\n%s\n%s\n' \
            "$toggle_label" \
            "$disconnect_label" \
            "$rescan_label" \
            "$separator" \
            "$network_list" \
            | $ROFI_CMD \
                -p "$menu_header" \
                -no-custom \
                -i)
    else
        chosen=$(printf '%s\n' "$toggle_label" \
            | $ROFI_CMD \
                -p "$menu_header" \
                -no-custom \
                -i)
    fi

    [ -z "$chosen" ] && exit 0

    case "$chosen" in
        "$toggle_label")     toggle_wifi; main ;;
        "$disconnect_label") disconnect_current ;;
        "$rescan_label")
            notify "Scanning…"
            nmcli dev wifi rescan 2>/dev/null
            sleep 2
            main
            ;;
        "$separator") main ;;
        *)
            local ssid; ssid=$(echo "$chosen" | sed 's/^.\{8\}//' | sed 's/^  //')
            [ -n "$ssid" ] && connect_to "$ssid"
            ;;
    esac
}

main
