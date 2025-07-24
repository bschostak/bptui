#!/bin/bash

export HOME="$(mktemp -d)"
CONFIG_FILE="$HOME/.config/bptui/config.sh"
OPTION_HANDLER="../../modules/config/option_handler.sh"  # adjust path as needed

setUp() {
    mkdir -p "$(dirname "$CONFIG_FILE")"
    cat <<EOF > "$CONFIG_FILE"
USE_PACMAN=true
USE_FLATPAK=true
USE_PARU=false
USE_YAY=false
USE_SNAP=false
PRINT_PKG_INFO=true
DEBUG_MODE=false
EOF

    PACKAGE_MANAGERS=()
    OPTIONS=()
    NEW_OPTIONS=()
    source "$OPTION_HANDLER"
}

test_get_pkg_mngrs_values() {
    get_pkg_mngrs_values
    assertContains "Should contain is_pacman" "${PACKAGE_MANAGERS[*]}" "is_pacman"
    assertContains "Should contain is_faltpak" "${PACKAGE_MANAGERS[*]}" "is_faltpak"
    assertNotContains "Should not contain is_paru" "${PACKAGE_MANAGERS[*]}" "is_paru"
}

test_get_options_values() {
    get_options_values
    assertContains "Should contain is_show_pkg_info" "${OPTIONS[*]}" "is_show_pkg_info"
    assertNotContains "Should not contain is_debug_mode" "${OPTIONS[*]}" "is_debug_mode"
}

test_set_pkg_mngrs_values() {
    NEW_OPTIONS=("is_snap" "is_yay")

    set_pkg_mngrs_values
    source "$CONFIG_FILE"

    assertEquals "USE_PACMAN should be false" "false" "$USE_PACMAN"
    assertEquals "USE_YAY should be true" "true" "$USE_YAY"
    assertEquals "USE_SNAP should be true" "true" "$USE_SNAP"
}

test_set_options_values() {
    NEW_OPTIONS=("is_debug_mode")

    set_options_values
    source "$CONFIG_FILE"

    assertEquals "PRINT_PKG_INFO should be false" "false" "$PRINT_PKG_INFO"
    assertEquals "DEBUG_MODE should be true" "true" "$DEBUG_MODE"
}

# Helper assertions
assertContains() {
    local message="$1"
    local list="$2"
    local item="$3"
    [[ "$list" == *"$item"* ]] || fail "$message"
}

assertNotContains() {
    local message="$1"
    local list="$2"
    local item="$3"
    [[ "$list" != *"$item"* ]] || fail "$message"
}

. /usr/bin/shunit2
