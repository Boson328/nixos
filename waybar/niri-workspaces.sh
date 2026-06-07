#!/usr/bin/env bash
# niri のワークスペースとウィンドウ情報を取得してwaybar用JSONを出力

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
                apps: (
                    $wins
                    | map(select(.workspace_id == $ws.id))
                    | map(.app_id // "unknown")
                )
            }
        ) |
        map(
            . as $ws |
            {
                idx: .idx,
                is_active: .is_active,
                icons: (
                    .apps | map(
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
            "<span" +
            (if .is_active then " foreground=\"#7aa2f7\"" else " foreground=\"#565f89\"" end) +
            ">" +
            (if (.icons | length) > 0 then (.icons | join(" ")) else "󰝦" end) +
            "</span>"
        ) |
        join("  ")
    ')

    echo "{\"text\": \"$output\", \"tooltip\": \"\", \"class\": \"\"}"
}

# 初回出力
get_workspaces

# niri のイベントを監視してリアルタイム更新
niri msg --json event-stream 2>/dev/null | while IFS= read -r line; do
    event=$(echo "$line" | jq -r 'keys[0]' 2>/dev/null)
    case "$event" in
        WorkspaceActivated|WindowOpenedOrChanged|WindowClosed|WorkspacesChanged)
            get_workspaces
            ;;
    esac
done
