#!/usr/bin/bash

script_dir="$(dirname "$(realpath "$0")")"

folder_name=$(basename "$script_dir")
hidden_name=".$folder_name"

cp -r "$script_dir" "$HOME/$hidden_name"

rm -rf "$HOME/$hidden_name/.git"

alias_command="alias bptui='(cd ~/.bptui/ && ./bptui.sh)'"

echo -e "\n$alias_command" >> ~/.bashrc

source ~/.bashrc

echo "Folder '$script_dir' copied to '$HOME/$hidden_name'"
echo "Alias 'bptui' added to ~/.bashrc"
