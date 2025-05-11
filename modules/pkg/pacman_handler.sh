#!/bin/bash

source "modules/pkg/info_manager.sh"

function install_pacman_pkgs() {
  echo -e
  echo -e "\e[32mSelect packages to install\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(pacman -Sl | awk '{print $2}' | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    print_pacman_pkg_info "$packages"

    echo "Installing selected pkgs: $packages"
    # shellcheck disable=SC2046
    sudo pacman -S --needed $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
}

function remove_pacman_pkgs() {
  echo -e
  echo -e "\e[32mSelect packages to remove\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(pacman -Qe | awk '{print $1}' | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    echo "Installing selected pkgs: $packages"
    # shellcheck disable=SC2046
    sudo pacman -Rns $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
}

function update_pacman_pkgs() {
  echo -e "\e[33mUpdating repo packages...\e[0m"
  echo -e

  sudo pacman -Syu

  echo -e "\e[32mRepo packages updated.\e[0m"
  echo -e
  read -p "Press any key to continue..." -n 1
  clear
}

function clean_pacman_cache() {
  echo "Cleaning pacman cache..."
  echo -e

  sudo pacman -Scc

  echo "Cache cleaned."
}

function remove_orphan_packages() {
  echo "Removing orphan packages..."
  echo -e

  sudo pacman -Rns $(pacman -Qtdq)

  echo "Orphan packages removed."
}

