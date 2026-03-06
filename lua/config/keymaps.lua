local function nmap(lhs, rhs, opts)
  vim.keymap.set("n", lhs, rhs, vim.tbl_extend("force", { noremap = true, silent = true }, opts or {}))
end

local function vmap(lhs, rhs, opts)
  vim.keymap.set("v", lhs, rhs, vim.tbl_extend("force", { noremap = true, silent = true }, opts or {}))
end

local function map(modes, lhs, rhs, opts)
  vim.keymap.set(modes, lhs, rhs, vim.tbl_extend("force", { noremap = true, silent = true }, opts or {}))
end

-- Neo keyboard layout remappings (swap vim motions to match Neo layout)
local function remap_vim_motion(lhs, rhs)
  nmap(lhs, rhs)
  vmap(lhs, rhs)
  nmap(rhs, lhs)
end

remap_vim_motion("s", "h")
remap_vim_motion("n", "j")
nmap("N", "J")
remap_vim_motion("r", "k")
nmap("R", "K")
nmap("K", "R")
remap_vim_motion("t", "l")
nmap("T", "L")
nmap("L", "T")

-- Window navigation (Neo layout: s=left, n=down, r=up, t=right)
nmap("<C-s>", "<C-w>h")
nmap("<C-n>", "<C-w>j")
nmap("<C-r>", "<C-w>k")
nmap("<C-t>", "<C-w>l")

-- Delete/change/x go to black hole register by default
map({ "n" }, "c", '"xc')
map({ "n" }, "d", '"xd')
map({ "n" }, "x", '"xx')

-- Inner line text object
map({ "x" }, "iL", "0o$h")
map({ "o" }, "iL", ":normal viL<cr>")

-- Yank entire line content (without newline)
nmap("Y", "0y$")

-- Paste from black hole register
nmap("<C-p>", '"xp')

-- Visual mode: search and replace selected text
vmap("<C-r>", '"hy:%s/<C-r>h//gc<left><left><left>', { silent = false })

-- Save with Ctrl-s
nmap("<C-s>", ":w<cr>")

-- Clear search highlight
nmap("<Esc>", "<cmd>nohlsearch<cr>")

-- Better indenting (stay in visual mode)
vmap("<", "<gv")
vmap(">", ">gv")

-- Move lines up and down
map({ "v" }, "<A-n>", ":m '>+1<cr>gv=gv")
map({ "v" }, "<A-r>", ":m '<-2<cr>gv=gv")

-- Resize windows with arrows
nmap("<C-Up>", "<cmd>resize +2<cr>")
nmap("<C-Down>", "<cmd>resize -2<cr>")
nmap("<C-Left>", "<cmd>vertical resize -2<cr>")
nmap("<C-Right>", "<cmd>vertical resize +2<cr>")
