#!/bin/bash

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HOME/.config/bptui/config.sh"

source "$script_dir/pacman_handler.sh"
source "$script_dir/flatpak_handler.sh"
source "$script_dir/paru_handler.sh"

function remove_packages() {
  clear
  echo -e "\e[32mSelect packages to remove from available sources\e[0m"
  echo -e "\e[33mNote: Use TAB or SHIFT+TAB to select multiple packages\e[0m"

  # Build the unified list based on enabled sources
  pkg_list=$(
    {
      $USE_PACMAN && pacman -Qen | awk '{print "pacman:" $1}'
      $USE_FLATPAK && flatpak list | awk '{print "flatpak:" $2}'
      $USE_PARU && paru -Qm | awk '{print "paru:" $1}'
    } | sort -u | fzf --multi --height 60% --border --prompt "Select packages: "
  )

  if [[ -z "$pkg_list" ]]; then
    echo "No packages selected."
    return
  fi

  # Separate packages by source
  pacman_pkgs=()
  flatpak_pkgs=()

  while IFS= read -r line; do
    case "$line" in
      pacman:*) pacman_pkgs+=("${line#pacman:}") ;;
      flatpak:*) flatpak_pkgs+=("${line#flatpak:}") ;;
      paru:*) pacman_pkgs+=("${line#paru:}") ;;
    esac
  done <<< "$pkg_list"

  if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
    clear
    remove_pacman_explicit_pkgs "${pacman_pkgs[@]}"
    echo -e
    read -p "Press any key to continue..." -n 1
  fi

  if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
    clear
    remove_flatpak_pkgs "${flatpak_pkgs[@]}"
    echo -e
    read -p "Press any key to continue..." -n 1
  fi
}