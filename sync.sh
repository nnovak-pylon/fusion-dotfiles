#!/bin/sh

set -eu

cd -- "$(dirname -- "$0")"

desync=false

case "${1:-}" in
    -d|--desync)
        desync=true
        ;;
    "")
        ;;
    *)
        printf 'Usage: %s [--desync|-d]\n' "$0" >&2
        exit 2
        ;;
esac

for path in */; do
    [ -d "$path" ] || continue

    name=${path%/}

    if "$desync"; then
        printf 'Unstowing %s...\n' "$name"
        stow --delete --target "$HOME" --verbose "$name"
    else
        printf 'Stowing %s...\n' "$name"
        stow --restow --target "$HOME" --verbose "$name"
    fi
done
