#!/bin/bash

source "modules/pkg/info_manager.sh"

function install_paru_pkgs() {
    echo -e
    echo -e "\e[32mSelect packages to install\e[0m"
    echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

    packages=$(paru -Sl aur | awk '{print $2}' | fzf --multi --height 50% --border --prompt "Select packages: ")

    if [[ -n "$packages" ]]; then
        print_paru_pkg_info "$packages"

        echo "Installing selected pkgs: $packages"
        # shellcheck disable=SC2046
        paru -S --needed $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
    else
        echo "No packages selected."
    fi
}

function update_paru_pkgs() {
    echo -e "\e[33mUpdating Paru packages...\e[0m"
    echo -e

	paru -Sua

    echo -e "\e[32mParu packages updated.\e[0m"
    echo -e
    read -p "Press any key to continue..." -n 1
    clear
}