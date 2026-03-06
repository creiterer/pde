return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    cmd = "Telescope",
    keys = {
      { "<leader>f", "<cmd>Telescope find_files<cr>", desc = "Find files" },
    },
    opts = function()
      return {
        defaults = {
          path_display = { truncate = 2 },
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
          },
          mappings = {
            i = {
              ["<C-n>"] = require("telescope.actions").move_selection_next,
              ["<C-r>"] = require("telescope.actions").move_selection_previous,
            },
          },
        },
        pickers = {
          buffers = {
            initial_mode = "insert",
          },
          git_status = {
            theme = "dropdown",
            previewer = false,
            path_display = { "truncate" },
            layout_config = {
              width = 0.8,
            },
          },
          lsp_document_symbols = {
            theme = "dropdown",
            previewer = false,
            path_display = { "truncate" },
            layout_config = {
              width = 0.8,
            },
          },
        },
      }
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      pcall(telescope.load_extension, "fzf")
    end,
  },
}
