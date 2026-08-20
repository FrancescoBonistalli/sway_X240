#!/bin/bash
# Push this repo's configs out to ~/.config, after showing what would change
# and asking for confirmation.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/sync-lib.sh"

copy_configs "$REPO_DIR" "$HOME/.config" "~/.config"
