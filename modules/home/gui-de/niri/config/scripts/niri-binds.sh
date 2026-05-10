#!/usr/bin/env bash
# niri 快捷键查看器 — 解析 KDL 配置，ghostty + fzf 交互展示
NIRI_DIR="${NIRI_CONFIG_DIR:-$HOME/.config/niri}"

parse_kdl() {
  grep -Rhv '^[[:space:]]*//' "$NIRI_DIR" --include="*.kdl" 2>/dev/null \
  | awk '
    function trim(s) { gsub(/^[ \t]+|[ \t]+$/, "", s); return s }

    /^[[:space:]]*$/    { next }
    /^[[:space:]]*binds[[:space:]]*\{/ { in_binds = 1; depth += cnt_braces($0); next }
    !in_binds           { next }

    {
      depth += cnt_braces($0)
      if (depth <= 0) { in_binds = 0; depth = 0; next }

      desc = ""
      if (match($0, /hotkey-overlay-title="([^"]+)"/, m)) desc = m[1]
      if (desc == "null") desc = ""

      action = ""
      if (match($0, /\{([^}]+)\}/, m)) {
        action = m[1]
        gsub(/^[[:space:];]+|[[:space:];]+$/, "", action)
        gsub(/[[:space:]]+/, " ", action)
        sub(/^spawn-sh?[[:space:]]+"?/, "", action)
        gsub(/"/, "", action)
        sub(/^niri msg action /, "", action)
        sub(/^dms ipc call /, "dms: ", action)
        sub(/^noctalia-shell ipc call /, "noctalia: ", action)
      }

      key = $0
      sub(/[[:space:]]*\{.*/, "", key)
      gsub(/hotkey-overlay-title="[^"]*"/, "", key)
      gsub(/cooldown-ms=[0-9]+/, "", key)
      gsub(/allow-when-locked=true/, "", key)
      gsub(/allow-inhibiting=false/, "", key)
      gsub(/repeat=false/, "", key)
      key = trim(key)
      if (key == "") next

      text = (desc != "" ? desc : (action != "" ? action : ""))
      if (text != "")
        printf "%s │ %s\n", key, text
      else
        printf "%s\n", key
    }

    function cnt_braces(s) { return gsub(/\{/, "&", s) - gsub(/\}/, "&", s) }
  ' | sort -u
}

items=$(parse_kdl)

if [[ -z $items ]]; then
  echo "未找到快捷键" >&2
  exit 1
fi

if [[ ${1:-} == "--print" || ${1:-} == "-p" ]]; then
  echo "$items" | column -t -s '│' -o '│'
fi

# 用 column 对齐，pipe 到 fzf 搜索
FZF_CMD='echo "$ITEMS" | column -t -s "│" -o "│" | fzf --reverse --prompt="󰌌 快捷键: " --info=hidden --border=none --exact --preview-window=hidden'

if command -v ghostty >/dev/null 2>&1; then
  ITEMS="$items" ghostty --title="快捷键" -e bash -c "$FZF_CMD"
elif command -v kitty >/dev/null 2>&1; then
  ITEMS="$items" kitty --title "快捷键" \
    -o "initial_window_width=90c" -o "initial_window_height=24c" bash -c "$FZF_CMD"
elif command -v foot >/dev/null 2>&1; then
  ITEMS="$items" foot --title "快捷键" \
    --window-size-chars=90x24 bash -c "$FZF_CMD"
else
  echo "$items" | column -t -s '│' -o '│' | fzf --reverse --prompt="󰌌 快捷键: " --info=hidden --border=none --preview-window=hidden
fi
