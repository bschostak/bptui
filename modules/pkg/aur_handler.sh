#!/bin/bash

# Fetch all AUR package names from the official gzipped list
function fetch_all_aur_packages() {
  curl -s "https://aur.archlinux.org/packages.gz" | gzip -cd
}

# List and select AUR packages using fzf
function select_aur_packages() {
  fetch_all_aur_packages | fzf --multi --prompt="Select AUR Packages > "
}