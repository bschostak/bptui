#!/bin/bash

# TODO: Delete this file

function print_pacman_pkg_info() {
    package_names=$*

    # shellcheck disable=SC2046
    package_info=$(pacman -Si $(echo "$package_names" | tr '\n' ' ') 2>/dev/null)

    if [[ -n "$package_info" ]]; then
        clear
        echo -e "\e[33mPackage/s Info\e[0m"
        echo -e
        echo -e "$package_info"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    else
        echo -e
        echo -e "\e[31mPackage not found.\e[0m"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    fi
}

function print_flatpak_pkg_info() {
    package_names=$*

    # shellcheck disable=SC2046
    package_info=$(flatpak remote-info flathub $(echo "$package_names" | tr '\n' ' ') 2>/dev/null)

    if [[ -n "$package_info" ]]; then
        clear
        echo -e "\e[33mPackage/s Info\e[0m"
        echo -e
        echo -e "$package_info"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    else
        echo -e
        echo -e "\e[31mPackage not found.\e[0m"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    fi
}

function print_paru_pkg_info() {
    package_names=$*

    # shellcheck disable=SC2046
    package_info=$(paru -Si $(echo "$package_names" | tr '\n' ' ') 2>/dev/null)

    if [[ -n "$package_info" ]]; then
        clear
        echo -e "\e[33mPackage/s Info\e[0m"
        echo -e
        echo -e "$package_info"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    else
        echo -e
        echo -e "\e[31mPackage not found.\e[0m"
        echo -e
        read -p "Press any key to continue..." -n 1
        clear
    fi
}
