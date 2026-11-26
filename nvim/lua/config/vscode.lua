-- Keymaps used only when Neovim runs inside VS Code (vscode-neovim extension).
-- Each LazyVim key that normally opens a Neovim plugin UI (picker, neo-tree,
-- trouble, dap, gitsigns, ...) is pointed at the matching VS Code command.
-- Motions, text objects, flash (s/S) and the rest come from the normal config.
local vscode = require("vscode")

local function act(cmd, args)
  return function()
    vscode.action(cmd, args and { args = { args } } or nil)
  end
end

local function map(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, type(rhs) == "string" and act(rhs) or rhs, { desc = desc, silent = true })
end

local function each(mode, keys, rhs, desc)
  for _, lhs in ipairs(keys) do
    map(mode, lhs, rhs, desc)
  end
end

-- Flip a VS Code setting between two values
local function toggle(setting, on, off)
  return function()
    local new = vscode.get_config(setting) == on and off or on
    vscode.update_config(setting, new, "global")
    vscode.notify(setting .. " = " .. tostring(new))
  end
end

local function selection_or_word()
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" then
    local lines = vim.fn.getregion(vim.fn.getpos("v"), vim.fn.getpos("."), { type = mode })
    return lines[1] or ""
  end
  return vim.fn.expand("<cword>")
end

local function grep_word()
  vscode.action("workbench.action.findInFiles", { args = { { query = selection_or_word(), triggerSearch = true } } })
end

local function todo(pattern)
  return act("workbench.action.findInFiles", { query = "\\b(" .. pattern .. ")\\b", isRegex = true, triggerSearch = true })
end

-- files / find
each("n", { "<leader><space>", "<leader>ff", "<leader>fF", "<leader>fg" }, "workbench.action.quickOpen", "Find Files")
each("n", { "<leader>,", "<leader>fb", "<leader>fB", "<leader>bj" }, "workbench.action.showAllEditors", "Buffers")
each("n", { "<leader>fr", "<leader>fR", "<leader>fp" }, "workbench.action.openRecent", "Recent")
map("n", "<leader>fc", "workbench.action.openSettingsJson", "Config File")
map("n", "<leader>fn", "workbench.action.files.newUntitledFile", "New File")
map("n", "<leader>.", "workbench.action.files.newUntitledFile", "Scratch Buffer")

-- explorer (neo-tree)
each("n", { "<leader>e", "<leader>E", "<leader>fe", "<leader>fE" }, "workbench.files.action.focusFilesExplorer", "Explorer")
map("n", "<leader>be", "workbench.files.action.focusOpenEditorsView", "Buffer Explorer")
map("n", "<leader>ge", "workbench.view.scm", "Git Explorer")

-- search
each("n", { "<leader>/", "<leader>sg", "<leader>sG" }, "workbench.action.quickTextSearch", "Grep")
each({ "n", "x" }, { "<leader>sw", "<leader>sW" }, grep_word, "Grep Word / Selection")
each("n", { "<leader>sb", "<leader>sB" }, "actions.find", "Buffer Lines")
map({ "n", "x" }, "<leader>sr", "workbench.action.replaceInFiles", "Search and Replace")
map("n", "<leader>sR", "workbench.view.search", "Resume Search")
map("n", "<leader>ss", "workbench.action.gotoSymbol", "Symbols")
map("n", "<leader>sS", "workbench.action.showAllSymbols", "Workspace Symbols")
each("n", { "<leader>:", "<leader>sc", "<leader>sC" }, "workbench.action.showCommands", "Commands")
map("n", "<leader>sk", "workbench.action.openGlobalKeybindings", "Keymaps")
each("n", { "<leader>sd", "<leader>sD", "<leader>xx", "<leader>xX" }, "workbench.actions.view.problems", "Diagnostics")
each("n", { "<leader>st", "<leader>xt" }, todo("TODO|FIX|FIXME|HACK|WARN|PERF|NOTE"), "Todo")
each("n", { "<leader>sT", "<leader>xT" }, todo("TODO|FIX|FIXME"), "Todo/Fix/Fixme")
each("n", { "<leader>xq", "<leader>xQ", "<leader>sq" }, "workbench.view.search", "Quickfix List")
map("n", "]q", "search.action.focusNextSearchResult", "Next Quickfix")
map("n", "[q", "search.action.focusPreviousSearchResult", "Previous Quickfix")
map("n", "<leader>uC", "workbench.action.selectTheme", "Colorschemes")
each("n", { "<leader>n", "<leader>snh", "<leader>sna", "<leader>snl" }, "notifications.showList", "Notifications")
each("n", { "<leader>un", "<leader>snd" }, "notifications.clearAll", "Dismiss Notifications")

-- buffers (editor tabs)
each("n", { "<S-h>", "[b" }, "workbench.action.previousEditor", "Prev Buffer")
each("n", { "<S-l>", "]b" }, "workbench.action.nextEditor", "Next Buffer")
map("n", "[B", "workbench.action.moveEditorLeftInGroup", "Move Buffer Prev")
map("n", "]B", "workbench.action.moveEditorRightInGroup", "Move Buffer Next")
each("n", { "<leader>bb", "<leader>`" }, "workbench.action.openPreviousRecentlyUsedEditorInGroup", "Other Buffer")
each("n", { "<leader>bd", "<leader>bD" }, "workbench.action.closeActiveEditor", "Delete Buffer")
map("n", "<leader>bo", "workbench.action.closeOtherEditors", "Delete Other Buffers")
map("n", "<leader>br", "workbench.action.closeEditorsToTheRight", "Delete Buffers to the Right")
map("n", "<leader>bl", "workbench.action.closeEditorsToTheLeft", "Delete Buffers to the Left")
map("n", "<leader>bp", "workbench.action.pinEditor", "Pin Buffer")
map("n", "<leader>bP", "workbench.action.closeAllEditors", "Delete Non-Pinned Buffers")

-- windows (editor groups)
map("n", "<C-h>", "workbench.action.navigateLeft", "Go to Left Window")
map("n", "<C-j>", "workbench.action.navigateDown", "Go to Lower Window")
map("n", "<C-k>", "workbench.action.navigateUp", "Go to Upper Window")
map("n", "<C-l>", "workbench.action.navigateRight", "Go to Right Window")
map("n", "<C-Up>", "workbench.action.increaseViewHeight", "Increase Window Height")
map("n", "<C-Down>", "workbench.action.decreaseViewHeight", "Decrease Window Height")
map("n", "<C-Left>", "workbench.action.decreaseViewWidth", "Decrease Window Width")
map("n", "<C-Right>", "workbench.action.increaseViewWidth", "Increase Window Width")
map("n", "<leader>-", "workbench.action.splitEditorDown", "Split Window Below")
map("n", "<leader>|", "workbench.action.splitEditorRight", "Split Window Right")
map("n", "<leader>wd", "workbench.action.closeGroup", "Delete Window")
each("n", { "<leader>wm", "<leader>uZ" }, "workbench.action.toggleMaximizeEditorGroup", "Zoom Window")
map("n", "<leader>uz", "workbench.action.toggleZenMode", "Zen Mode")

-- tabs have no VS Code counterpart; use editor groups
map("n", "<leader><tab><tab>", "workbench.action.newGroupRight", "New Tab")
map("n", "<leader><tab>]", "workbench.action.focusNextGroup", "Next Tab")
map("n", "<leader><tab>[", "workbench.action.focusPreviousGroup", "Previous Tab")
map("n", "<leader><tab>f", "workbench.action.focusFirstEditorGroup", "First Tab")
map("n", "<leader><tab>l", "workbench.action.focusLastEditorGroup", "Last Tab")
map("n", "<leader><tab>d", "workbench.action.closeGroup", "Close Tab")
map("n", "<leader><tab>o", "workbench.action.closeEditorsInOtherGroups", "Close Other Tabs")

-- lsp / code
map("n", "gd", "editor.action.revealDefinition", "Goto Definition")
map("n", "gD", "editor.action.revealDeclaration", "Goto Declaration")
map("n", "gr", "editor.action.goToReferences", "References")
map("n", "gI", "editor.action.goToImplementation", "Goto Implementation")
map("n", "gy", "editor.action.goToTypeDefinition", "Goto Type Definition")
map("n", "gai", "editor.showIncomingCalls", "Calls Incoming")
map("n", "gao", "editor.showOutgoingCalls", "Calls Outgoing")
each("n", { "K", "<leader>K", "<leader>cd" }, "editor.action.showHover", "Hover / Line Diagnostics")
map("n", "gK", "editor.action.triggerParameterHints", "Signature Help")
map({ "n", "x" }, "<leader>ca", "editor.action.quickFix", "Code Action")
map("n", "<leader>cA", "editor.action.sourceAction", "Source Action")
map("n", "<leader>cr", "editor.action.rename", "Rename")
map("n", "<leader>cf", "editor.action.formatDocument", "Format")
map("x", "<leader>cf", "editor.action.formatSelection", "Format")
map({ "n", "x" }, "<leader>cc", "codelens.showLensesInCurrentLine", "Run Codelens")
map("n", "<leader>cs", "outline.focus", "Symbols")
map("n", "<leader>cS", "references-view.findReferences", "LSP References")
map("n", "<leader>co", "editor.action.organizeImports", "Organize Imports")
map("n", "]]", "editor.action.wordHighlight.next", "Next Reference")
map("n", "[[", "editor.action.wordHighlight.prev", "Prev Reference")
each("n", { "]d", "]e", "]w" }, "editor.action.marker.next", "Next Diagnostic")
each("n", { "[d", "[e", "[w" }, "editor.action.marker.prev", "Prev Diagnostic")

-- java (jdtls)
local function refactor(kind)
  return act("editor.action.codeAction", { kind = kind, apply = "first" })
end
map({ "n", "x" }, "<leader>cxv", refactor("refactor.extract.variable"), "Extract Variable")
map({ "n", "x" }, "<leader>cxc", refactor("refactor.extract.constant"), "Extract Constant")
map("x", "<leader>cxm", refactor("refactor.extract.function"), "Extract Method")
map("n", "<leader>cgs", "java.action.navigateToSuperImplementation", "Goto Super")
map("n", "<leader>cgS", "java.test.goToTest", "Goto Subjects")
map("n", "<leader>tt", "testing.runCurrentFile", "Run All Tests")
map("n", "<leader>tr", "testing.runAtCursor", "Run Nearest Test")
map("n", "<leader>tT", "testing.runAll", "Run Test")

-- git
each("n", { "<leader>gg", "<leader>gG" }, act("workbench.action.tasks.runTask", "lazygit"), "Lazygit")
each("n", { "<leader>gs", "<leader>gd" }, "workbench.view.scm", "Git Status")
each("n", { "<leader>gl", "<leader>gL" }, "workbench.scm.history.focus", "Git Log")
map("n", "<leader>gf", "timeline.focus", "Git Current File History")
each("n", { "<leader>gb", "<leader>ghb", "<leader>ghB" }, "git.blame.toggleEditorDecoration", "Git Blame")
map("n", "<leader>gS", "git.stashApply", "Git Stash")
map("n", "]h", "workbench.action.editor.nextChange", "Next Hunk")
map("n", "[h", "workbench.action.editor.previousChange", "Prev Hunk")
map({ "n", "x" }, "<leader>ghs", "git.stageSelectedRanges", "Stage Hunk")
map({ "n", "x" }, "<leader>ghr", "git.revertSelectedRanges", "Reset Hunk")
map("n", "<leader>ghu", "git.unstageSelectedRanges", "Undo Stage Hunk")
map("n", "<leader>ghS", "git.stage", "Stage Buffer")
map("n", "<leader>ghR", "git.clean", "Reset Buffer")
map("n", "<leader>ghp", "editor.action.dirtydiff.next", "Preview Hunk Inline")
each("n", { "<leader>ghd", "<leader>ghD" }, "git.openChange", "Diff This")

-- debug (nvim-dap)
map("n", "<leader>db", "editor.debug.action.toggleBreakpoint", "Toggle Breakpoint")
map("n", "<leader>dB", "editor.debug.action.conditionalBreakpoint", "Breakpoint Condition")
map("n", "<leader>dc", function()
  local running = vscode.eval("return vscode.debug.activeDebugSession !== undefined")
  vscode.action(running and "workbench.action.debug.continue" or "workbench.action.debug.start")
end, "Run/Continue")
map("n", "<leader>da", "workbench.action.debug.selectandstart", "Run with Args")
map("n", "<leader>dC", "editor.debug.action.runToCursor", "Run to Cursor")
map("n", "<leader>di", "workbench.action.debug.stepInto", "Step Into")
map("n", "<leader>do", "workbench.action.debug.stepOut", "Step Out")
map("n", "<leader>dO", "workbench.action.debug.stepOver", "Step Over")
map("n", "<leader>dj", "workbench.action.debug.callStackDown", "Down")
map("n", "<leader>dk", "workbench.action.debug.callStackUp", "Up")
map("n", "<leader>dl", "workbench.action.debug.restart", "Run Last")
map("n", "<leader>dP", "workbench.action.debug.pause", "Pause")
map("n", "<leader>dr", "workbench.debug.action.toggleRepl", "Toggle REPL")
map("n", "<leader>dt", "workbench.action.debug.stop", "Terminate")
map("n", "<leader>du", "workbench.view.debug", "Dap UI")
each({ "n", "x" }, { "<leader>de", "<leader>dw" }, "editor.debug.action.showDebugHover", "Eval")

-- terminal
each("n", { "<leader>ft", "<leader>fT", "<C-/>", "<C-_>" }, "workbench.action.terminal.toggleTerminal", "Terminal")

-- ui toggles
map("n", "<leader>uw", "editor.action.toggleWordWrap", "Toggle Wrap")
map("n", "<leader>ul", toggle("editor.lineNumbers", "on", "off"), "Toggle Line Numbers")
map("n", "<leader>uL", toggle("editor.lineNumbers", "relative", "on"), "Toggle Relative Number")
map("n", "<leader>uh", toggle("editor.inlayHints.enabled", "on", "off"), "Toggle Inlay Hints")
map("n", "<leader>uf", toggle("editor.formatOnSave", true, false), "Toggle Auto Format")
map("n", "<leader>ug", toggle("editor.guides.indentation", true, false), "Toggle Indent Guides")

-- misc
map("n", "<leader>l", "workbench.view.extensions", "Extensions (Lazy)")
map("n", "<leader>qq", "workbench.action.closeWindow", "Quit All")
