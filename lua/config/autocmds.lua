local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Format on save (Lua files only)
augroup("FormatOnSave", { clear = true })
autocmd("BufWritePre", {
  group = "FormatOnSave",
  pattern = "*.lua",
  callback = function()
    vim.lsp.buf.format({ timeout_ms = 1000 })
  end,
})

-- Custom diff highlight colors
augroup("DiffColors", { clear = true })
autocmd("ColorScheme", {
  group = "DiffColors",
  pattern = "*",
  callback = function()
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#1c444a", underline = false, bold = false })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#801919", underline = false, bold = false })
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1d2739", underline = false, bold = false })
    vim.api.nvim_set_hl(0, "DiffText", { bg = "#3c4e77", underline = false, bold = false })
  end,
})

-- Highlight on yank
augroup("HighlightYank", { clear = true })
autocmd("TextYankPost", {
  group = "HighlightYank",
  callback = function()
    vim.hl.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Go to last location when opening a buffer
augroup("LastLocation", { clear = true })
autocmd("BufReadPost", {
  group = "LastLocation",
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf]._last_loc then
      return
    end
    vim.b[buf]._last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close some filetypes with <q>
augroup("CloseWithQ", { clear = true })
autocmd("FileType", {
  group = "CloseWithQ",
  pattern = {
    "help",
    "lspinfo",
    "notify",
    "qf",
    "checkhealth",
    "man",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true })
  end,
})
