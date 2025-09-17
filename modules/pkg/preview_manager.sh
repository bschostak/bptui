#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

pkg_preview_status_line() {
  local installed="$1"
  if [[ "$installed" == "yes" ]]; then
    echo -e "Status: ${GREEN}Installed${RESET}"
  else
    echo -e "Status: ${RED}Not installed${RESET}"
  fi
}

pkg_preview_pacman() {
  local mode="$1" pkg="$2"
  local installed="no"
  if pacman -Qi "$pkg" >/dev/null 2>&1; then installed="yes"; fi
  pkg_preview_status_line "$installed"
  if [[ "$mode" == "install" ]]; then
    pacman -Si "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
  else
    pacman -Qi "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
  fi
}

pkg_preview_flatpak() {
  local mode="$1" pkg="$2"
  local appid="$pkg"
  if [[ "$appid" != *.*.* ]]; then
    local found
    found="$(flatpak search --columns=application "$appid" 2>/dev/null | awk 'NR==1{print $1}')"
    [[ -n "$found" ]] && appid="$found"
  fi
  local installed="no"
  if flatpak list --app --columns=application 2>/dev/null | grep -Fxq "$appid"; then installed="yes"; fi
  pkg_preview_status_line "$installed"
  flatpak remote-info flathub "$appid" 2>/dev/null | sed -n '2p' || echo "No description found."
}

pkg_preview_paru() {
  local mode="$1" pkg="$2"
  local installed="no"
  if pacman -Qi "$pkg" >/dev/null 2>&1; then installed="yes"; fi
  pkg_preview_status_line "$installed"
  if [[ "$mode" == "install" ]]; then
    paru -Si "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
  else
    pacman -Qi "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
  fi
}

pkg_preview_dispatch() {
  local mode="$1" source="$2" pkg="$3"
  case "$source" in
    pacman) pkg_preview_pacman "$mode" "$pkg" ;;
    flatpak) pkg_preview_flatpak "$mode" "$pkg" ;;
    paru) pkg_preview_paru "$mode" "$pkg" ;;
    *) echo "Unknown package source." ;;
  esac
}

pkg_preview_run() {
  local arg="$1"
  local source pkg
  IFS=":" read -r source pkg <<< "$arg"
  pkg_preview_dispatch "${MODE:-install}" "$source" "$pkg"
}
