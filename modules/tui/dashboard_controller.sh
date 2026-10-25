#!/bin/bash

# ==============================================================================
# BPTUI - Dashboard Controller with Clean Terminal Refresh, Descriptions, Options & Updates
# ==============================================================================

# --- Configuration & Paths ---
MODE_FILE="/tmp/bptui_mode"
PREVIEW_WRAPPER="/tmp/pkg_preview.sh"

[[ -f "$MODE_FILE" ]] || echo "online" > "$MODE_FILE"

# Robust absolute path resolution
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"

# --- Sourcing Helper ---
source_module() {
  for path in "$@"; do
    if [[ -f "$path" ]]; then
      source "$path"
      return 0
    fi
  done
  return 1
}

# Source required modules with fallback options
source_module "$project_root/modules/pkg/aur_handler.sh"
source_module "$project_root/modules/pkg/update_manager.sh"
source_module \
  "$project_root/modules/config/option_handler.sh" \
  "$script_dir/../config/option_handler.sh"

# Provide open_options wrapper if option_handler uses select_options
if ! declare -F open_options &>/dev/null && declare -F select_options &>/dev/null; then
  open_options() {
    select_options
  }
fi

# --- Package Fetcher ---
get_packages() {
  local mode
  mode=$(cat "$MODE_FILE" 2>/dev/null || echo "online")

  : "${USE_PACMAN:=true}"
  : "${USE_FLATPAK:=true}"
  : "${USE_PARU:=true}"

  {
    case "$mode" in
      online)
        $USE_PACMAN && pacman -Sl 2>/dev/null | awk '{print "pacman:" $2}'
        $USE_FLATPAK && flatpak remote-ls --app --columns=application 2>/dev/null | awk '{print "flatpak:" $1}'
        if $USE_PARU && declare -F fetch_all_aur_packages &>/dev/null; then
          fetch_all_aur_packages 2>/dev/null | awk '{print "paru:" $1}'
        elif $USE_PARU && command -v paru &>/dev/null; then
          paru -Slq --color=never 2>/dev/null | awk '{print "paru:" $1}'
        fi
        ;;
      installed)
        $USE_PACMAN && pacman -Q 2>/dev/null | awk '{print "pacman:" $1}'
        $USE_FLATPAK && flatpak list --app --columns=application 2>/dev/null | awk '{print "flatpak:" $1}'
        if command -v paru &>/dev/null; then
          paru -Qm --color=never 2>/dev/null | awk '{print "paru:" $1}'
        fi
        ;;
    esac
  } | grep -v '^$' | sort -u
}

# --- Dashboard Runner ---
setup_preview_wrapper() {
  local preview_script="$project_root/modules/pkg/preview_manager.sh"
  [[ -f "$preview_script" ]] || preview_script="$script_dir/../pkg/preview_manager.sh"

  cat <<EOF > "$PREVIEW_WRAPPER"
#!/bin/bash
source "$preview_script" 2>/dev/null
pkg_preview_run "\$1"
EOF
  chmod +x "$PREVIEW_WRAPPER"
}

run_dashboard() {
  setup_preview_wrapper

  while true; do
    local mode
    mode=$(cat "$MODE_FILE" 2>/dev/null || echo "online")

    rm -f /tmp/bptui_toggled /tmp/bptui_options /tmp/bptui_update

    # Clean terminal window to prevent rendering artifacts
    clear

    # Launch fzf
    selected=$(get_packages | fzf \
      --ansi \
      --multi \
      --height=85% \
      --border \
      --header="[TAB] Multi-select | [F5] Toggle View ($mode) | [F1] Install | [F2] Remove | [F3] Update | [F4] Downgrade | [F6] Options | [ESC] Quit" \
      --header-first \
      --prompt="Mode: $mode > " \
      --preview="MODE=$mode $PREVIEW_WRAPPER {}" \
      --preview-window=down:30%:wrap \
      --bind="enter:ignore" \
      --bind="f5:execute(
          current=\$(cat $MODE_FILE);
          if [ \"\$current\" = 'online' ]; then
            echo 'installed' > $MODE_FILE;
          else
            echo 'online' > $MODE_FILE;
          fi;
          touch /tmp/bptui_toggled
        )+abort" \
      --bind="f6:execute(clear; touch /tmp/bptui_options)+abort" \
      --bind="f3:execute(clear; touch /tmp/bptui_update)+abort" \
      --bind="f1:execute(clear; bash modules/pkg/package_manager_fascade.sh install {+})" \
      --bind="f2:execute(clear; bash modules/pkg/package_manager_fascade.sh remove {+})" \
      --bind="f4:execute(clear; bash modules/pkg/package_manager_fascade.sh downgrade {+})" \
      --bind="f7:abort" \
      --layout=reverse
    )

    local exit_code=$?

    # Handle F3 Update trigger
    if [[ -f /tmp/bptui_update ]]; then
      rm -f /tmp/bptui_update
      if declare -F update_all_pkgs &>/dev/null; then
        update_all_pkgs
      else
        echo "Error: update_all_pkgs function not found."
        read -n 1 -p "Press any key to continue..."
      fi
      continue
    fi

    # Handle F6 Options trigger
    if [[ -f /tmp/bptui_options ]]; then
      rm -f /tmp/bptui_options
      if declare -F open_options &>/dev/null; then
        open_options
      elif declare -F select_options &>/dev/null; then
        select_options
      fi
      continue
    fi

    if [[ -f /tmp/bptui_toggled ]]; then
      rm -f /tmp/bptui_toggled
      continue
    fi

    if [[ $exit_code -eq 130 ]] || [[ $exit_code -eq 1 ]]; then
      clear
      rm -f "$MODE_FILE" "$PREVIEW_WRAPPER" /tmp/bptui_toggled /tmp/bptui_options /tmp/bptui_update
      break
    fi
  done
}