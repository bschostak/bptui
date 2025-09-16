#!/bin/bash

# TODO: Fix this testing code.
# TODO: Update manager is working (copy the structure)

USE_PACMAN=true
USE_FLATPAK=true
USE_PARU=true
PRINT_PKG_INFO=false

pacman() { echo "extra pacpkg"; }
flatpak() { echo "org.example.flatpkg"; }
paru() { echo "aur aurpkg"; }

# fzf() {
#   echo "pacman:pacpkg\nflatpak:flatpkg\nparu:aurpkg"
# }

. ../../modules/pkg/install_manager.sh

clear() { :; }
read() { :; }

print_pacman_pkg_info() { :; }
print_flatpak_pkg_info() { :; }
print_paru_pkg_info() { :; }

install_pacman_pkgs() { PACMAN_CALLED=true; }
install_flatpak_pkgs() { FLATPAK_CALLED=true; }
install_paru_pkgs() { PARU_CALLED=true; }

setUp() {
  PACMAN_CALLED=false
  FLATPAK_CALLED=false
  PARU_CALLED=false
}

testInstallPackages_allSourcesSelected() {
  install_packages

  assertTrue "Pacman install should be triggered" "$PACMAN_CALLED"
  assertTrue "Flatpak install should be triggered" "$FLATPAK_CALLED"
  assertTrue "Paru install should be triggered" "$PARU_CALLED"
}

. /usr/bin/shunit2
