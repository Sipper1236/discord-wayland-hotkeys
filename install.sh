#!/usr/bin/env bash
# ==============================================================================
# Discord Wayland Global Hotkeys Installer
# Fixes Scroll Lock (Mute) & Pause/Break (Deafen) keybinds on Wayland with zero CPU overhead.
# ==============================================================================

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Discord Wayland Hotkey Fix Installer ===${NC}\n"

# 1. Locate Discord desktop core module
DISCORD_CORE_DIR=""
for path in "$HOME/.config/discord/app-"*/modules/discord_desktop_core-*/discord_desktop_core/index.js; do
    if [ -f "$path" ]; then
        DISCORD_CORE_DIR=$(dirname "$path")
        break
    fi
done

if [ -z "$DISCORD_CORE_DIR" ]; then
    echo -e "${RED}Error: Could not find Discord desktop core installation in ~/.config/discord/${NC}"
    echo "Please ensure Discord is installed and has been run at least once."
    exit 1
fi

INDEX_JS="$DISCORD_CORE_DIR/index.js"
INDEX_BAK="$DISCORD_CORE_DIR/index.js.bak"

echo -e "${GREEN}[1/4] Found Discord Core at:${NC} $DISCORD_CORE_DIR"

# 2. Backup original index.js if not already backed up
if [ ! -f "$INDEX_BAK" ]; then
    cp "$INDEX_JS" "$INDEX_BAK"
    echo -e "${GREEN}[2/4] Created backup at:${NC} $INDEX_BAK"
else
    echo -e "${YELLOW}[2/4] Backup already exists at:${NC} $INDEX_BAK"
fi

# Inject background trigger server into index.js
cat << 'EOF' > "$INDEX_JS"
const http = require('http');
const { app, BrowserWindow } = require('electron');

app.whenReady().then(() => {
  try {
    const server = http.createServer((req, res) => {
      const url = req.url;
      let action = null;
      let keyCode = null;

      if (url === '/mute') {
        action = 'mute';
        keyCode = 'M';
      } else if (url === '/deafen') {
        action = 'deafen';
        keyCode = 'D';
      }

      if (action) {
        const windows = BrowserWindow.getAllWindows();
        for (const win of windows) {
          if (win.webContents && !win.webContents.isDestroyed()) {
            try {
              win.webContents.sendInputEvent({ type: 'keyDown', keyCode: keyCode, modifiers: ['control', 'shift'] });
              win.webContents.sendInputEvent({ type: 'keyUp', keyCode: keyCode, modifiers: ['control', 'shift'] });
            } catch (err) {}

            win.webContents.executeJavaScript(`
              try {
                const wpc = window.webpackChunkdiscord_app;
                if (wpc) {
                  wpc.push([[Math.random()], {}, (e) => {
                    for (const m of Object.values(e.c)) {
                      const exp = m && m.exports && (m.exports.default || m.exports);
                      if (exp && typeof exp.toggleSelfMute === 'function') {
                        if ("${action}" === "mute") exp.toggleSelfMute();
                        else if ("${action}" === "deafen") exp.toggleSelfDeaf();
                        break;
                      }
                    }
                  }]);
                }
              } catch(e){}
            `).catch(() => {});
          }
        }
        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('OK\n');
      } else {
        res.writeHead(404);
        res.end('Not Found\n');
      }
    });

    server.listen(25810, '127.0.0.1', () => {
      console.log('[DiscordTrigger] Server listening on http://127.0.0.1:25810');
    });
  } catch (e) {
    console.error('[DiscordTrigger] Error starting server:', e);
  }
});

module.exports = require('./core.asar');
EOF

echo -e "${GREEN}[2/4] Successfully patched Discord index.js${NC}"

# 3. Create local toggle scripts
mkdir -p "$HOME/.local/bin"

cat << 'EOF' > "$HOME/.local/bin/discord-toggle-mute"
#!/bin/sh
curl -s http://127.0.0.1:25810/mute >/dev/null 2>&1
EOF

cat << 'EOF' > "$HOME/.local/bin/discord-toggle-deafen"
#!/bin/sh
curl -s http://127.0.0.1:25810/deafen >/dev/null 2>&1
EOF

chmod +x "$HOME/.local/bin/discord-toggle-mute" "$HOME/.local/bin/discord-toggle-deafen"

echo -e "${GREEN}[3/4] Created toggle scripts in ~/.local/bin/${NC}"

# 4. Configure GNOME Shortcuts if running under GNOME
if [ "$XDG_CURRENT_DESKTOP" = "GNOME" ] || [ -n "$DBUS_SESSION_BUS_ADDRESS" ]; then
    echo -e "${GREEN}[4/4] Configuring GNOME Custom Keyboard Shortcuts...${NC}"
    
    export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"

    gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-mute/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-deafen/']"

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-mute/ name 'Discord Toggle Mute'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-mute/ command "$HOME/.local/bin/discord-toggle-mute"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-mute/ binding 'Scroll_Lock'

    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-deafen/ name 'Discord Toggle Deafen'
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-deafen/ command "$HOME/.local/bin/discord-toggle-deafen"
    gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom-discord-deafen/ binding 'Pause'

    echo -e "${GREEN}GNOME Shortcuts set: Scroll Lock -> Mute, Pause -> Deafen${NC}"
else
    echo -e "${YELLOW}[4/4] Non-GNOME desktop detected. Please map your custom shortcuts manually:${NC}"
    echo "  Mute Command:   $HOME/.local/bin/discord-toggle-mute"
    echo "  Deafen Command: $HOME/.local/bin/discord-toggle-deafen"
fi

echo -e "\n${BLUE}=== Installation Complete! ===${NC}"
echo -e "Please restart Discord to apply the changes."
