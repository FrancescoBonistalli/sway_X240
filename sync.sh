#!/bin/bash
# Pull the live configs from ~/.config into this repo, after showing what
# would change and asking for confirmation.

set -uo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$REPO_DIR/sync-lib.sh"

copy_configs "$HOME/.config" "$REPO_DIR" "the repo"
