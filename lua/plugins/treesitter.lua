return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    opts = {
      ensure_installed = {
        "c",
        "cpp",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",
        "bash",
        "json",
        "yaml",
        "cmake",
      },
      auto_install = true,
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["ip"] = "@parameter.inner",
            ["ap"] = "@parameter.outer",
            ["ab"] = "@block.outer",
            ["ic"] = "@call.inner",
            ["ac"] = "@call.outer",
            ["ia"] = "@class.inner",
            ["aa"] = "@class.outer",
            ["ao"] = "@comment.outer",
            ["id"] = "@conditional.inner",
            ["ad"] = "@conditional.outer",
            ["if"] = "@function.inner",
            ["af"] = "@function.outer",
            ["il"] = "@loop.inner",
            ["al"] = "@loop.outer",
            ["in"] = "@number.inner",
            ["ir"] = "@return.inner",
            ["ar"] = "@return.outer",
            ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
            ["at"] = "@statement.outer",
          },
          selection_modes = {
            ["@parameter.outer"] = "v",
            ["@function.outer"] = "V",
            ["@class.outer"] = "<c-v>",
          },
          include_surrounding_whitespace = false,
        },
        swap = {
          enable = true,
          swap_next = {
            ["<leader>tp"] = "@parameter.inner",
            ["<leader>tf"] = "@function.outer",
          },
          swap_previous = {
            ["<leader>tP"] = "@parameter.inner",
            ["<leader>tF"] = "@function.outer",
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = {
            ["]a"] = "@class.outer",
            ["]f"] = "@function.inner",
            ["]m"] = "@function.outer",
            ["]p"] = "@parameter.inner",
            ["]o"] = "@loop.*",
            ["]s"] = { query = "@scope", query_group = "locals", desc = "Next scope" },
            ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
          },
          goto_next_end = {
            ["]A"] = "@class.outer",
            ["]F"] = "@function.inner",
            ["]M"] = "@function.outer",
            ["]P"] = "@parameter.inner",
          },
          goto_previous_start = {
            ["[a"] = "@class.outer",
            ["[f"] = "@function.inner",
            ["[m"] = "@function.outer",
            ["[p"] = "@parameter.inner",
          },
          goto_previous_end = {
            ["[A"] = "@class.outer",
            ["[F"] = "@function.inner",
            ["[M"] = "@function.outer",
            ["[P"] = "@parameter.inner",
          },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- Repeatable movement with ; and ,
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      -- Make builtin f, F, t, T also repeatable with ; and ,
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end,
  },
}
