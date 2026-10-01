# Hyprland Config Restore

This package restores the user's `Hyprland_Config-PC` backup on a fresh Arch + Hyprland installation.

## Files

- `restore-config.sh` — main restore script
- `hyprland.lua` — migrated Hyprland 0.55+ configuration
- `monitors.lua` — migrated monitor configuration

The script also restores:
- hypridle.conf
- hyprlock.conf
- hyprpaper.conf
- wallpapers
- Waybar config/style
- Waybar scripts

The old `.conf` Hyprland files are preserved under a timestamped `legacy-conf-*` directory.

## Run

```bash
chmod +x restore-config.sh
./restore-config.sh
```

The script expects `git` to already be installed.

## Important

Hyprland 0.55+ uses Lua for the compositor configuration. The separate `hypridle.conf`, `hyprlock.conf`, and `hyprpaper.conf` remain `.conf` files because those programs have their own configuration formats.

The old `local.conf` contained `pkill nm-applet`, which would kill the nm-applet that the main configuration starts. It is preserved as a legacy backup but deliberately not executed in the migrated configuration.

The backup's current `monitors.lua` placed HDMI-A-1 at `1920x1080`; the older backed-up `monitors.conf` specified `0x0`. The migration uses `0x0`, which is appropriate for the single-monitor setup represented by the backup.
