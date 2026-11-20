#!/usr/bin/env bash
set -euo pipefail
case ${1:-} in
    mute|deafen|status) ;;
    *) echo 'Usage: toggle.sh mute|deafen|status' >&2; exit 2 ;;
esac
reply=$(printf '%s\n' "$1" | socat -t 3 -T 4 - "UNIX-CONNECT:${XDG_RUNTIME_DIR:?}/vesktop-hotkeys.sock")
printf '%s\n' "$reply"
[[ -n $reply && $reply != *'"error"'* ]]
