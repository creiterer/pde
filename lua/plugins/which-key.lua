return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "modern",
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)

      wk.add({
        -- Buffer mappings
        { "<leader>b", group = "Buffer" },
        { "<leader>G", group = "Git" },
        { "<leader>g", group = "Goto" },
        { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close all to the left" },
        { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close all to the right" },
        { "<leader>bp", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous" },
        { "<leader>bn", "<cmd>BufferLineCycleNext<cr>", desc = "Next" },
        { "<leader>ba", "<cmd>%bd<cr>", desc = "Close all" },
        { "<leader>bo", "<cmd>%bd|e #|bd #|normal`\"<cr>", desc = "Close all but current" },
        { "<leader>bd", "<cmd>e!<cr>", desc = "Discard changes" },
        { "<leader>bt", "<cmd>Telescope buffers<cr>", desc = "Telescope buffers" },
        { "<leader>C", "<cmd>bdelete<cr>", desc = "Close Buffer" },

        -- Window mappings
        { "<leader>W", group = "Window" },
        { "<leader>Wo", "<cmd>only<cr>", desc = "Close all windows but current" },

        -- Search mappings
        { "<leader>s", group = "Search" },
        { "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>st", "<cmd>Telescope live_grep<cr>", desc = "Text (grep)" },
        { "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
        { "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
        { "<leader>sr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
        { "<leader>sw", "<cmd>Telescope grep_string<cr>", desc = "Word under cursor" },
        { "<leader>sT", function() require("telescope_pickers").live_grep_in_folder() end, desc = "Text in folders" },

        -- Telescope shortcuts at top level
        { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
        { "<leader>F", "<cmd>Telescope find_files follow=true hidden=true no_ignore=true no_ignore_parent=true<cr>", desc = "Find all files" },
        { "<leader>r", "<cmd>Telescope resume<cr>", desc = "Resume previous picker" },

        -- LSP mappings
        { "<leader>l", group = "LSP" },
        { "<leader>la", vim.lsp.buf.code_action, desc = "Code Action" },
        { "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<cr>", desc = "Document Diagnostics" },
        { "<leader>lD", "<cmd>Telescope diagnostics<cr>", desc = "Workspace Diagnostics" },
        { "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, desc = "Format" },
        { "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info" },
        { "<leader>ln", vim.diagnostic.goto_next, desc = "Next Diagnostic" },
        { "<leader>lp", vim.diagnostic.goto_prev, desc = "Prev Diagnostic" },
        { "<leader>lr", vim.lsp.buf.rename, desc = "Rename" },
        { "<leader>ls", "<cmd>Telescope lsp_document_symbols symbol_width=80<cr>", desc = "Document Symbols" },
        { "<leader>lS", "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>", desc = "Workspace Symbols" },
        { "<leader>lq", vim.diagnostic.setloclist, desc = "Quickfix" },

        -- Code mappings
        { "<leader>c", group = "Code" },
        { "<leader>cc", "gcc", desc = "Comment toggle", remap = true },
        { "<leader>cd", function() require("cpp_def").generate_definition() end, desc = "Generate C++ definition" },

        -- Diff mappings
        { "<leader>d", group = "Diff" },
        { "<leader>dg", "<cmd>diffget<cr>", desc = "diffget" },
        { "<leader>dp", "<cmd>diffput<cr>", desc = "diffput" },
        { "<leader>dn", "]c", desc = "Next change" },
        { "<leader>dN", "[c", desc = "Prev change" },

        -- Paste and jump to line start
        { "<leader>p", "p^", desc = "Paste and jump to line start" },

        -- Switch source/header (C++)
        { "<leader>gs", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header" },
        { "<leader>gt", function() require("cpp_test").open_test() end, desc = "Open the corresponding test" },
      })

      -- Visual mode diff mappings
      wk.add({
        mode = "v",
        { "<leader>cc", "gc", desc = "Comment toggle", remap = true },
        { "<leader>d", group = "Diff" },
        { "<leader>dg", ":diffget<cr>", desc = "diffget" },
        { "<leader>dp", ":diffput<cr>", desc = "diffput" },
        -- Visual mode format selection
        { "<leader>lf", function()
          vim.lsp.buf.format({
            range = {
              ["start"] = vim.api.nvim_buf_get_mark(0, "<"),
              ["end"] = vim.api.nvim_buf_get_mark(0, ">"),
            },
          })
        end, desc = "Format Selection" },
      })
    end,
  },
}
