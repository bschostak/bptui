#!/bin/bash

function install_pacman_pkgs() {
  packages=("$@")

  if [[ -n "${packages[*]}" ]]; then
    echo "Installing selected pkgs: ${packages[*]}"
    echo -e
    sudo pacman -S --needed "${packages[@]}" || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
}

function remove_pacman_explicit_pkgs() {
  packages=("$@")

  if [[ -n "${packages[*]}" ]]; then
    echo "Removing selected pkgs: $packages"
    echo -e
    sudo pacman -Rns $(echo "${packages[@]}" | tr '\n' ' ') || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
}

function remove_pacman_all_pkgs() {
  clear

  echo -e "\e[32mSelect packages to remove\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(pacman -Q | awk '{print $1}' | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    echo "Removing selected pkgs: $packages"
    echo -e
    sudo pacman -Rns $(echo "$packages" | tr '\n' ' ') || echo "Some packages may not be available."
  else
    echo "No packages selected."
  fi
  echo -e
  read -p "Press any key to continue..." -n 1
}

function update_pacman_pkgs() {
  echo -e
  echo -e "\e[33mUpdating repo packages...\e[0m"
  echo -e

  sudo pacman -Syu

  echo -e "\e[32mRepo packages updated.\e[0m"
  echo -e
}

function clean_pacman_cache() {
  clear

  echo -e
  echo "Cleaning pacman cache..."
  echo -e

  sudo pacman -Scc

  echo "Cache cleaned."

  clear
}

function remove_orphan_packages() {
  clear
  echo -e
  echo "Removing orphan packages..."
  echo -e

  sudo pacman -Rns $(pacman -Qtdq)

  echo "Orphan packages removed."

  clear
}

#INFO: Needs refactoring
function downgrade_pacman_packages() {
  clear
  echo -e
  echo -e "\e[32mSelect packages to downgrade\e[0m"
  echo -e "\e[33mNote: To select multiple packages use SHIFT+TAB\e[0m"

  packages=$(pacman -Q | awk '{print $1}' | sort -u | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    echo -e "\e[34mFetching available versions from cache...\e[0m"

    selected_versions=""

    for pkg in $packages; do
      cached_versions=$(ls /var/cache/pacman/pkg/ | grep "^${pkg}-" | sort -V)
      if [[ -n "$cached_versions" ]]; then
        version=$(echo "$cached_versions" | fzf --height 30% --border --prompt "Select version for $pkg: ")
        selected_versions="$selected_versions /var/cache/pacman/pkg/$version"
      else
        echo -e "\e[31mNo cached versions found for $pkg\e[0m"
      fi
    done

    if [[ -n "$selected_versions" ]]; then
      echo "Downgrading selected packages..."
      sudo pacman -U --needed $selected_versions

      read -p "Press any key to continue..." -n 1
    else
      echo "No versions selected. Exiting."

      read -p "Press any key to continue..." -n 1
    fi
  else
    echo "No packages selected."

    read -p "Press any key to continue..." -n 1
  fi

  clear
}

ignore_packages() {
  clear

  echo -e "\e[32mSelect packages to ignore\e[0m"
  echo -e "\e[33mNote: Use SHIFT+TAB to select multiple packages\e[0m"

  # packages=$(pacman -Q | awk '{print $1}' | sort -u | fzf --multi --height 50% --border --prompt "Select packages: ")

  if [[ -n "$packages" ]]; then
    echo -e "\e[34mAdding packages to IgnorePkg...\e[0m"

    sudo cp /etc/pacman.conf /etc/pacman.conf.bak

    #TODO: Test if it works, it should also check if this attribute is not already uncommentend.

    sudo sed -i "/^#IgnorePkg/ c\IgnorePkg=$packages" /etc/pacman.conf

    echo -e "\e[32mPackages added to IgnorePkg successfully!\e[0m"
  else
    echo -e "\e[31mNo packages selected.\e[0m"
  fi

  clear
}