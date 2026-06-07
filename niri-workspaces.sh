#!/usr/bin/env bash

get_workspaces() {
    workspaces=$(niri msg --json workspaces 2>/dev/null)
    windows=$(niri msg --json windows 2>/dev/null)

    if [ -z "$workspaces" ] || [ -z "$windows" ]; then
        echo '{"text": "", "tooltip": "", "class": ""}'
        return
    fi

    output=$(echo "$workspaces" | jq -r --argjson wins "$windows" '
        sort_by(.idx) |
        map(
            . as $ws |
            {
                idx: .idx,
                is_active: .is_active,
                icons: (
                    $wins
                    | map(select(.workspace_id == $ws.id))
                    | map(.app_id // "unknown")
                    | map(
                        if test("ghostty|terminal|alacritty|kitty|foot") then "󰆍"
                        elif test("firefox|librewolf") then "󰈹"
                        elif test("chromium|google-chrome|brave") then "󰊯"
                        elif test("figma") then "󰙏"
                        elif test("code|vscode|vscodium") then "󰨞"
                        elif test("discord|vesktop") then "󰙯"
                        elif test("slack") then "󰒱"
                        elif test("spotify") then "󰓇"
                        elif test("nautilus|thunar|nemo|dolphin") then "󰉋"
                        elif test("obsidian") then "󱞁"
                        elif test("gimp") then "󰏃"
                        elif test("vlc|mpv") then "󰕼"
                        else "󰣆"
                        end
                    )
                )
            }
        ) |
        map(
            if .is_active then
                "ACTIVE:" + (if (.icons | length) > 0 then (.icons | join(" ")) else "󰝦" end)
            else
                "INACTIVE:" + (if (.icons | length) > 0 then (.icons | join(" ")) else "󰝦" end)
            end
        ) |
        join("|")
    ')

    # シェル側でHTMLを組み立ててダブルクォートを避ける
    result=""
    first=true
    IFS='|' read -ra parts <<< "$output"
    for part in "${parts[@]}"; do
        if [ "$first" != "true" ]; then
            result="${result}  "
        fi
        first=false
        if [[ "$part" == ACTIVE:* ]]; then
            icons="${part#ACTIVE:}"
            result="${result}<span foreground='#ffffff'>${icons}</span>"
        else
            icons="${part#INACTIVE:}"
            result="${result}<span foreground='#cccccc'>${icons}</span>"
        fi
    done

    printf '{"text": "%s", "tooltip": "", "class": ""}\n' "$result"
}

get_workspaces

niri msg --json event-stream 2>/dev/null | while IFS= read -r line; do
    event=$(echo "$line" | jq -r 'keys[0]' 2>/dev/null)
    case "$event" in
        WorkspaceActivated|WindowOpenedOrChanged|WindowClosed|WorkspacesChanged)
            get_workspaces
            ;;
    esac
done
