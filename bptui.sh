#!/bin/bash

source "modules/config/config_controller.sh"
source "modules/config/option_handler.sh"
source "modules/tui/tui_controller.sh"

source "modules/pkg/pacman_handler.sh"
source "modules/pkg/flatpak_handler.sh"
source "modules/pkg/paru_handler.sh"

source "modules/pkg/update_manager.sh"
source "modules/pkg/install_manager.sh"
source "modules/pkg/remove_manager.sh"

setup_config

source "$HOME/.config/bptui/config.sh"

function print_logo() {
  echo -e "\n\e[1;36m"
  echo "██████╗ ██████╗ ████████╗██╗   ██╗██╗"
  echo "██╔══██╗██╔══██╗╚══██╔══╝██║   ██║██║"
  echo "██████╔╝██████╔╝   ██║   ██║   ██║██║"
  echo "██╔══██╗██╔═══╝    ██║   ██║   ██║██║"
  echo "██████╔╝██║        ██║   ╚██████╔╝██║"
  echo "╚═════╝ ╚═╝        ╚═╝    ╚═════╝ ╚═╝"
  echo -e "\e[0m"
}

function open_update_pkgs_menu() {
  clear

  echo -e "\e[4mType Of Updates\e[24m"
  ui_widget_select -k update_all_pkgs update_specific_pkgs main -i "Update All Packages" "Update Specific Packages" "Go Back"
  if [[ "${UI_WIDGET_RC}" == "update_all_pkgs" ]]; then
    update_all_pkgs
  elif [[ "${UI_WIDGET_RC}" == "update_specific_pkgs" ]]; then
    update_specific_pkgs
  elif [[ "${UI_WIDGET_RC}" == "main" ]]; then
    return
  fi
}

function open_remove_pkgs_menu() {
  clear

  echo -e "\e[4mRemove Packages\e[24m"
  ui_widget_select -k remove_packages remove_pacman_all_pkgs main -i "Explicit installed" "Native installed" "Go Back"

  if [[ "${UI_WIDGET_RC}" == "remove_packages" ]]; then
    remove_packages
  elif [[ "${UI_WIDGET_RC}" == "remove_pacman_all_pkgs" ]]; then
    remove_pacman_all_pkgs
  elif [[ "${UI_WIDGET_RC}" == "main" ]]; then
    return
  fi
}

function downgrade_packages() {
  downgrade_pacman_packages

  if [ -n "$pacman_cached_packages" ]; then
    read -p "Do you want to add packages to ignore list? (y/n): " user_input

    if [[ "$user_input" == "y" ]]; then
      ignore_packages
    fi
  fi

  read -p "Press any key to continue..." -n 1
}

function open_options() {
  select_options
  read -p "Press any key to continue..." -n 1
}

function main() {
  while true; do
    clear

    print_logo
    echo -e "\e[4mSelect Action\e[24m"
    ui_widget_select -k install_packages open_update_pkgs_menu open_remove_pkgs_menu downgrade_packages open_options exit_app -i "Install Package/s" "Update Package/s" "Remove Package/s" "Downgrade Package/s" "Options" "Exit"

    if [[ "${UI_WIDGET_RC}" == "open_options" ]]; then
      open_options
    elif [[ "${UI_WIDGET_RC}" == "install_packages" ]]; then
      install_packages
    elif [[ "${UI_WIDGET_RC}" == "open_update_pkgs_menu" ]]; then
      open_update_pkgs_menu
    elif [[ "${UI_WIDGET_RC}" == "open_remove_pkgs_menu" ]]; then
      open_remove_pkgs_menu
    elif [[ "${UI_WIDGET_RC}" == "downgrade_packages" ]]; then
      downgrade_packages
    elif [[ "${UI_WIDGET_RC}" == "exit_app" ]]; then
      clear
      echo "Exiting application..."
      exit 0
    fi

    # echo "Return code: $?"
    # echo "Selected key: ${UI_WIDGET_RC}";
  done
}

main
