local M = {}

local SRC_ROOT = "src/main/cpp/"
local TEST_ROOT = "src/test/cpp/"

--- Get the base name (without extension and without "Test" suffix) from a file path
local function get_base_name(filepath)
  local basename = vim.fn.fnamemodify(filepath, ":t")
  local name = basename:match("^(.+)%.[^.]+$")
  if not name then return nil end
  -- Strip trailing "Test" if present
  name = name:gsub("Test$", "")
  return name
end

--- Get the relative path under src/main/cpp/ for the header include
local function get_include_path(filepath)
  local rel = filepath:match(SRC_ROOT .. "(.+)$")
  if not rel then return nil end
  -- Convert to .h header path
  local header = rel:gsub("%.[^.]+$", ".h")
  return header
end

--- Open the corresponding test file for the current buffer.
--- Given Foo.h, Foo.cpp, or Foo.hpp, searches for FooTest.cpp recursively
--- from the project root.
function M.open_test()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.ERROR)
    return
  end

  local name = get_base_name(filepath)
  if not name then
    vim.notify("Cannot determine file name", vim.log.levels.ERROR)
    return
  end

  -- If we're already in a test file, inform the user
  if vim.fn.fnamemodify(filepath, ":t"):match("Test%.[^.]+$") then
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

--- Create a test file for the current buffer.
--- Maps src/main/cpp/<path>/Foo.{h,cpp} → src/test/cpp/<path>/FooTest.cpp
--- with #include <path/Foo.h> and #include <gtest/gtest.h>.
function M.create_test()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.ERROR)
    return
  end

  -- Must be under src/main/cpp/
  if not filepath:find(SRC_ROOT, 1, true) then
    vim.notify("File is not under " .. SRC_ROOT, vim.log.levels.ERROR)
    return
  end

  local name = get_base_name(filepath)
  if not name then
    vim.notify("Cannot determine file name", vim.log.levels.ERROR)
    return
  end

  if vim.fn.fnamemodify(filepath, ":t"):match("Test%.[^.]+$") then
    vim.notify("Current file is already a test file", vim.log.levels.WARN)
    return
  end

  -- Compute include path (relative to src/main/cpp/)
  local include_path = get_include_path(filepath)
  if not include_path then
    vim.notify("Cannot determine include path", vim.log.levels.ERROR)
    return
  end

  -- Compute test file path: replace src/main/cpp/ with src/test/cpp/
  local rel = filepath:match(SRC_ROOT .. "(.+)$")
  local dir = rel:match("^(.+/)")  or ""
  local test_file = SRC_ROOT:gsub("main", "test"):gsub("/$", "") -- base
  -- Use absolute path based on the project root portion of filepath
  local project_prefix = filepath:match("^(.-)" .. SRC_ROOT:gsub("%-", "%%-"))
  if not project_prefix then
    vim.notify("Cannot determine project root", vim.log.levels.ERROR)
    return
  end
  local test_path = project_prefix .. TEST_ROOT .. dir .. name .. "Test.cpp"

  -- Check if test file already exists
  if vim.fn.filereadable(test_path) == 1 then
    vim.notify("Test file already exists: " .. test_path, vim.log.levels.WARN)
    vim.cmd("edit " .. vim.fn.fnameescape(test_path))
    return
  end

  -- Create parent directories
  local test_dir = vim.fn.fnamemodify(test_path, ":h")
  vim.fn.mkdir(test_dir, "p")

  -- Write the test file
  local content = {
    "#include <" .. include_path .. ">",
    "",
    "#include <gtest/gtest.h>",
  }
  vim.fn.writefile(content, test_path)

  -- Open the new test file
  vim.cmd("edit " .. vim.fn.fnameescape(test_path))
  vim.notify("Created test file: " .. test_path)
end

--- Add an empty gtest TEST() at the current cursor position.
--- Derives the test suite name from the filename and prompts for the test case name.
function M.add_test()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file in current buffer", vim.log.levels.ERROR)
    return
  end

  local basename = vim.fn.fnamemodify(filepath, ":t:r")
  if not basename or basename == "" then
    vim.notify("Cannot determine file name", vim.log.levels.ERROR)
    return
  end

  vim.ui.input({ prompt = "Test case name: " }, function(test_name)
    if not test_name or test_name == "" then
      return
    end

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local lines = {
      "TEST(" .. basename .. ", " .. test_name .. ") {",
      "\t",
      "}",
    }
    vim.api.nvim_buf_set_lines(0, row, row, false, lines)
    -- Place cursor on the indented line inside the test body
    vim.api.nvim_win_set_cursor(0, { row + 2, 1 })
    vim.cmd("startinsert!")
  end)
end

return M
