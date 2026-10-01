-- Cosmic Voyager / Lunar Mountains
-- Migrated from the old hyprlang configuration.
-- Hyprland 0.55+ Lua configuration.

require("monitors")

-- Environment
hl.env("XCURSOR_SIZE", "24")
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("DISPLAY", ":0")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- Startup applications
hl.exec_cmd("waybar")
hl.exec_cmd("hyprpaper")
hl.exec_cmd("dunst")
hl.exec_cmd("nm-applet --indicator")
hl.exec_cmd("wl-paste --type text --watch cliphist store")
hl.exec_cmd("wl-paste --type image --watch cliphist store")
hl.exec_cmd("hypridle")
hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

-- Input
hl.config({
    input = {
        kb_layout = "gb",
        follow_mouse = 1,
        sensitivity = 0,
        scroll_factor = 1,
    },

    general = {
        gaps_in = 6,
        gaps_out = 14,
        border_size = 2,
        col = {
            active_border = "rgba(4B0082ff) rgba(00FFFFff) 45deg",
            inactive_border = "rgba(000080aa)",
        },
        layout = "dwindle",
        allow_tearing = false,
    },

    decoration = {
        rounding = 10,
        blur = {
            enabled = true,
            size = 8,
            passes = 2,
            new_optimizations = true,
            xray = false,
        },
        active_opacity = 1.0,
        inactive_opacity = 0.92,
    },

    dwindle = {
        preserve_split = true,
    },
})

-- Animation curves
hl.curve("moonrise", {
    type = "bezier",
    points = {
        { 0.16, 1.0 },
        { 0.30, 1.0 },
    },
})

hl.curve("drift", {
    type = "bezier",
    points = {
        { 0.40, 0.0 },
        { 0.20, 1.0 },
    },
})

hl.curve("snap", {
    type = "bezier",
    points = {
        { 0.68, -0.55 },
        { 0.27, 1.55 },
    },
})

hl.animation({ leaf = "windows", enabled = true, speed = 5, curve = "moonrise", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 4, curve = "drift", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 10, curve = "default" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 8, curve = "drift", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 6, curve = "drift" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 5, curve = "snap", style = "slidevert" })

-- Main modifier
local mainMod = "SUPER"

-- Applications
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("kitty"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("google-chrome-stable"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("spotify"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("claude-desktop"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("rofi -show drun -theme ~/.config/rofi/lunar.rasi"))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + V", hl.dsp.window.float())
hl.bind(mainMod .. " + SHIFT + V",
    hl.dsp.exec_cmd("cliphist list | rofi -dmenu -theme ~/.config/rofi/lunar.rasi | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + CTRL + V",
    hl.dsp.exec_cmd("cliphist list | grep -i '\\[image\\]' | head -1 | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen())
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + J", hl.dsp.exec_cmd("env DISPLAY=:0 QT_QPA_PLATFORM=xcb jellyfin-desktop"))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("nautilus"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("~/.local/bin/rofi-smb"))

-- Focus
hl.bind(mainMod .. " + LEFT", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + UP", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + DOWN", hl.dsp.focus({ direction = "d" }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "u" }))

-- Resize
hl.bind(mainMod .. " + SHIFT + RIGHT",
    hl.dsp.window.resize({ x = 30, y = 0, relative = true }),
    { repeating = true })
hl.bind(mainMod .. " + SHIFT + LEFT",
    hl.dsp.window.resize({ x = -30, y = 0, relative = true }),
    { repeating = true })
hl.bind(mainMod .. " + SHIFT + UP",
    hl.dsp.window.resize({ x = 0, y = -30, relative = true }),
    { repeating = true })
hl.bind(mainMod .. " + SHIFT + DOWN",
    hl.dsp.window.resize({ x = 0, y = 30, relative = true }),
    { repeating = true })

-- Workspaces
for i = 1, 9 do
    hl.bind(mainMod .. " + " .. tostring(i), hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. tostring(i),
        hl.dsp.window.move({ workspace = i }))
end

hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))
hl.bind(mainMod .. " + SHIFT + 0", hl.dsp.window.move({ workspace = 10 }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Volume / brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pamixer -i 5"))
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pamixer -d 5"))
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("pamixer -t"))
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl s +10%"))
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl s 10%-"))

-- Screenshot
hl.bind("PRINT", hl.dsp.exec_cmd(
    "sh -c \"grim -g '$(slurp)' - | tee ~/Pictures/screenshot-$(date +%F_%T).png | wl-copy\""
))

-- Per-device mouse configuration
hl.device({
    name = "dell0a69:00-0488:120a-mouse",
    sensitivity = -0.5,
    scroll_factor = 0.3,
})

-- The old local.conf contained `pkill nm-applet`, which would immediately
-- terminate the nm-applet started above. It is therefore kept in the
-- legacy backup but not executed by the migrated configuration.
