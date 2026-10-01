#!/usr/bin/env bash
set -euo pipefail

# Hyprland PC dependency installer
# Arch Linux + Hyprland 0.55+ / Lua configuration
#
# Installs everything used by the backed-up configuration EXCEPT:
#   - Claude Desktop
#   - Jellyfin Desktop
#
# Also installs Google Chrome, Spotify, and the legacy NVIDIA 580xx
# driver needed by Pascal GPUs such as the GTX 1070.

if [[ $EUID -eq 0 ]]; then
    echo "Do not run this script as root."
    echo "Run: ./install.sh"
    exit 1
fi

if [[ ! -f /etc/arch-release ]]; then
    echo "This installer is intended for Arch Linux."
    exit 1
fi

echo
echo "=============================================="
echo " Hyprland PC - dependency installer"
echo "=============================================="
echo
echo "This will install:"
echo "  Hyprland + Waybar + Hyprpaper + Hypridle + Hyprlock"
echo "  Wayland/XWayland + XDG desktop portal"
echo "  NetworkManager + nm-applet"
echo "  Bluetooth + Blueman"
echo "  PipeWire + WirePlumber + audio utilities"
echo "  Clipboard, screenshots, notifications and desktop utilities"
echo "  Kitty, Nautilus, Rofi, Qt tools"
echo "  Fonts used by the configuration"
echo "  Google Chrome + Spotify"
echo "  NVIDIA 580xx legacy driver for the GTX 1070"
echo
echo "Claude Desktop and Jellyfin Desktop are intentionally NOT installed."
echo

read -rp "Continue? [Y/n] " answer
answer="${answer:-Y}"
[[ "$answer" =~ ^[Yy]$ ]] || exit 0

echo
echo "[1/6] Updating Arch Linux..."
sudo pacman -Syu --needed

# Core packages used directly by the config and its scripts.
PACMAN_PACKAGES=(
    # Hyprland / Wayland
    hyprland
    waybar
    hyprpaper
    hypridle
    hyprlock
    xdg-desktop-portal
    xdg-desktop-portal-hyprland
    xdg-desktop-portal-gtk
    xorg-xwayland
    wayland
    wayland-protocols

    # Session / desktop integration
    polkit-gnome
    gnome-keyring
    libnotify
    xdg-utils

    # Networking
    networkmanager
    network-manager-applet

    # Bluetooth
    bluez
    bluez-utils
    blueman

    # Audio
    pipewire
    pipewire-pulse
    wireplumber
    pavucontrol
    pamixer
    brightnessctl
    playerctl

    # Clipboard / screenshots
    wl-clipboard
    cliphist
    grim
    slurp

    # Desktop applications used by the config
    kitty
    nautilus
    rofi
    qt5ct
    qt5-wayland
    qt6-wayland

    # Utilities used by scripts / custom helpers
    curl
    jq
    git
    base-devel
    cifs-utils
    smbclient

    # Fonts referenced by Waybar / lock screen / CSS
    ttf-nunito
    ttf-cinzel
    ttf-jetbrains-mono-nerd
    noto-fonts
    noto-fonts-emoji
)

echo
echo "[2/6] Installing official Arch packages..."
sudo pacman -S --needed "${PACMAN_PACKAGES[@]}"

echo
echo "[3/6] Enabling required system services..."
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service

# PipeWire/WirePlumber are normally started automatically as user services.
# Explicitly enabling them is harmless when the units are available.
systemctl --user enable --now pipewire.service pipewire-pulse.service wireplumber.service 2>/dev/null || true

echo
echo "[4/6] Installing paru (AUR helper)..."

if ! command -v paru >/dev/null 2>&1; then
    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    git clone https://aur.archlinux.org/paru.git "$tmpdir/paru"
    (
        cd "$tmpdir/paru"
        makepkg -si --noconfirm
    )

    rm -rf "$tmpdir"
    trap - EXIT
fi

echo
echo "[5/6] Installing AUR packages..."

# GTX 1070 = Pascal. Arch's current main NVIDIA 590+ driver no longer
# supports Pascal, so use the legacy proprietary 580xx DKMS branch.
#
# paru will pull the matching 580xx userspace package/dependencies.
AUR_PACKAGES=(
    nvidia-580xx-dkms
    google-chrome
    spotify
)

paru -S --needed --noconfirm "${AUR_PACKAGES[@]}"

echo
echo "[6/6] Installing repository helper scripts and Rofi configuration..."

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

# The repository contains these helper scripts in bin/. Install them to the
# standard per-user executable directory used by the Hyprland config.
if [[ -d "$SCRIPT_DIR/bin" ]]; then
    mkdir -p "$HOME/.local/bin"
    cp -a "$SCRIPT_DIR/bin/." "$HOME/.local/bin/"
    find "$HOME/.local/bin" -maxdepth 1 -type f -exec chmod +x {} +
    echo "  Installed helper scripts to ~/.local/bin"
else
    echo "  WARNING: bin/ directory not found; skipping helper scripts."
fi

# The repository contains the Rofi configuration/themes and Wi-Fi menu.
if [[ -d "$SCRIPT_DIR/rofi" ]]; then
    mkdir -p "$HOME/.config/rofi"
    cp -a "$SCRIPT_DIR/rofi/." "$HOME/.config/rofi/"
    [[ -f "$HOME/.config/rofi/wifi-menu.sh" ]] && chmod +x "$HOME/.config/rofi/wifi-menu.sh"
    echo "  Installed Rofi configuration to ~/.config/rofi"
else
    echo "  WARNING: rofi/ directory not found; skipping Rofi configuration."
fi

echo
echo "=============================================="
echo " Installation complete"
echo "=============================================="
echo
echo "Installed:"
echo "  - Hyprland / Waybar / Hyprpaper / Hypridle / Hyprlock"
echo "  - Wayland + XWayland + XDG portals"
echo "  - NetworkManager + Bluetooth"
echo "  - PipeWire / WirePlumber / audio tools"
echo "  - Clipboard + screenshot tools"
echo "  - Kitty / Nautilus / Rofi / Qt integration"
echo "  - Required fonts and utilities"
echo "  - Google Chrome"
echo "  - Spotify"
echo "  - NVIDIA 580xx DKMS driver"
echo
echo "NOT installed:"
echo "  - Claude Desktop"
echo "  - Jellyfin Desktop"
echo
echo "Repository helper scripts and Rofi files have also been installed."
echo "These include:"
echo "  ~/.local/bin/dim-brightness.sh"
echo "  ~/.local/bin/hypridle-inhibit"
echo "  ~/.local/bin/hypridle-snooze-menu"
echo "  ~/.local/bin/rofi-smb"
echo "  ~/.local/bin/rofi-wifi"
echo "  ~/.config/rofi/*"
echo
echo "Next step:"
echo "  Run your restore script, then log out and start Hyprland."
echo
echo "For the GTX 1070, do not install nvidia-open; Pascal support"
echo "requires the legacy proprietary 580xx driver branch."
echo
