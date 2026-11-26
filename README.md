# lazyvim-vscode

Use your [LazyVim](https://www.lazyvim.org) keybindings in VS Code.

VS Code runs your real Neovim config through the
[VS Code Neovim](https://github.com/vscode-neovim/vscode-neovim) extension, so
motions, text objects, registers, macros and flash (`s` / `S`) already behave
the same. What does not carry over is every key that opens a Neovim plugin
window: the file picker, neo-tree, trouble, gitsigns, nvim-dap and so on. Those
plugins are switched off inside VS Code, so `<leader>ff` or `<leader>e` does
nothing.

This config fills that gap. It points about 190 LazyVim keys at the matching
VS Code command, and adds the few bindings VS Code needs for the places Neovim
does not control (file explorer, terminal, side panels).

Your terminal Neovim is not affected: the mappings load only when Neovim is
running inside VS Code.

## Requirements

- Neovim 0.10 or newer with a [LazyVim](https://www.lazyvim.org) config
- VS Code, VSCodium or Cursor
- `python3` (used by the installer to merge JSON files)
- Optional: [lazygit](https://github.com/jesseduffield/lazygit) for `<leader>gg`

## Install

```sh
git clone https://github.com/sifenfisaha/lazyvim-vscode.git
cd lazyvim-vscode
./install.sh
```

Then reload the editor window (`Developer: Reload Window`).

For another editor, pass `--editor codium`, `--editor cursor` or
`--editor code-insiders`.

The installer:

1. Installs the `asvetliakov.vscode-neovim` extension.
2. Copies `nvim/lua/config/vscode.lua` into your Neovim config and adds three
   lines to `lua/config/keymaps.lua` that load it when `vim.g.vscode` is set.
3. Merges `vscode/keybindings.json`, `vscode/settings.json` and
   `vscode/tasks.json` into your editor's `User` folder. Existing entries are
   kept, and each changed file gets a `.bak` copy first. Comments in a file
   that gets changed are not preserved (they remain in the `.bak` copy).

It is safe to run again after pulling an update.

If you use the **VSCodeVim** extension, remove it. Both extensions grab the
same keys:

```sh
code --uninstall-extension vscodevim.vim
```

### Manual install

1. Install the `asvetliakov.vscode-neovim` extension.
2. Copy `nvim/lua/config/vscode.lua` to `~/.config/nvim/lua/config/vscode.lua`.
3. Add this to the end of `~/.config/nvim/lua/config/keymaps.lua`:

   ```lua
   if vim.g.vscode then
     require("config.vscode")
   end
   ```

4. Add the entries from the three files in `vscode/` to your own
   `keybindings.json`, `settings.json` and user `tasks.json`.

## Keys

`<leader>` is space, as in LazyVim.

### Files and search

| Key | Action |
| --- | --- |
| `<leader><space>` `<leader>ff` | Find files |
| `<leader>,` `<leader>fb` | Open editors (buffers) |
| `<leader>fr` | Recent files and folders |
| `<leader>fn` | New file |
| `<leader>e` `<leader>fe` | File explorer |
| `<leader>/` `<leader>sg` | Grep across the project |
| `<leader>sw` | Grep the word under the cursor or the selection |
| `<leader>sr` | Search and replace in files |
| `<leader>ss` / `<leader>sS` | Symbols in file / in workspace |
| `<leader>sk` | Keyboard shortcuts |
| `<leader>st` | Find TODO comments |
| `<leader>:` `<leader>sC` | Command palette |

### Buffers and windows

| Key | Action |
| --- | --- |
| `<S-h>` `<S-l>` `[b` `]b` | Previous / next editor tab |
| `[B` `]B` | Move tab left / right |
| `<leader>bb` | Switch to the other buffer |
| `<leader>bd` | Close buffer |
| `<leader>bo` | Close other buffers |
| `<leader>bl` `<leader>br` | Close buffers to the left / right |
| `<leader>bp` | Pin buffer |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | Move between windows, sidebar and terminal |
| `<C-Up>` `<C-Down>` `<C-Left>` `<C-Right>` | Resize window |
| `<leader>-` `<leader>\|` | Split below / right |
| `<leader>wd` | Close window |
| `<leader>wm` | Maximize window |
| `<leader>uz` | Zen mode |
| `<A-j>` `<A-k>` | Move line down / up |
| `<C-s>` | Save and return to normal mode |

### Code

| Key | Action |
| --- | --- |
| `gd` `gD` `gr` `gI` `gy` | Definition, declaration, references, implementation, type |
| `K` / `gK` | Hover / signature help |
| `<leader>ca` / `<leader>cA` | Code action / source action |
| `<leader>cr` | Rename symbol |
| `<leader>cf` | Format file or selection |
| `<leader>cs` | Symbol outline |
| `<leader>co` | Organize imports |
| `]d` `[d` | Next / previous diagnostic |
| `]]` `[[` `<A-n>` `<A-p>` | Next / previous reference of the word under the cursor |
| `<leader>xx` | Problems panel |
| `<leader>tt` `<leader>tr` | Run tests in file / nearest test |

### Git

| Key | Action |
| --- | --- |
| `<leader>gg` | lazygit in a terminal |
| `<leader>gs` | Source control view |
| `<leader>gl` | Commit graph |
| `<leader>gf` | File history (timeline) |
| `<leader>gb` | Toggle blame |
| `]h` `[h` | Next / previous hunk |
| `<leader>ghs` `<leader>ghr` `<leader>ghu` | Stage, reset, unstage hunk |
| `<leader>ghS` `<leader>ghR` | Stage / reset whole file |
| `<leader>ghp` | Preview hunk |
| `<leader>ghd` | Diff this file |

### Debug

| Key | Action |
| --- | --- |
| `<leader>db` / `<leader>dB` | Toggle / conditional breakpoint |
| `<leader>dc` | Start or continue |
| `<leader>di` `<leader>do` `<leader>dO` | Step into, out, over |
| `<leader>dC` | Run to cursor |
| `<leader>dP` `<leader>dt` | Pause / terminate |
| `<leader>dr` | Debug console |
| `<leader>du` | Debug view |
| `<leader>de` | Evaluate under cursor |

### Terminal and UI

| Key | Action |
| --- | --- |
| `<C-/>` `<leader>ft` | Toggle terminal (works from inside it too) |
| `<leader>uw` | Toggle word wrap |
| `<leader>ul` / `<leader>uL` | Toggle line numbers / relative numbers |
| `<leader>uh` | Toggle inlay hints |
| `<leader>uf` | Toggle format on save |
| `<leader>uC` | Pick color theme |
| `<leader>l` | Extensions view (stands in for Lazy) |
| `<leader>qq` | Close window |

### File explorer

With the explorer focused: `j` `k` `h` `l` to move, `a` new file, `A` new
folder, `r` rename, `d` delete, `y` copy, `x` cut, `p` paste, `/` filter, and
`q` or `<leader>e` to close it. Most of these come from the vscode-neovim
extension itself.

### Copilot inline suggestions

`<Tab>` accept, `<A-w>` accept word, `<A-l>` accept line, `<A-]>` / `<A-[>`
next / previous, `<C-]>` dismiss.

The full list is in [`nvim/lua/config/vscode.lua`](nvim/lua/config/vscode.lua)
and [`vscode/keybindings.json`](vscode/keybindings.json).

## Optional extras

### `jj` or `jk` to leave insert mode

Insert mode is handled by VS Code, so an insert-mode mapping in your Neovim
config does not apply. Add this to your `settings.json` instead:

```json
"vscode-neovim.compositeKeys": {
  "jj": { "command": "vscode-neovim.escape" }
}
```

## What is different from Neovim

- **Vim tabs** have no counterpart. `<leader><tab>…` acts on editor groups.
- **`]e` and `]w`** go to the next diagnostic of any severity. VS Code cannot
  filter that jump by severity.
- **Not mapped:** session restore (`<leader>qs`), the which-key popup, rename
  file (`<leader>cR`) and `<C-k>` signature help in insert mode.
- **Insert mode** is plain VS Code, so completion, snippets and auto pairs
  come from VS Code and not from blink.cmp or mini.pairs.

## Customizing

`vscode.lua` is ordinary Lua. To change a key, edit the copy in your Neovim
config, or override it after the `require("config.vscode")` line:

```lua
if vim.g.vscode then
  require("config.vscode")
  vim.keymap.set("n", "<leader>gg", function()
    require("vscode").action("workbench.view.scm")
  end)
end
```

Command names can be copied from VS Code's Keyboard Shortcuts editor (right
click a row, then "Copy Command ID").

## Uninstall

Delete `lua/config/vscode.lua` from your Neovim config, remove the
`require("config.vscode")` block from `keymaps.lua`, and remove the added
entries from `keybindings.json`, `settings.json` and `tasks.json` (or restore
the `.bak` copies).

## License

[MIT](LICENSE)
