#!/bin/bash

# ==============================================================================
# BPTUI - Dashboard Controller with Clean Terminal Refresh, Descriptions, Options & Updates
# ==============================================================================

MODE_FILE="/tmp/bptui_mode"
[[ -f "$MODE_FILE" ]] || echo "online" > "$MODE_FILE"

# Robust absolute path resolution for sourcing handlers based on your tree structure[cite: 1]
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
project_root="$(cd "$script_dir/../.." && pwd)"

# Source AUR handler
if [[ -f "$project_root/modules/pkg/aur_handler.sh" ]]; then
  source "$project_root/modules/pkg/aur_handler.sh"
fi

# Source Update manager
if [[ -f "$project_root/modules/pkg/update_manager.sh" ]]; then
  source "$project_root/modules/pkg/update_manager.sh"
fi

# Source Option handler from modules/config/
if [[ -f "$project_root/modules/config/option_handler.sh" ]]; then
  source "$project_root/modules/config/option_handler.sh"
elif [[ -f "$script_dir/../config/option_handler.sh" ]]; then
  source "$script_dir/../config/option_handler.sh"
fi

# Provide open_options wrapper if option_handler uses select_options
if ! declare -F open_options &>/dev/null && declare -F select_options &>/dev/null; then
  open_options() {
    select_options
  }
fi

get_packages() {
  local mode
  mode=$(cat "$MODE_FILE" 2>/dev/null || echo "online")

  : ${USE_PACMAN:=true}
  : ${USE_FLATPAK:=true}
  : ${USE_PARU:=true}

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

run_dashboard() {
  # Ensure the preview script wrapper exists for fzf preview support
  if [[ ! -f /tmp/pkg_preview.sh ]]; then
    cat <<EOF > /tmp/pkg_preview.sh
#!/bin/bash
source "$project_root/modules/pkg/preview_manager.sh" 2>/dev/null || source "$script_dir/../pkg/preview_manager.sh" 2>/dev/null
pkg_preview_run "\$1"
EOF
    chmod +x /tmp/pkg_preview.sh
  fi

  while true; do
    local mode
    mode=$(cat "$MODE_FILE" 2>/dev/null || echo "online")

    rm -f /tmp/bptui_toggled /tmp/bptui_options /tmp/bptui_update

    # Clean the terminal window before rendering fzf to prevent artifacts
    clear

    # Launch fzf natively with rearranged function keys and bottom preview pane
    selected=$(get_packages | fzf \
      --ansi \
      --multi \
      --height=85% \
      --border \
      --header="[TAB] Multi-select | [F5] Toggle View ($mode) | [F1] Install | [F2] Remove | [F3] Update | [F4] Downgrade | [F6] Options | [ESC] Quit" \
      --header-first \
      --prompt="Mode: $mode > " \
      --preview="MODE=$mode /tmp/pkg_preview.sh {}" \
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
        read -p "Press any key to continue..." -n 1
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
      rm -f "$MODE_FILE" /tmp/bptui_toggled /tmp/bptui_options /tmp/bptui_update
      break
    fi
  done
}