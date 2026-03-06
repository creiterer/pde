return {
  -- Gitsigns: git decorations in the sign column
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = {
        add = { text = "▎" },
        change = { text = "▎" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "▎" },
        untracked = { text = "▎" },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map("n", "]h", function()
          gs.nav_hunk("next", { navigation_message = false, preview = true, wrap = false })
        end, { desc = "Next Hunk" })
        map("n", "[h", function()
          gs.nav_hunk("prev", { navigation_message = false, preview = true, wrap = false })
        end, { desc = "Prev Hunk" })

        -- Actions (leader-g group is defined in which-key)
        map("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })
        map("n", "<leader>gu", gs.undo_stage_hunk, { desc = "Undo Stage Hunk" })
        map("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
        map("v", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Stage Hunk" })
        map("v", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, { desc = "Reset Hunk" })
        map("n", "<leader>gS", gs.stage_buffer, { desc = "Stage Buffer" })
        map("n", "<leader>gR", gs.reset_buffer, { desc = "Reset Buffer" })
        map("n", "<leader>gP", gs.preview_hunk, { desc = "Preview Hunk" })
        map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, { desc = "Blame Line" })
        map("n", "<leader>gd", gs.diffthis, { desc = "Diff This" })
        map("n", "<leader>gD", function() gs.diffthis("~") end, { desc = "Diff This ~" })
        map("n", "<leader>gt", gs.toggle_deleted, { desc = "Toggle Deleted" })
      end,
    },
  },

  -- Fugitive: git commands
  {
    "tpope/vim-fugitive",
    cmd = {
      "G", "Git", "Gdiffsplit", "Gvdiffsplit", "Gread", "Gwrite",
      "Ggrep", "GMove", "GDelete", "GBrowse", "GRemove", "GRename",
      "Glgrep", "Gedit",
    },
    ft = { "fugitive" },
    keys = {
      { "<leader>gg", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
    },
  },

  -- Fubitive: Bitbucket URL support for fugitive
  {
    "tommcdo/vim-fubitive",
    dependencies = { "tpope/vim-fugitive" },
    init = function()
      vim.g.fubitive_domain_pattern = "bitbucket.lab.dynatrace.org"
    end,
  },
}
