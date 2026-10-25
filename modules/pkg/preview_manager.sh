#!/bin/bash

GREEN="\e[32m"
RED="\e[31m"
CYAN="\e[36m"
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
  local tmp_data installed version size install_reason install_date url deps conflicts required_by desc

  tmp_data="$(mktemp)" || return 1

  (
    if pacman -Qi "$pkg" >/dev/null 2>&1; then
      echo "INSTALLED:yes"
      pacman -Qi "$pkg" 2>/dev/null
    else
      echo "INSTALLED:no"
      pacman -Si "$pkg" 2>/dev/null
    fi
  ) > "$tmp_data"

  installed="$(grep "^INSTALLED:" "$tmp_data" | cut -d: -f2)"
  version="$(grep -i "^[[:space:]]*Version" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  size="$(grep -iE "^[[:space:]]*(Installed Size|Download Size)" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  install_reason="$(grep -i "^[[:space:]]*Install Reason" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  install_date="$(grep -iE "^[[:space:]]*(Install Date|Build Date)" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  url="$(grep -i "^[[:space:]]*URL" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  deps="$(grep -i "^[[:space:]]*Depends On" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  conflicts="$(grep -i "^[[:space:]]*Conflicts With" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  required_by="$(grep -i "^[[:space:]]*Required By" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  desc="$(grep -i "^[[:space:]]*Description" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"

  rm -f "$tmp_data"

  pkg_preview_status_line "$installed"
  echo -e "${CYAN}Description:${RESET} ${desc:-No description found.}"
  [[ -n "$version" ]] && echo -e "${CYAN}Version:${RESET} $version"
  [[ -n "$size" ]] && echo -e "${CYAN}Size:${RESET} $size"
  [[ -n "$url" ]] && echo -e "${CYAN}URL:${RESET} $url"
  [[ -n "$install_date" ]] && echo -e "${CYAN}Install Date:${RESET} $install_date"
  [[ -n "$install_reason" ]] && echo -e "${CYAN}Install Reason:${RESET} $install_reason"
  [[ -n "$deps" && "$deps" != "None" ]] && echo -e "${CYAN}Dependencies:${RESET} $deps"
  [[ -n "$conflicts" && "$conflicts" != "None" ]] && echo -e "${CYAN}Conflicts:${RESET} $conflicts"
  [[ -n "$required_by" && "$required_by" != "None" ]] && echo -e "${CYAN}Required By:${RESET} $required_by"
}

pkg_preview_flatpak() {
  local mode="$1" pkg="$2"
  local appid="$pkg"

  if [[ "$appid" != *.*.* ]]; then
    local found
    found="$(flatpak search --columns=application "$appid" 2>/dev/null | awk 'NR==1{print $1}')"
    [[ -n "$found" ]] && appid="$found"
  fi

  local tmp_data installed version size url desc
  tmp_data="$(mktemp)" || return 1

  (
    if flatpak list --app --columns=application 2>/dev/null | grep -Fxq "$appid"; then
      echo "INSTALLED:yes"
      flatpak info "$appid" 2>/dev/null
    else
      echo "INSTALLED:no"
      flatpak remote-info flathub "$appid" 2>/dev/null
    fi
  ) > "$tmp_data"

  installed="$(grep "^INSTALLED:" "$tmp_data" | cut -d: -f2)"
  version="$(grep -i "^[[:space:]]*Version:" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  size="$(grep -iE "^[[:space:]]*(Download size|Installed size):" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  url="$(grep -i "^[[:space:]]*Homepage:" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  desc="$(flatpak remote-info flathub "$appid" 2>/dev/null | awk 'NR==2{print; exit}' || flatpak info "$appid" 2>/dev/null | awk 'NR==2{print; exit}')"

  rm -f "$tmp_data"

  pkg_preview_status_line "$installed"
  echo -e "${CYAN}Description:${RESET} ${desc:-No description found.}"
  [[ -n "$version" ]] && echo -e "${CYAN}Version:${RESET} $version"
  [[ -n "$size" ]] && echo -e "${CYAN}Size:${RESET} $size"
  [[ -n "$url" ]] && echo -e "${CYAN}URL:${RESET} $url"
}

pkg_preview_paru() {
  local mode="$1" pkg="$2"
  local tmp_data installed version size install_reason install_date url deps conflicts required_by desc

  tmp_data="$(mktemp)" || return 1

  (
    if pacman -Qm "$pkg" >/dev/null 2>&1; then
      echo "INSTALLED:yes"
      pacman -Qi "$pkg" 2>/dev/null || paru -Qi "$pkg" 2>/dev/null
    else
      echo "INSTALLED:no"
      paru -Si "$pkg" 2>/dev/null || pacman -Si "$pkg" 2>/dev/null
    fi
  ) > "$tmp_data"

  installed="$(grep "^INSTALLED:" "$tmp_data" | cut -d: -f2)"
  version="$(grep -i "^[[:space:]]*Version" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  size="$(grep -iE "^[[:space:]]*(Installed Size|Download Size)" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  install_reason="$(grep -i "^[[:space:]]*Install Reason" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  install_date="$(grep -iE "^[[:space:]]*(Install Date|Build Date)" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  url="$(grep -i "^[[:space:]]*URL" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  deps="$(grep -i "^[[:space:]]*(Depends On|Dependencies)" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  conflicts="$(grep -i "^[[:space:]]*Conflicts With" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  required_by="$(grep -i "^[[:space:]]*Required By" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"
  desc="$(grep -i "^[[:space:]]*Description" "$tmp_data" | head -n1 | cut -d':' -f2- | xargs)"

  rm -f "$tmp_data"

  pkg_preview_status_line "$installed"
  echo -e "${CYAN}Description:${RESET} ${desc:-No description found.}"
  [[ -n "$version" ]] && echo -e "${CYAN}Version:${RESET} $version"
  [[ -n "$size" ]] && echo -e "${CYAN}Size:${RESET} $size"
  [[ -n "$url" ]] && echo -e "${CYAN}URL:${RESET} $url"
  [[ -n "$install_date" ]] && echo -e "${CYAN}Install Date:${RESET} $install_date"
  [[ -n "$install_reason" ]] && echo -e "${CYAN}Install Reason:${RESET} $install_reason"
  [[ -n "$deps" && "$deps" != "None" ]] && echo -e "${CYAN}Dependencies:${RESET} $deps"
  [[ -n "$conflicts" && "$conflicts" != "None" ]] && echo -e "${CYAN}Conflicts:${RESET} $conflicts"
  [[ -n "$required_by" && "$required_by" != "None" ]] && echo -e "${CYAN}Required By:${RESET} $required_by"
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