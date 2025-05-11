#!/bin/bash

source "modules/pkg/info_manager.sh"

function install_flatpak_pkgs() {
  echo -e
  echo -e "\e[32mSelect packages to install\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(flatpak remote-ls --app | awk '{print $2}' | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    print_flatpak_pkg_info "$packages"

    echo "Installing selected pkgs: $packages"
    # shellcheck disable=SC2046
    flatpak install flathub $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
}

function remove_flatpak_pkgs() {
  echo -e
  echo -e "\e[32mSelect packages to remove\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(flatpak list | awk '{print $2}' | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    echo "Removing selected pkgs: $packages"
    # shellcheck disable=SC2046
    flatpak uninstall $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
    echo "Removing unused dependencies..."
    flatpak uninstall --unused
  else
    echo "No packages selected."
  fi
}

function update_flatpak_pkgs() {
  echo -e "\e[33mUpdating Flatpak packages...\e[0m"
  echo -e

  sudo flatpak update

  echo -e "\e[32mFlatpak packages updated.\e[0m"
  echo -e
  read -p "Press any key to continue..." -n 1
  clear
}
