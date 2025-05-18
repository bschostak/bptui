#!/bin/bash

# Initialize ncurses
# tput civis  # Hide cursor
tput cup $(tput lines) 0  # Move to the bottom line

# Get terminal width
width=$(tput cols)

# Define labels
labels=("i = Install" "u = Update" "r = Remove" "q = Quit")
num_labels=${#labels[@]}

# Calculate spacing dynamically and adjust for rounding errors
spacing=$((width / num_labels))
remaining_space=$((width - (spacing * num_labels)))

# Build the bar dynamically with bold labels and full-width background
bar=""
for label in "${labels[@]}"; do
    bar+=$(printf "\e[47;30;1m%-${spacing}s\e[0m" "$label")
done

# Append spaces to ensure full width coverage
bar+=$(printf "\e[47;30m%-${remaining_space}s\e[0m" "")

# Print the dynamic bar
echo -ne "$bar\n"

# Keep the bar visible
# while true; do
#     sleep 1
# done
