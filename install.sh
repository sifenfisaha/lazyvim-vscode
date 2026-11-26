#!/usr/bin/env bash
# Installs the LazyVim keymaps for VS Code.
#
#   ./install.sh                 VS Code
#   ./install.sh --editor codium VSCodium
#   ./install.sh --editor cursor Cursor
#
# Environment overrides:
#   NVIM_CONFIG      Neovim config directory   (default: ~/.config/nvim)
#   VSCODE_USER_DIR  editor "User" directory   (default: detected per editor and OS)
#   SKIP_EXTENSION=1 do not install the vscode-neovim extension
set -euo pipefail

editor=code
while [[ $# -gt 0 ]]; do
  case "$1" in
    --editor) editor="${2:?--editor needs a value}"; shift 2 ;;
    -h|--help) sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 1 ;;
  esac
done

case "$editor" in
  code) app_dir="Code" ;;
  code-insiders) app_dir="Code - Insiders" ;;
  codium) app_dir="VSCodium" ;;
  cursor) app_dir="Cursor" ;;
  *) echo "Unsupported editor: $editor (use code, code-insiders, codium or cursor)" >&2; exit 1 ;;
esac

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
nvim_config="${NVIM_CONFIG:-${XDG_CONFIG_HOME:-$HOME/.config}/nvim}"

if [[ -n "${VSCODE_USER_DIR:-}" ]]; then
  user_dir="$VSCODE_USER_DIR"
elif [[ "$(uname)" == "Darwin" ]]; then
  user_dir="$HOME/Library/Application Support/$app_dir/User"
else
  user_dir="${XDG_CONFIG_HOME:-$HOME/.config}/$app_dir/User"
fi

command -v python3 >/dev/null || { echo "python3 is required to merge the JSON files." >&2; exit 1; }
[[ -d "$nvim_config/lua/config" ]] || {
  echo "No LazyVim config found at $nvim_config (expected lua/config/). Set NVIM_CONFIG to your config directory." >&2
  exit 1
}
mkdir -p "$user_dir"

# 1. Extension
if [[ "${SKIP_EXTENSION:-}" != 1 ]]; then
  if command -v "$editor" >/dev/null; then
    "$editor" --install-extension asvetliakov.vscode-neovim >/dev/null
    echo "Installed the vscode-neovim extension."
    if "$editor" --list-extensions 2>/dev/null | grep -qi '^vscodevim\.vim$'; then
      echo "NOTE: the VSCodeVim extension is also installed and will fight over the same keys."
      echo "      Remove it with: $editor --uninstall-extension vscodevim.vim"
    fi
  else
    echo "NOTE: '$editor' is not on PATH. Install the 'asvetliakov.vscode-neovim' extension yourself."
  fi
fi

# 2. Neovim side
cp "$here/nvim/lua/config/vscode.lua" "$nvim_config/lua/config/vscode.lua"
keymaps="$nvim_config/lua/config/keymaps.lua"
if ! grep -q 'require("config.vscode")' "$keymaps" 2>/dev/null; then
  cat >>"$keymaps" <<'EOF'

-- Inside VS Code (vscode-neovim), point LazyVim's UI keys at VS Code commands
if vim.g.vscode then
  require("config.vscode")
end
EOF
fi
echo "Installed $nvim_config/lua/config/vscode.lua"

# 3. VS Code side: merge into existing files, keeping what is already there
python3 - "$here/vscode" "$user_dir" <<'PY'
import json, os, shutil, sys

src, dst = sys.argv[1], sys.argv[2]


def load(path):
    """Read JSON that may contain comments and trailing commas."""
    text = open(path, encoding="utf-8").read()
    out, i, n = [], 0, len(text)
    while i < n:
        c = text[i]
        if c == '"':
            j = i + 1
            while j < n and text[j] != '"':
                j += 2 if text[j] == "\\" else 1
            out.append(text[i : j + 1])
            i = j + 1
        elif text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
        elif text.startswith("/*", i):
            i = text.find("*/", i) + 2 if text.find("*/", i) != -1 else n
        elif c == ",":
            j = i + 1
            while j < n and (text[j].isspace() or text.startswith("//", j)):
                if text.startswith("//", j):
                    while j < n and text[j] != "\n":
                        j += 1
                else:
                    j += 1
            if j < n and text[j] in "]}":
                i += 1  # trailing comma
            else:
                out.append(c)
                i += 1
        else:
            out.append(c)
            i += 1
    stripped = "".join(out).strip()
    return json.loads(stripped) if stripped else None


def save(path, data):
    if os.path.exists(path):
        shutil.copy2(path, path + ".bak")
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def merge(name, combine):
    theirs, ours = os.path.join(dst, name), load(os.path.join(src, name))
    if not os.path.exists(theirs):
        shutil.copy2(os.path.join(src, name), theirs)
        print(f"Created {theirs}")
        return
    try:
        current = load(theirs)
    except ValueError as err:
        print(f"SKIPPED {theirs}: could not parse it ({err}). Merge {name} from this repo by hand.")
        return
    merged, added = combine(current, ours)
    if added:
        save(theirs, merged)
        print(f"Updated {theirs} ({added} added, backup in {name}.bak)")
    else:
        print(f"{theirs} is already up to date")


def keybindings(current, ours):
    current = current or []
    seen = {(k.get("key"), k.get("command"), k.get("when")) for k in current}
    new = [k for k in ours if (k.get("key"), k.get("command"), k.get("when")) not in seen]
    return current + new, len(new)


def settings(current, ours):
    current, added = current or {}, 0
    for key, value in ours.items():
        if isinstance(value, dict) and isinstance(current.get(key), dict):
            for k, v in value.items():
                if k not in current[key]:
                    current[key][k] = v
                    added += 1
        elif key not in current:
            current[key] = value
            added += 1
    return current, added


def tasks(current, ours):
    current = current or {"version": "2.0.0"}
    existing = current.setdefault("tasks", [])
    labels = {t.get("label") for t in existing}
    new = [t for t in ours["tasks"] if t.get("label") not in labels]
    existing.extend(new)
    return current, len(new)


merge("keybindings.json", keybindings)
merge("settings.json", settings)
merge("tasks.json", tasks)
PY

echo
echo "Done. Reload the editor window (Developer: Reload Window) to start using it."
