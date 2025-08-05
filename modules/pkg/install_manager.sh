#!/bin/bash

# source "$HOME/.config/bptui/config.sh"

# source "modules/pkg/info_manager.sh"
# source "modules/pkg/pacman_handler.sh"
# source "modules/pkg/flatpak_handler.sh"
# source "modules/pkg/paru_handler.sh"

# TODO: Make all other sources so.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HOME/.config/bptui/config.sh"

source "$script_dir/info_manager.sh"
source "$script_dir/pacman_handler.sh"
source "$script_dir/flatpak_handler.sh"
source "$script_dir/paru_handler.sh"

function install_packages() {
  clear
  echo -e "\e[32mSelect packages to install from available sources\e[0m"
  echo -e "\e[33mNote: Use TAB or SHIFT+TAB to select multiple packages\e[0m"

  # Build the unified list based on enabled sources
  pkg_list=$(
    {
      $USE_PACMAN && pacman -Sl | awk '{print "pacman:" $2}'
      $USE_FLATPAK && flatpak remote-ls --app | awk '{print "flatpak:" $2}'
      $USE_PARU && paru -Sl aur | awk '{print "paru:" $2}'
    } | sort -u | fzf --multi --height 60% --border --prompt "Select packages: "
  )

  if [[ -z "$pkg_list" ]]; then
    echo "No packages selected."
    return
  fi

  # Separate packages by source
  pacman_pkgs=()
  flatpak_pkgs=()
  paru_pkgs=()

  while IFS= read -r line; do
    case "$line" in
      pacman:*) pacman_pkgs+=("${line#pacman:}") ;;
      flatpak:*) flatpak_pkgs+=("${line#flatpak:}") ;;
      paru:*) paru_pkgs+=("${line#paru:}") ;;
    esac
  done <<< "$pkg_list"

  if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
    clear
    $PRINT_PKG_INFO && print_pacman_pkg_info "${pacman_pkgs[@]}"
    install_pacman_pkgs "${pacman_pkgs[@]}"
    echo -e
    read -p "Press any key to continue..." -n 1
  fi

  if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
    clear
    $PRINT_PKG_INFO && print_flatpak_pkg_info "${flatpak_pkgs[@]}"
    install_flatpak_pkgs "${flatpak_pkgs[@]}"
    echo -e
    read -p "Press any key to continue..." -n 1
  fi

  if [[ ${#paru_pkgs[@]} -gt 0 ]]; then
    clear
    $PRINT_PKG_INFO && print_paru_pkg_info "${paru_pkgs[@]}"
    install_paru_pkgs "${paru_pkgs[@]}"
    echo -e
    read -p "Press any key to continue..." -n 1
  fi
}