#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
app_dir="${XDG_DATA_HOME:-$HOME/.local/share}/discord-wayland-hotkeys/vesktop"
[[ -r /opt/vesktop/resources/app.asar && -x /opt/vesktop/vesktop ]] || {
    echo 'Install the native Vesktop package under /opt/vesktop first.' >&2
    exit 1
}
install -d "$app_dir/runtime/resources"
install -m644 main.cjs package.json pack.py "$app_dir/"
install -m755 launch.sh toggle.sh "$app_dir/"
for entry in /opt/vesktop/*; do
    case ${entry##*/} in vesktop|resources) continue ;; esac
    ln -sfn "$entry" "$app_dir/runtime/"
done
python3 "$app_dir/pack.py"
printf 'Launch Vesktop with: %s/launch.sh\nBind your hotkeys to: %s/toggle.sh mute (or deafen)\n' "$app_dir" "$app_dir"
