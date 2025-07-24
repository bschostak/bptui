#!/bin/bash


export HOME="$(mktemp -d)"
CONFIG_SCRIPT="$(dirname "$0")/../../modules/config/config_controller.sh"
CONFIG_PATH="$HOME/.config/bptui/config.sh"

# Load the function from your project
. "$CONFIG_SCRIPT"

setUp() {
    rm -rf "$HOME/.config"
}

test_config_created_when_missing() {
    setup_config
    assertTrue "Config file should be created" "[ -f \"$CONFIG_PATH\" ]"
}

test_default_values_written() {
    setup_config
    source "$CONFIG_PATH"

    assertEquals "true" "$USE_PACMAN"
    assertEquals "false" "$USE_FLATPAK"
    assertEquals "false" "$USE_PARU"
    assertEquals "false" "$USE_YAY"
    assertEquals "false" "$USE_SNAP"
    assertEquals "false" "$PRINT_PKG_INFO"
    assertEquals "false" "$DEBUG_MODE"
}

test_config_not_overwritten() {
    mkdir -p "$(dirname "$CONFIG_PATH")"
    echo "USE_PACMAN=false" > "$CONFIG_PATH"

    setup_config
    source "$CONFIG_PATH"

    assertEquals "false" "$USE_PACMAN"
}

. /usr/bin/shunit2