# Vesktop on Wayland

This adapter targets the native Linux Vesktop package installed at
`/opt/vesktop`. It requires Bash, Python 3 and socat. The official Discord
installer in the parent directory is independent.

Run `./vesktop/install.sh` from the repository root, quit any running Vesktop
instance, then start Vesktop using the printed `launch.sh` path. Configure your
compositor to run the printed `toggle.sh` path with `mute` or `deafen`.
Use `toggle.sh status` to check the connection without toggling anything.
Set your launcher to use the same launch script if you want the hotkeys
available when opening Vesktop from your app menu.

The adapter uses a private Unix socket in your session runtime directory
and calls the Discord voice actions through Vencord. There is no polling
or focus switch. This relies on Vencord's Discord module discovery and may
need adjustments after app updates. The source integration was exercised
with Vesktop 1.6.9 on Hyprland.

To undo, restore your launcher and hotkey bindings, quit the wrapped
Vesktop instance and launch the stock app. The installer prints the
adapter directory, which you can then remove.
