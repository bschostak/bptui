#!/usr/bin/bash

source "$HOME/.config/bptui/config.sh"

source "modules/pkg/pacman_handler.sh"
source "modules/pkg/flatpak_handler.sh"
source "modules/pkg/paru_handler.sh"

function update_all_pkgs() {
    if [[ "$USE_PACMAN" == true ]]; then
    update_pacman_pkgs
    fi

    if [[ "$USE_FLATPAK" == true ]]; then
    update_flatpak_pkgs
    fi
    
    if [[ "$USE_PARU" == true ]]; then
    update_paru_pkgs
    fi
    
    if [[ "$USE_YAY" == true ]]; then
    #TODO: Implement yay update function
    echo "YAY update function not implemented yet."
    fi

    if [[ "$USE_SNAP" == true ]]; then
    #TODO: Implement snap update function
    echo "Snap update function not implemented yet."
    fi
}

function update_specific_pkgs() {
    options[0]="Pacman"
    options[1]="Flatpak"
    options[2]="Paru"
    options[3]="YAY"
    options[4]="Snap"
    #TODO: Implement the rest of the options
}