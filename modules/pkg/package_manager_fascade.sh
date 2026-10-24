#!/bin/bash

source "$HOME/.config/bptui/config.sh"
source "modules/tui/tui_controller.sh"
source "modules/pkg/pacman_handler.sh"
source "modules/pkg/paru_handler.sh"
source "modules/pkg/flatpak_handler.sh"

MODE="$1"

if [[ ! " install remove downgrade " =~ " $MODE " ]]; then
  echo "Usage: $0 [install|remove|downgrade]"
  exit 1
fi

function install_packages_flow() {
  clear
  echo -e "\e[4mPackage Installation Search\e[24m"
  read -p "Enter package search query: " search_query

  if [[ -z "$search_query" ]]; then
    echo -e "\e[31mSearch query cannot be empty.\e[0m"
    read -p "Press any key to continue..." -n 1
    return
  fi

  echo -e "\n\e[33mSearching packages for '$search_query'...\e[0m"

  declare -a pkg_options=()

  # 1. Pacman Search
  if [[ "$USE_PACMAN" == true ]]; then
    while IFS= read -r pkg; do
      if [[ -n "$pkg" ]]; then
        pkg_options+=("pacman:$pkg")
      fi
    done < <(pacman -Ssq "$search_query" 2>/dev/null)
  fi

  # 2. Paru Search (AUR / pacman wrapper)
  if [[ "$USE_PARU" == true ]]; then
    while IFS= read -r pkg; do
      if [[ -n "$pkg" ]]; then
        pkg_options+=("paru:$pkg")
      fi
    done < <(paru -Ssaq "$search_query" 2>/dev/null || paru -Ssq "$search_query" 2>/dev/null)
  fi

  # 3. Flatpak Search
  if [[ "$USE_FLATPAK" == true ]]; then
    while IFS= read -r app_id; do
      if [[ -n "$app_id" ]]; then
        pkg_options+=("flatpak:$app_id")
      fi
    done < <(flatpak search "$search_query" --columns=application 2>/dev/null | tail -n +2)
  fi

  if [[ ${#pkg_options[@]} -eq 0 ]]; then
    echo -e "\e[31mNo packages found matching '$search_query'.\e[0m"
    read -p "Press any key to continue..." -n 1
    return
  fi

  # Multi-select enabled via --multi (Use TAB to select multiple, ENTER to confirm)
  local selected_output
  selected_output=$(printf '%s\n' "${pkg_options[@]}" | fzf --multi --prompt="Select packages (TAB to multi-select) > ")

  if [[ -z "$selected_output" ]]; then
    echo "No packages selected."
    read -p "Press any key to continue..." -n 1
    return
  fi

  local pacman_pkgs=()
  local paru_pkgs=()
  local flatpak_pkgs=()

  while IFS= read -r selected; do
    case "$selected" in
      pacman:*) pacman_pkgs+=("${selected#pacman:}") ;;
      paru:*) paru_pkgs+=("${selected#paru:}") ;;
      flatpak:*) flatpak_pkgs+=("${selected#flatpak:}") ;;
    esac
  done <<< "$selected_output"

  clear
  if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
    install_pacman_pkgs "${pacman_pkgs[@]}"
  fi

  if [[ ${#paru_pkgs[@]} -gt 0 ]]; then
    install_paru_pkgs "${paru_pkgs[@]}"
  fi

  if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
    install_flatpak_pkgs "${flatpak_pkgs[@]}"
  fi

  read -p "Press any key to continue..." -n 1
}

function remove_packages_flow() {
  clear
  echo -e "\e[4mPackage Removal\e[24m"
  echo -e "\e[33mLoading installed packages...\e[0m"

  declare -a pkg_options=()

  # Original bulk load of explicitly/locally installed packages for removal
  if [[ "$USE_PACMAN" == true ]]; then
    while IFS= read -r pkg; do
      if [[ -n "$pkg" ]]; then
        pkg_options+=("pacman:$pkg")
      fi
    done < <(pacman -Qqe 2>/dev/null)
  fi

  if [[ "$USE_FLATPAK" == true ]]; then
    while IFS= read -r app_id; do
      if [[ -n "$app_id" ]]; then
        pkg_options+=("flatpak:$app_id")
      fi
    done < <(flatpak list --app --columns=application 2>/dev/null)
  fi

  if [[ ${#pkg_options[@]} -eq 0 ]]; then
    echo -e "\e[31mNo installed packages found to remove.\e[0m"
    read -p "Press any key to continue..." -n 1
    return
  fi

  local selected_output
  selected_output=$(printf '%s\n' "${pkg_options[@]}" | fzf --multi --prompt="Select packages to remove > ")

  if [[ -z "$selected_output" ]]; then
    echo "No packages selected for removal."
    read -p "Press any key to continue..." -n 1
    return
  fi

  local pacman_pkgs=()
  local flatpak_pkgs=()

  while IFS= read -r selected; do
    case "$selected" in
      pacman:*) pacman_pkgs+=("${selected#pacman:}") ;;
      flatpak:*) flatpak_pkgs+=("${selected#flatpak:}") ;;
    esac
  done <<< "$selected_output"

  clear
  if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
    remove_pacman_pkgs "${pacman_pkgs[@]}"
  fi

  if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
    remove_flatpak_pkgs "${flatpak_pkgs[@]}"
  fi

  read -p "Press any key to continue..." -n 1
}

case "$MODE" in
  install)
    install_packages_flow
    ;;
  remove)
    remove_packages_flow
    ;;
  downgrade)
    # Existing downgrade logic
    ;;
esac