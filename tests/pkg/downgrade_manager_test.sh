#!/bin/bash

# Temporary home for config
export HOME="$(mktemp -d)"
CONFIG_PATH="$HOME/.config/bptui/config.sh"
DOWNGRADE_SCRIPT="$(dirname "$0")/../../modules/pkg/downgrade_manager.sh"

# Create mock config
mkdir -p "$(dirname "$CONFIG_PATH")"
cat <<EOF > "$CONFIG_PATH"
USE_PACMAN=true
USE_FLATPAK=false
USE_PARU=false
EOF

pacman() {
  echo -e "bash 5.2.015\nnano 6.3"
}

fzf() {
  # Simulate selecting 'bash'
  echo "pacman:bash"
}

downgrade_pacman_packages() {
  called_downgrade=true
  downgraded=("$@")
}

setUp() {
  called_downgrade=false
  downgraded=()
}

test_downgrade_function_called_on_selection() {
  . "$DOWNGRADE_SCRIPT"

  assertTrue "downgrade_pacman_packages should be triggered" "$called_downgrade"
  assertEquals "bash" "${downgraded[0]}"
}

test_no_selection_skips_downgrade() {
  fzf() { echo ""; } # Simulate skipping all packages
  called_downgrade=false

  . "$DOWNGRADE_SCRIPT"

  assertFalse "Downgrade should not occur without selection" "$called_downgrade"
}

tearDown() {
  rm -rf "$HOME"
}

. /usr/bin/shunit2
