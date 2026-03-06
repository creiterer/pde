return {
  -- Surround text objects
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },

  -- Repeat plugin actions with .
  {
    "tpope/vim-repeat",
    event = "VeryLazy",
  },

  -- Highlight TODO, FIXME, etc.
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufRead",
    opts = {
      highlight = {
        keyword = "bg",
        pattern = { [[.*<(KEYWORDS)\s*:]], [[.*<(KEYWORDS)\(\w+\)\s*:]] },
      },
    },
  },
}
