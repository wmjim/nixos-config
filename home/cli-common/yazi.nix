{ config, pkgs, ... }:

{
  xdg.configFile = {
    "yazi/yazi.toml".text = ''
[mgr]
ratio = [ 1, 4, 3 ]
sort_by = "alphabetical"
sort_sensitive = false
sort_reverse = false
sort_dir_first = true
linemode = "none"
show_hidden = false
show_symlink = true
scrolloff = 5

[preview]
tab_size = 2
max_width = 600
max_height = 900

[opener]
edit = [
	{ run = "$EDITOR \"$1\"", desc = "$EDITOR", block = true, for = "unix" },
]
open = [
	{ run = "xdg-open \"$1\"", desc = "Open", for = "linux" },
]
extract = [
	{ run = "unar \"$1\"", desc = "Extract here" },
]
play = [
	{ run = "mpv \"$1\"", desc = "Play", orphan = true },
]

[open]
rules = [
	{ name = "*/", use = [ "edit", "open" ] },
	{ mime = "text/*", use = [ "edit", "open" ] },
	{ mime = "image/*", use = [ "open" ] },
	{ mime = "video/*", use = [ "play", "open" ] },
]

[tasks]
micro_workers = 10
macro_workers = 25

[plugin]
preloaders = [
	{ mime = "image/*", run = "preloader" },
]

previewers = [
	{ name = "*/", run = "folder", sync = true },
	{ mime = "text/*", run = "code" },
	{ mime = "image/*", run = "image" },
]

[input]
cursor_blink = false

[log]
enabled = false
'';

    "yazi/theme.toml".text = ''
# Catppuccin Frappe
[mgr]
cwd = { fg = "#8caaee" }

[mgr.directory]
style = { fg = "#8caaee", bold = true }

[mgr.file]
style = { fg = "#c6d0f5" }

[mgr.selected]
style = { fg = "#c6d0f5", bg = "#414559", bold = true }

[status]
separator_open = ""
separator_close = ""
separator_style = { fg = "#414559", bg = "#414559" }

mode_normal = { fg = "#303446", bg = "#8caaee", bold = true }
mode_select = { fg = "#303446", bg = "#a6d189", bold = true }

progress_normal = { fg = "#8caaee", bg = "#414559" }
progress_error = { fg = "#e78284", bg = "#414559" }

permissions_t = { fg = "#a6d189" }
permissions_r = { fg = "#e5c890" }
permissions_w = { fg = "#e78284" }
permissions_x = { fg = "#8caaee" }

[select]
open_title = { fg = "#c6d0f5" }
open_border = { fg = "#8caaee" }

[input]
border = { fg = "#8caaee" }
title = { fg = "#c6d0f5" }
value = { fg = "#c6d0f5" }
selected = { reversed = true }

[completion]
active = { fg = "#303446", bg = "#8caaee" }
inactive = { fg = "#c6d0f5" }

[tasks]
border = { fg = "#414559" }
title = { fg = "#c6d0f5" }

[tasks.table]
border = { fg = "#414559" }
active = { fg = "#e5c890" }

[which]
mask = { bg = "#414559", bold = true }
cand = { fg = "#8caaee" }
rest = { fg = "#949cbb" }
desc = { fg = "#ca9ee6" }
separator = "  "

[help]
on = { fg = "#a6d189" }
exec = { fg = "#8caaee" }
desc = { fg = "#949cbb" }
hovered = { bg = "#414559", bold = true }

[filetype]
rules = [
	{ mime = "image/*", fg = "#ca9ee6" },
	{ mime = "video/*", fg = "#ef9f76" },
	{ name = "*.zip", fg = "#f4b8e4" },
	{ name = "*.pdf", fg = "#e78284" },
	{ name = "*.py", fg = "#e5c890" },
	{ name = "*.js", fg = "#e5c890" },
	{ name = "*.nix", fg = "#8caaee" },
]
'';

    "yazi/keymap.toml".text = ''
# Keymap
keymap = [
	{ on = ["q"], run = "quit", desc = "Quit" },
	{ on = ["Q"], run = "quit --no-cwd", desc = "Quit without cwd" },
	{ on = ["esc"], run = "escape", desc = "Escape" },
	{ on = ["e"], run = "open", desc = "Open" },
	{ on = ["."], run = "toggle_hidden", desc = "Toggle hidden" },
	{ on = [" "], run = "select --state=none", desc = "Select" },
	{ on = ["v"], run = "select_all --state=true", desc = "Select all" },
	{ on = ["V"], run = "select_all --state=false", desc = "Unselect all" },
	{ on = ["\n"], run = "enter", desc = "Enter" },
	{ on = ["y"], run = "copy", desc = "Copy" },
	{ on = ["x"], run = "cut", desc = "Cut" },
	{ on = ["p"], run = "paste", desc = "Paste" },
	{ on = ["d"], run = "delete", desc = "Delete" },
	{ on = ["a"], run = "create", desc = "Create" },
	{ on = ["r"], run = "rename", desc = "Rename" },
	{ on = [":"], run = "shell", desc = "Shell" },
	{ on = ["/"], run = "search", desc = "Search" },
	{ on = ["n"], run = "search_next", desc = "Search next" },
	{ on = ["N"], run = "search_prev", desc = "Search prev" },
	{ on = ["["], run = "parent", desc = "Go to parent" },
	{ on = ["]"], run = "child", desc = "Go to child" },
	{ on = ["~"], run = "home", desc = "Go to home" },
	{ on = ["z"], run = "jump", desc = "Jump" },
	{ on = ["h"], run = "help", desc = "Help" },
]
'';
  };

  home.packages = with pkgs; [
    unar
  ];
}
