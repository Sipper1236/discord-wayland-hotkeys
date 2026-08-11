# Discord Wayland Global Hotkeys (Scroll Lock & Pause/Break) 🎙️🔔

A lightweight, zero-overhead solution to enable working **Scroll Lock (Mute)** and **Pause/Break (Deafen)** global hotkeys for Official Discord on **Fedora Linux / Wayland** (GNOME / KDE / Hyprland).

> **Why is this needed?**  
> On Wayland (Fedora default), Discord cannot capture global keypresses when unfocused due to Wayland security restrictions. Modern Electron also ignores legacy keys like `Scroll Lock` and `Pause/Break`. This project enables working global hotkeys **with Discord's native mute/deafen audio chimes** 🔔 without altering window focus or wasting system resources.

---

## Features

- ⚡ **Zero-Overhead (<1MB RAM, 0% CPU)**: No extra daemons or polling loops; embeds directly into Discord's local Node.js process.
- 🔔 **Native Audio Chimes**: Plays Discord's authentic mute/deafen sound effects.
- 🔒 **Zero Window Movement**: Never steals focus, minimizes, or moves your active game or browser window.
- 🚀 **Instant Trigger**: Activates via local IPC in < 5ms.

---

## Quick Installation

Run the automated installer script:

```bash
git clone https://github.com/<your-username>/discord-wayland-hotkeys.git
cd discord-wayland-hotkeys
chmod +x install.sh
./install.sh
```

Restart Discord after running the installer.

---

## How It Works

1. **Local HTTP Trigger Server**: `install.sh` injects a tiny (~20 lines) background event listener into Discord's desktop core entry file (`discord_desktop_core/index.js`) listening on `127.0.0.1:25810`.
2. **GNOME / OS Shortcut**: Your system maps `Scroll Lock` and `Pause/Break` to issue an instant `curl http://127.0.0.1:25810/mute` (or `/deafen`).
3. **Direct Renderer Event**: Discord receives the signal in-memory, triggers `toggleSelfMute()` / `toggleSelfDeaf()`, and plays the **native audio chime** 🔔.

---

## Manual Control / CLI Commands

You can also trigger mute and deafen manually from terminal or custom scripts:

```bash
# Toggle Mute
curl -s http://127.0.0.1:25810/mute

# Toggle Deafen
curl -s http://127.0.0.1:25810/deafen
```

---

## Uninstallation

To restore original Discord core files and remove all custom shortcuts:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

---

## License

MIT License. Free for all open-source distribution and use.
