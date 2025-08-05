#!/bin/bash

. ../../modules/pkg/info_manager.sh

# Mock commands
pacman() {
    echo "Package info: Pacman $*"
}

flatpak() {
    echo "Package info: Flatpak $*"
}

paru() {
    echo "Package info: Paru $*"
}

# Capture outputs to a variable instead of displaying
clear() { :; }  # Suppress clears
read() { :; }   # Suppress waits

setUp() {
    output=""
}

test_print_pacman_pkg_info() {
    output=$(print_pacman_pkg_info "vim")
    assertNotNull "$output"
}

test_print_flatpak_pkg_info() {
    output=$(print_flatpak_pkg_info "org.gimp.GIMP")
    assertNotNull "$output"
}

test_print_paru_pkg_info() {
    output=$(print_paru_pkg_info "htop")
    assertNotNull "$output"
}

. /usr/bin/shunit2