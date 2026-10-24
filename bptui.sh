#!/bin/bash

# ==============================================================================
# BPTUI - Arch Linux Package Management TUI
# Main Entry Point
# ==============================================================================

# Ensure it's run from an actual terminal (interactive session)
if [ ! -t 0 ]; then
    echo "Error: This script must be run interactively from a terminal."
    exit 1
fi

# Resolve base project directory
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# --- 1. Dependency Checks ---
command -v tput >/dev/null 2>&1 || { echo "Error: 'tput' is required but not installed."; exit 1; }
command -v pacman >/dev/null 2>&1 || { echo "Error: This tool is designed for Arch-based systems (pacman missing)."; exit 1; }

# --- 2. Source Required Modules ---
MODULES_DIR="$PROJECT_ROOT/modules"

if [[ -f "$MODULES_DIR/tui/dashboard_controller.sh" ]]; then
    source "$MODULES_DIR/tui/dashboard_controller.sh"
else
    echo "Error: Dashboard controller not found at $MODULES_DIR/tui/dashboard_controller.sh"
    exit 1
fi

# --- 3. Main Execution ---
main() {
    run_dashboard
}

main "$@"