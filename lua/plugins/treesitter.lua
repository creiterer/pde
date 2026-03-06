return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
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
      local textobjects = opts.textobjects
      opts.textobjects = nil
      require("nvim-treesitter").setup(opts)

      -- Setup textobjects config (lookahead, selection_modes, etc.)
      if textobjects then
        require("nvim-treesitter-textobjects").setup({
          select = textobjects.select or {},
          move = textobjects.move or {},
        })
      end

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- Register select keymaps
      if textobjects and textobjects.select and textobjects.select.keymaps then
        for key, query in pairs(textobjects.select.keymaps) do
          local query_string, query_group
          if type(query) == "table" then
            query_string = query.query
            query_group = query.query_group
          else
            query_string = query
          end
          vim.keymap.set({ "x", "o" }, key, function()
            select.select_textobject(query_string, query_group)
          end, { desc = "Textobject: " .. query_string })
        end
      end

      -- Register move keymaps
      if textobjects and textobjects.move then
        local move_maps = {
          { textobjects.move.goto_next_start, move.goto_next_start },
          { textobjects.move.goto_next_end, move.goto_next_end },
          { textobjects.move.goto_previous_start, move.goto_previous_start },
          { textobjects.move.goto_previous_end, move.goto_previous_end },
        }
        for _, pair in ipairs(move_maps) do
          local keymaps, fn = pair[1], pair[2]
          if keymaps then
            for key, query in pairs(keymaps) do
              local query_string, query_group, desc
              if type(query) == "table" then
                query_string = query.query or query[1]
                query_group = query.query_group
                desc = query.desc or query_string
              else
                query_string = query
                desc = query_string
              end
              vim.keymap.set({ "n", "x", "o" }, key, function()
                fn(query_string, query_group)
              end, { desc = desc })
            end
          end
        end
      end

      -- Register swap keymaps
      if textobjects and textobjects.swap then
        if textobjects.swap.swap_next then
          for key, query in pairs(textobjects.swap.swap_next) do
            vim.keymap.set("n", key, function()
              swap.swap_next(query)
            end, { desc = "Swap next: " .. query })
          end
        end
        if textobjects.swap.swap_previous then
          for key, query in pairs(textobjects.swap.swap_previous) do
            vim.keymap.set("n", key, function()
              swap.swap_previous(query)
            end, { desc = "Swap prev: " .. query })
          end
        end
      end

      -- Repeatable movement with ; and ,
      local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)

      -- Make builtin f, F also repeatable with ; and ,
      -- NOTE: builtin t/T are NOT remapped here because t=l and T=L in the Neo layout
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
    end,
  },
}
