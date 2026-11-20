#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
if ! cmp -s /opt/vesktop/vesktop runtime/vesktop; then
    staged=$(mktemp runtime/vesktop.XXXXXX)
    install -m755 /opt/vesktop/vesktop "$staged"
    mv -f "$staged" runtime/vesktop
fi
exec "$PWD/runtime/vesktop" "$@"
