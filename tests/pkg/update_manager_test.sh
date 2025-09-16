#!/bin/bash

USE_PACMAN=true
USE_FLATPAK=true
USE_PARU=true
USE_YAY=true
USE_SNAP=true

read() { return 0; }
clear() { return 0; }

source() { return 0; }

. ../../modules/pkg/update_manager.sh

update_pacman_pkgs() { echo "Pacman updated"; }
update_flatpak_pkgs() { echo "Flatpak updated"; }
update_paru_pkgs() { echo "Paru updated"; }

setUp() {
    OUTPUT_FILE=$(mktemp)
}

test_update_all_pkgs_outputs_with_expected_messages() {
    update_all_pkgs > "$OUTPUT_FILE"

    echo "Captured output:"
    cat "$OUTPUT_FILE"

    assertTrue "Should mock Pacman update" "grep -q 'Pacman updated' \"$OUTPUT_FILE\""
    assertTrue "Should mock Flatpak update" "grep -q 'Flatpak updated' \"$OUTPUT_FILE\""
    assertTrue "Should mock Paru update" "grep -q 'Paru updated' \"$OUTPUT_FILE\""
    assertTrue "Should mention YAY not implemented" "grep -q 'YAY update function not implemented yet.' \"$OUTPUT_FILE\""
    assertTrue "Should mention Snap not implemented" "grep -q 'Snap update function not implemented yet.' \"$OUTPUT_FILE\""
}

tearDown() {
    rm -f "$OUTPUT_FILE"
}

. /usr/bin/shunit2
