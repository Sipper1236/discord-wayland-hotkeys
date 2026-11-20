# Discord Wayland Global Hotkeys 🎙️🎧🔔

A lightweight, zero-overhead solution to enable working **Global Hotkeys for Mute and Deafen** in Official Discord on **Fedora / Ubuntu / Arch / any Linux Wayland desktop** (GNOME, KDE Plasma, Hyprland, Sway).

> 💡 **Note:** Yes, this is a **vibe-coded solution**, but it actually works! It runs instantly with 0% CPU overhead, plays Discord's authentic audio chimes, and keeps your active game or browser window completely undisturbed.

---

## ❓ The Problem & Solution

### The Problem
On Wayland (default on Fedora/Ubuntu), applications cannot listen to global keystrokes in the background due to Wayland's security model. Furthermore, Electron drops legacy keys like `Scroll Lock` and `Pause/Break`. 

Most workarounds either require switching to X11, using third-party web apps like Vesktop, or doing janky window-focus switching that minimizes your game or active window.

### The Solution
This project embeds a tiny (~20 lines) local background trigger server inside Discord's local Node.js process (`127.0.0.1:25810`). 

When you press your custom key (e.g. `Scroll Lock` or `Pause/Break`), your OS sends a 1-millisecond signal to Discord over localhost. Discord executes its native `toggleSelfMute()` / `toggleSelfDeaf()` methods, **plays the authentic audio chime** 🔔, and leaves your screen and active window 100% untouched.

---

## 🌟 Features

- ⚡ **Zero-Overhead (<1MB RAM, 0% CPU)**: No extra background apps or polling loops.
- 🎯 **Choose ANY Key**: Use `Scroll_Lock`, `Pause`, `F13`–`F24`, `XF86AudioMute`, `Ctrl+Shift+M`, or any key/button you prefer.
- 🔔 **Native Audio Chimes**: Plays Discord's authentic mute/deafen sound effects.
- 🔒 **Zero Window Disruption**: Never steals focus, minimizes, or interrupts your game or workspace.
- 🚀 **Instant Response**: Executes in < 5ms over localhost IPC.

---

## 📦 Quick Start / Installation

Clone the repository and run the interactive installer:

```bash
git clone https://github.com/<YOUR-USERNAME>/discord-wayland-hotkeys.git
cd discord-wayland-hotkeys
chmod +x install.sh
./install.sh
```

The installer will prompt you to choose your preferred hotkeys (or press **Enter** to use default `Scroll_Lock` and `Pause`):

```
Choose your custom hotkey for TOGGLE MUTE:
Examples: Scroll_Lock, F13, F14, XF86AudioMute, <Primary><Shift>m
Enter Mute Hotkey [Default: Scroll_Lock]: 

Choose your custom hotkey for TOGGLE DEAFEN:
Examples: Pause, F14, F15, XF86AudioDeafen, <Primary><Shift>d
Enter Deafen Hotkey [Default: Pause]: 
```

After installation finishes, **restart Discord**.

### Non-Interactive / Scripted Install

You can also pass your preferred keys as arguments:

```bash
./install.sh --mute Scroll_Lock --deafen Pause
# or
./install.sh --mute F13 --deafen F14
```

---

## 🖥️ Desktop Environment Guides

### GNOME (Automated)
`install.sh` automatically configures custom keyboard shortcuts in GNOME via `gsettings`.

### KDE Plasma
1. Open **System Settings** $\rightarrow$ **Shortcuts** $\rightarrow$ **Custom Shortcuts**.
2. Create two new Command shortcuts:
   - **Mute**: Command = `~/.local/bin/discord-toggle-mute` $\rightarrow$ Set your preferred hotkey.
   - **Deafen**: Command = `~/.local/bin/discord-toggle-deafen` $\rightarrow$ Set your preferred hotkey.

### Hyprland (`hyprland.conf`)
Add these lines to your `hyprland.conf`:

```ini
bind = , Scroll_Lock, exec, ~/.local/bin/discord-toggle-mute
bind = , Pause, exec, ~/.local/bin/discord-toggle-deafen
```

### Sway (`~/.config/sway/config`)
Add these lines to your Sway config:

```ini
bindsym Scroll_Lock exec ~/.local/bin/discord-toggle-mute
bindsym Pause exec ~/.local/bin/discord-toggle-deafen
```

---

## 🛠️ Technical Architecture

```
[ Your Custom Keypress ] ──► [ OS Desktop Manager ] ──► [ ~/.local/bin/discord-toggle-mute ]
                                                                      │
                                                                 (curl request)
                                                                      ▼
 [ Discord Muted + Chime Played 🔔 ] ◄── [ In-Process Event ] ◄── [ 127.0.0.1:25810 ]
```

1. **Local Trigger Server**: `install.sh` patches `discord_desktop_core/index.js` to run a lightweight HTTP server on `127.0.0.1:25810`.
2. **Key Binding**: Your OS Desktop Manager captures your keypress globally and runs `curl -s http://127.0.0.1:25810/mute` (or `/deafen`).
3. **Direct In-Memory Event**: Discord receives the local HTTP request and calls its internal `toggleSelfMute()` / `toggleSelfDeaf()` methods directly in Electron's renderer process.

---

## 💻 Manual CLI Usage

You can also trigger mute and deafen manually from terminal or custom macro scripts:

```bash
# Toggle Mute
curl -s http://127.0.0.1:25810/mute

# Toggle Deafen
curl -s http://127.0.0.1:25810/deafen
```

---

## 🗑️ Uninstallation

To restore original Discord core files and remove all custom shortcuts:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

---

## 📄 License

MIT License. Free for all open-source distribution and use.

For native Vesktop, see the [Vesktop adapter](vesktop/README.md).
