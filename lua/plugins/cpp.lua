return {
  {
    "p00f/clangd_extensions.nvim",
    ft = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    opts = {
      inlay_hints = {
        inline = true,
      },
      ast = {
        role_icons = {
          type = "",
          declaration = "",
          expression = "",
          specifier = "",
          statement = "",
          ["template argument"] = "",
        },
        kind_icons = {
          Compound = "",
          Recovery = "",
          TranslationUnit = "",
          PackExpansion = "",
          TemplateTypeParm = "",
          TemplateTemplateParm = "",
          TemplateParamObject = "",
        },
      },
    },
    config = function(_, opts)
      require("clangd_extensions").setup(opts)

      local capabilities = require("blink.cmp").get_lsp_capabilities()

      -- Project-specific clangd flags
      local clangd_flags = {}
      local ok, project_flags = pcall(require, "rhel.clangd_wrl")
      if ok then
        clangd_flags = vim.tbl_deep_extend("keep", project_flags, clangd_flags)
      end

      vim.lsp.config("clangd", {
        capabilities = vim.tbl_deep_extend("force", capabilities, {
          offsetEncoding = { "utf-16" },
        }),
        cmd = vim.list_extend({ "clangd" }, clangd_flags),
        root_markers = {
          "CMakePresets.json",
          "compile_commands.json",
          "compile_flags.txt",
          ".clangd",
          ".clang-tidy",
          ".clang-format",
          "CMakeLists.txt",
          "Makefile",
          ".git",
        },
      })

      vim.lsp.enable("clangd")
    end,
  },
}
