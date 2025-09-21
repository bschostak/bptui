#!/bin/bash

script_dir="$(dirname "$(realpath "$0")")"

folder_name=$(basename "$script_dir")
hidden_name=".$folder_name"

if [ -d "$HOME/$hidden_name" ]; then
    rm -rf "$HOME/$hidden_name"
    echo "The Software is already installed. Reinstalling..."
fi

cp -r "$script_dir" "$HOME/$hidden_name"

rm -rf "$HOME/$hidden_name/.git"

alias_command="alias bptui='(cd ~/.bptui/ && ./bptui.sh)'"

if ! grep -Fxq "$alias_command" ~/.bashrc; then
    echo -e "\n$alias_command" >> ~/.bashrc
    echo "Alias 'bptui' added to ~/.bashrc"
else
    echo "Alias 'bptui' already exists in ~/.bashrc"
fi

source ~/.bashrc

echo "Folder '$script_dir' copied to '$HOME/$hidden_name'"
