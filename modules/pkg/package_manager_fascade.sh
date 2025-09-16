#!/bin/bash

# Usage: ./package_manager_fascade.sh [install|remove|downgrade]
MODE="$1"

if [[ ! " install remove downgrade " =~ " $MODE " ]]; then
  echo "Usage: $0 [install|remove|downgrade]"
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$HOME/.config/bptui/config.sh"
source "$script_dir/pacman_handler.sh"
source "$script_dir/flatpak_handler.sh"
source "$script_dir/paru_handler.sh"
[ -f "$script_dir/info_manager.sh" ] && source "$script_dir/info_manager.sh"

print_banner() {
  case "$MODE" in
    install)
      echo -e "\e[32mSelect packages to install from available sources\e[0m"
      ;;
    remove)
      echo -e "\e[32mSelect packages to remove from available sources\e[0m"
      ;;
    downgrade)
      echo -e "\e[32mSelect packages to downgrade from available sources\e[0m"
      ;;
  esac
  echo -e "\e[33mNote: Use TAB or SHIFT+TAB to select multiple packages\e[0m"
}

# The preview script
cat <<'EOF' > /tmp/pkg_preview.sh
#!/bin/bash
IFS=":" read -r source pkg <<< "$1"
case "$source" in
  pacman)
    if [[ "$MODE" == install ]]; then
      pacman -Si "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
    else
      pacman -Qi "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
    fi
    ;;
  flatpak)
    flatpak info "$pkg" 2>/dev/null | grep -i '^Description' || echo "No description found."
    ;;
  paru)
    paru -Si "$pkg" 2>/dev/null | grep -E '^Description' || echo "No description found."
    ;;
  * )
    echo "Unknown package source."
    ;;
esac
EOF
chmod +x /tmp/pkg_preview.sh

main() {
  clear
  print_banner

  # Build the unified list and show fzf (avoid eval and ensure grouping always closes)
  pkg_list=$(
    {
      case "$MODE" in
        install)
          $USE_PACMAN && pacman -Sl | awk '{print "pacman:" $2}'
          $USE_FLATPAK && flatpak remote-ls --app | awk '{print "flatpak:" $2}'
          $USE_PARU && paru -Sl aur | awk '{print "paru:" $2}'
          ;;
        remove)
          $USE_PACMAN && pacman -Qen | awk '{print "pacman:" $1}'
          $USE_FLATPAK && flatpak list | awk '{print "flatpak:" $2}'
          $USE_PARU && paru -Qm | awk '{print "paru:" $1}'
          ;;
        downgrade)
          $USE_PACMAN && pacman -Q | awk '{print "pacman:" $1}'
          ;;
      esac
    } | sort -u | fzf --multi --height 60% --border --preview "MODE=$MODE /tmp/pkg_preview.sh {}" --preview-window=right:60% --prompt 'Select packages: '
  )

  if [[ -z "$pkg_list" ]]; then
    echo "No packages selected."
    return
  fi

  # Split by package manager
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

  # Post-selection operations
  case "$MODE" in
    install)
      if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
        clear; $PRINT_PKG_INFO && print_pacman_pkg_info "${pacman_pkgs[@]}"; install_pacman_pkgs "${pacman_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
        clear; $PRINT_PKG_INFO && print_flatpak_pkg_info "${flatpak_pkgs[@]}"; install_flatpak_pkgs "${flatpak_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      if [[ ${#paru_pkgs[@]} -gt 0 ]]; then
        clear; $PRINT_PKG_INFO && print_paru_pkg_info "${paru_pkgs[@]}"; install_paru_pkgs "${paru_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      ;;
    remove)
      if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
        clear; remove_pacman_explicit_pkgs "${pacman_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      if [[ ${#flatpak_pkgs[@]} -gt 0 ]]; then
        clear; remove_flatpak_pkgs "${flatpak_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      ;;
    downgrade)
      if [[ ${#pacman_pkgs[@]} -gt 0 ]]; then
        clear; downgrade_pacman_packages "${pacman_pkgs[@]}"; echo -e; read -p "Press any key to continue..." -n 1
      fi
      # Add similar blocks for flatpak or paru here if handlers defined
      ;;
  esac
}

main
