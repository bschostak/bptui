bptui

Universal TUI frontend for package management on Arch-based systems.

This project provides a simple, keyboard-driven terminal user interface to install, update, remove, and downgrade packages across multiple sources (Pacman, Flatpak, Paru/AUR). It generates a per-user config on first run and lets you toggle the enabled package sources from within the app.

Features:
---------

1. Install packages from multiple sources in one view (Pacman, Flatpak, Paru/AUR)
2. Update packages
   - Update all: Pacman, Flatpak, Paru (where enabled)
   - Update by source: WIP placeholder in menu
3. Remove packages
   - Unified remove across sources
   - Pacman-only bulk remove of installed packages
4. Downgrade Pacman packages from local cache (select versions interactively)
5. Interactive TUI in pure Bash (no ncurses dependency)
6. Config management
   - Auto-creates ~/.config/bptui/config.sh on first run
   - Toggle enabled sources and options via Options menu
7. Fuzzy finding with previews for descriptions (Pacman, Flatpak, Paru)

Used technologies:
------------------

- Bash (POSIX utilities: awk, sed)
- fzf (interactive selection)
- pacman (Arch package manager)
- flatpak (for Flatpak apps)
- paru (for AUR support)
- sudo (to elevate when needed)
- shunit2 (for shell unit tests; development only)

Requirements:
-------------

- Arch-based Linux (e.g., Arch, Manjaro, EndeavourOS)
- pacman installed and configured
- fzf installed
- Optional, to enable specific sources:
  - flatpak installed and configured (with Flathub remote if desired)
  - paru installed for AUR support
- sudo privileges for package operations
- For running tests: shunit2

Example installation of prerequisites (Arch):

    sudo pacman -S --needed fzf flatpak
    # if you want tests:
    sudo pacman -S shunit2

If you plan to use Flatpak and Flathub:

    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

If you plan to use Paru (AUR), install it via your preferred method.

Installation:
-------------

Option A: Quick install (adds a shell alias)

    chmod +x install.sh
    ./install.sh
    # The installer adds: alias bptui='(cd ~/.bptui/ && ./bptui.sh)'
    # Open a new shell or source your shell rc file, then run:
    bptui

Option B: Run directly from the project

    chmod +x bptui.sh
    ./bptui.sh

Usage:
------

- Main menu actions:
  - Install Package/s: Select packages from enabled sources and install them
  - Update Package/s: Update all enabled sources (Pacman, Flatpak, Paru)
  - Remove Package/s: Remove from enabled sources; includes a Pacman-only bulk remove
  - Downgrade Package/s: Downgrade Pacman packages using versions from /var/cache/pacman/pkg
  - Options: Toggle enabled sources and debug mode; writes to ~/.config/bptui/config.sh
  - Exit: Quit the app

- Selection controls:
  - Use arrow keys to navigate
  - Use TAB/Shift+TAB and Enter in lists powered by fzf (multi-select enabled)

Configuration:
--------------

A config file is created on first run at:

    ~/.config/bptui/config.sh

Keys you can control (and toggle via Options):

- USE_PACMAN=true|false
- USE_FLATPAK=true|false
- USE_PARU=true|false
- USE_YAY=true|false        (placeholder; not implemented)
- USE_SNAP=true|false       (placeholder; not implemented)
- DEBUG_MODE=true|false
- PRINT_PKG_INFO=true|false (currently used in tests)

Notes and limitations:
----------------------

- YAY and Snap are placeholders in the UI; no handlers are implemented yet.
- Downgrade currently targets Pacman packages using the local cache.
- Flatpak and Paru downgrade flows are not implemented.
- Ensure your Flatpak setup has the Flathub remote if you want rich metadata during selection.

Development & tests:
--------------------

- Tests require shunit2 at /usr/bin/shunit2.
- Run individual test files, for example:

    bash tests/config/config_controller_test.sh
    bash tests/config/option_handler_test.sh

- You can also execute all test files with a simple loop:

    find tests -name "*_test.sh" -print -exec bash {} \;

License:
--------

See LICENSE for details.
