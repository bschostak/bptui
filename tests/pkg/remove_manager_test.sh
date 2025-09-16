#!/bin/bash

# Mock config flags
USE_PACMAN=true
USE_FLATPAK=true
USE_PARU=true

# Prevent sourcing real files
source() { return 0; }

# Mock external commands
pacman() { echo "vim 1.0"; }
flatpak() { echo "com.spotify.Client"; }
paru() { echo "neofetch 7.1"; }

# Mock fzf to simulate user selection
fzf() {
    cat <<EOF
pacman:vim
flatpak:com.spotify.Client
paru:neofetch
EOF
}

# Mock removal functions
remove_pacman_explicit_pkgs() {
    echo "Mock: Removing pacman packages: $*"
}
remove_flatpak_pkgs() {
    echo "Mock: Removing flatpak packages: $*"
}

# Stub out interactive commands
clear() { return 0; }
read() { return 0; }

# Source the file to test
. ../../modules/pkg/remove_manager.sh

# Setup and teardown
setUp() {
    OUTPUT_FILE=$(mktemp)
}

tearDown() {
    rm -f "$OUTPUT_FILE"
}

test_remove_packages_processes_selection_correctly() {
    remove_packages > "$OUTPUT_FILE"

    echo "Captured output:"
    cat "$OUTPUT_FILE"

    assertTrue "Should remove pacman packages" "grep -q 'Mock: Removing pacman packages: vim neofetch' \"$OUTPUT_FILE\""
    assertTrue "Should remove flatpak packages" "grep -q 'Mock: Removing flatpak packages: com.spotify.Client' \"$OUTPUT_FILE\""
}

# Load shunit2
. /usr/bin/shunit2
