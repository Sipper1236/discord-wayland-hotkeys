#!/usr/bin/env bash
# ==============================================================================
# Discord Wayland Global Hotkeys Uninstaller
# Restores original Discord files and removes custom keybindings.
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== Discord Wayland Hotkey Fix Uninstaller ===${NC}\n"

# 1. Restore index.js
for path in "$HOME/.config/discord/app-"*/modules/discord_desktop_core-*/discord_desktop_core/index.js.bak; do
    if [ -f "$path" ]; then
        ORIG_DIR=$(dirname "$path")
        cp "$path" "$ORIG_DIR/index.js"
        rm -f "$path"
        echo -e "${GREEN}[1/3] Restored original index.js at:${NC} $ORIG_DIR"
    fi
done

# 2. Remove toggle scripts
rm -f "$HOME/.local/bin/discord-toggle-mute" "$HOME/.local/bin/discord-toggle-deafen"
echo -e "${GREEN}[2/3] Removed scripts from ~/.local/bin/${NC}"

# 3. Reset GNOME custom keybindings if present
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
    gsettings reset org.gnome.settings-daemon.plugins.media-keys custom-keybindings 2>/dev/null || true
    echo -e "${GREEN}[3/3] Reset GNOME Custom Keybindings${NC}"
fi

echo -e "\n${BLUE}=== Uninstallation Complete ===${NC}"
echo "Please restart Discord."
