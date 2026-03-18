local M = {}

--- Open the corresponding test file for the current buffer.
--- Given Foo.h, Foo.cpp, or Foo.hpp, searches for FooTest.cpp recursively
--- from the project root.
function M.open_test()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.ERROR)
    return
  end

  local basename = vim.fn.fnamemodify(filepath, ":t")

  -- Strip known extensions and any existing "Test" suffix to get the base name
  local name = basename:match("^(.+)%.[^.]+$")
  if not name then
    vim.notify("Cannot determine file name", vim.log.levels.ERROR)
    return
  end

  -- If we're already in a test file, inform the user
  if name:match("Test$") then
    vim.notify("Current file is already a test file", vim.log.levels.WARN)
    return
  end

  local test_name = name .. "Test.cpp"

  -- Search from the working directory recursively
  local results = vim.fn.globpath(vim.fn.getcwd(), "**/" .. test_name, false, true)

  if #results == 0 then
    vim.notify("No test file found: " .. test_name, vim.log.levels.ERROR)
    return
  end

  if #results == 1 then
    vim.cmd("edit " .. vim.fn.fnameescape(results[1]))
  else
    -- Multiple matches: let the user pick via vim.ui.select
    vim.ui.select(results, { prompt = "Multiple test files found:" }, function(choice)
      if choice then
        vim.cmd("edit " .. vim.fn.fnameescape(choice))
      end
    end)
  end
end

return M
