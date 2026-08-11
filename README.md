# Discord Wayland Global Hotkeys 🎙️🎧🔔

A lightweight, zero-overhead solution to enable working **Global Hotkeys for Mute and Deafen** in Official Discord on **Fedora / Ubuntu / Arch / any Linux Wayland desktop** (GNOME, KDE Plasma, Hyprland, Sway).

> **The Problem:**  
> On Wayland, Discord cannot capture global hotkeys when unfocused because Wayland restricts background keylogging for security. Additionally, Electron ignores legacy keys like `Scroll Lock` and `Pause/Break`.
>
> **The Solution:**  
> This project embeds a tiny (~20 lines), zero-resource local event server inside Discord's local process. Pressing your custom key triggers Discord's internal mute/deafen actions **and plays Discord's authentic audio chimes** 🔔 — **without ever moving, focusing, or minimizing your active game or browser window.**

---

## 🌟 Features

- ⚡ **Zero-Overhead (<1MB RAM, 0% CPU)**: No heavy background apps or polling loops.
- 🎯 **Choose ANY Key**: Use `Scroll_Lock`, `Pause`, `F13`–`F24`, `XF86AudioMute`, `Ctrl+Shift+M`, or any key/button of your choice.
- 🔔 **Native Audio Chimes**: Plays Discord's authentic mute/deafen sound effects.
- 🔒 **Zero Window Disruption**: Never steals focus, minimizes, or interrupts your active workspace.
- 🚀 **Instant Response**: Executes in < 5ms over localhost HTTP.

---

## 📦 Installation

Clone the repository and run the interactive installer:

```bash
git clone https://github.com/<your-username>/discord-wayland-hotkeys.git
cd discord-wayland-hotkeys
chmod +x install.sh
./install.sh
```

The installer will prompt you to choose your preferred hotkeys (or press **Enter** to accept default keys):

```
Choose your custom hotkey for TOGGLE MUTE:
Examples: Scroll_Lock, F13, F14, XF86AudioMute, <Primary><Shift>m
Enter Mute Hotkey [Default: Scroll_Lock]: 

Choose your custom hotkey for TOGGLE DEAFEN:
Examples: Pause, F14, F15, XF86AudioDeafen, <Primary><Shift>d
Enter Deafen Hotkey [Default: Pause]: 
```

After installation completes, **restart Discord**.

### Non-Interactive / Scripted Install

You can also pass your preferred keys as arguments:

```bash
./install.sh --mute Scroll_Lock --deafen Pause
# or
./install.sh --mute F13 --deafen F14
```

---

## 🖥️ Desktop Environment Configuration

### GNOME (Automated)
The `install.sh` script automatically configures custom keyboard shortcuts in GNOME via `gsettings`.

### KDE Plasma
1. Open **System Settings** $\rightarrow$ **Shortcuts** $\rightarrow$ **Custom Shortcuts**.
2. Add a new command shortcut:
   - **Mute**: Command = `~/.local/bin/discord-toggle-mute` $\rightarrow$ Set your preferred key.
   - **Deafen**: Command = `~/.local/bin/discord-toggle-deafen` $\rightarrow$ Set your preferred key.

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

## 🛠️ How It Works (Under the Hood)

```
[ Your Custom Keypress ] ──► [ OS Desktop Manager ] ──► [ ~/.local/bin/discord-toggle-mute ]
                                                                      │
                                                                 (curl request)
                                                                      ▼
 [ Discord Muted + Chime Played 🔔 ] ◄── [ In-Process Event ] ◄── [ 127.0.0.1:25810 ]
```

1. **Local Trigger Server**: `install.sh` patches `discord_desktop_core/index.js` to run a lightweight HTTP server on `127.0.0.1:25810`.
2. **Key Binding**: Your OS Desktop Environment captures your custom hotkey globally and runs `curl -s http://127.0.0.1:25810/mute` (or `/deafen`).
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

To restore original Discord core files and remove custom shortcuts:

```bash
chmod +x uninstall.sh
./uninstall.sh
```

---

## 📄 License

MIT License. Free for all open-source distribution and use.
