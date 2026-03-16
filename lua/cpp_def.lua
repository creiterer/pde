local M = {}

--- Strip C++ attributes like [[nodiscard]], [[deprecated("msg")]]
local function strip_attributes(str)
  return str:gsub("%[%[.-%]%]%s*", "")
end

--- Find the position of the last closing parenthesis
local function find_last_paren(str)
  for i = #str, 1, -1 do
    if str:sub(i, i) == ")" then
      return i
    end
  end
  return nil
end

--- Strip declaration-only specifiers, preserving parameter names
local function clean_for_definition(str)
  -- Leading specifiers
  str = str:gsub("^%s*virtual%s+", "")
  str = str:gsub("^%s*static%s+", "")
  str = str:gsub("^%s*explicit%s+", "")
  str = str:gsub("^%s*inline%s+", "")
  -- Trailing semicolon
  str = str:gsub("%s*;%s*$", "")
  -- override/final only after the last ) to avoid mangling parameter names
  local paren_pos = find_last_paren(str)
  if paren_pos then
    local before = str:sub(1, paren_pos)
    local after = str:sub(paren_pos + 1)
    after = after:gsub("%s*override", "")
    after = after:gsub("%s*final", "")
    str = before .. after
  end
  return vim.trim(str)
end

--- Find the class name enclosing the given row using treesitter or fallback regex
local function find_class_name(bufnr, row)
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, "cpp")
  if ok and parser then
    local trees = parser:parse()
    if trees and trees[1] then
      local node = trees[1]:root():named_descendant_for_range(row, 0, row, 0)
      while node do
        if node:type() == "class_specifier" or node:type() == "struct_specifier" then
          for child in node:iter_children() do
            if child:type() == "type_identifier" then
              return vim.treesitter.get_node_text(child, bufnr)
            end
          end
        end
        node = node:parent()
      end
    end
  end
  -- Fallback: search upward
  for i = row, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
    local name = line:match("^%s*class%s+(%w+)") or line:match("^%s*struct%s+(%w+)")
    if name then return name end
  end
  return nil
end

--- Read the full declaration starting from row (handles multi-line declarations)
local function get_declaration(bufnr, row)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local decl = vim.trim(lines[row + 1] or "")
  local i = row + 2
  while not decl:match(";%s*$") and i <= #lines do
    decl = decl .. " " .. vim.trim(lines[i])
    i = i + 1
  end
  return decl
end

--- Extract the method name from a cleaned declaration string
local function extract_method_name(cleaned)
  local paren_pos = cleaned:find("%(")
  if not paren_pos then return nil end
  local before = cleaned:sub(1, paren_pos - 1)
  local op = before:match("(operator.+)%s*$")
  if op then return vim.trim(op) end
  local name = before:match("(~?%w+)%s*$")
  return name
end

--- Build a qualified out-of-line definition from a declaration
local function make_definition(decl, class_name)
  local cleaned = strip_attributes(decl)
  cleaned = clean_for_definition(cleaned)

  local paren_pos = cleaned:find("%(")
  if not paren_pos then return nil end

  local before = cleaned:sub(1, paren_pos - 1)
  local from_paren = cleaned:sub(paren_pos)

  -- Operator methods
  local op_start = before:find("operator")
  if op_start then
    local prefix = before:sub(1, op_start - 1)
    local op_part = vim.trim(before:sub(op_start))
    return prefix .. class_name .. "::" .. op_part .. from_paren .. " {\n\n}"
  end

  -- Regular method, constructor, destructor
  local prefix, name = before:match("^(.*%s)(~?%w+)%s*$")
  if not name then
    -- No return type (constructor/destructor)
    name = before:match("^%s*(~?%w+)%s*$")
    prefix = ""
  end
  if not name then return nil end

  return prefix .. class_name .. "::" .. name .. from_paren .. " {\n\n}"
end

--- Find the name of the method declared just before `row` in the same class
local function find_previous_method(bufnr, row)
  for i = row - 1, 0, -1 do
    local line = vim.trim(vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1] or "")
    -- Stop if we've left the class body
    if line:match("^%s*class%s") or line:match("^%s*struct%s") or line:match("^};") then
      return nil
    end
    -- Method declaration: has parentheses and ends with ;
    if line:match("%(") and line:match(";%s*$") then
      local cleaned = clean_for_definition(strip_attributes(line))
      return extract_method_name(cleaned)
    end
  end
  return nil
end

--- Find the line number (1-indexed) where a brace-delimited block ends
local function find_block_end(lines, start)
  local depth = 0
  local found = false
  for i = start, #lines do
    for j = 1, #lines[i] do
      local c = lines[i]:sub(j, j)
      if c == "{" then
        depth = depth + 1
        found = true
      elseif c == "}" then
        depth = depth - 1
        if found and depth == 0 then return i end
      end
    end
  end
  return nil
end

--- Escape a string for use in a Lua pattern
local function escape_pattern(s)
  return s:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$~])", "%%%1")
end

--- Generate an empty out-of-line definition for the declaration under the cursor
function M.generate_definition()
  local bufnr = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1] - 1

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if not (filepath:match("%.[hH]$") or filepath:match("%.hpp$") or filepath:match("%.hxx$")) then
    vim.notify("Not a C++ header file", vim.log.levels.ERROR)
    return
  end

  local class_name = find_class_name(bufnr, row)
  if not class_name then
    vim.notify("Could not determine class name", vim.log.levels.ERROR)
    return
  end

  local decl = get_declaration(bufnr, row)
  if not decl or decl == "" then
    vim.notify("No declaration found", vim.log.levels.ERROR)
    return
  end

  if decl:match("=%s*0%s*;") or decl:match("=%s*default%s*;") or decl:match("=%s*delete%s*;") then
    vim.notify("Cannot generate definition (pure virtual / default / delete)", vim.log.levels.WARN)
    return
  end

  local definition = make_definition(decl, class_name)
  if not definition then
    vim.notify("Could not parse declaration", vim.log.levels.ERROR)
    return
  end

  local method_name = extract_method_name(clean_for_definition(strip_attributes(decl)))

  -- Find the corresponding source file
  local cpp_path = filepath:gsub("%.h$", ".cpp"):gsub("%.H$", ".cpp")
    :gsub("%.hpp$", ".cpp"):gsub("%.hxx$", ".cxx")

  if vim.fn.filereadable(cpp_path) == 0 then
    vim.notify("Source file not found: " .. cpp_path, vim.log.levels.ERROR)
    return
  end

  local cpp_bufnr = vim.fn.bufadd(cpp_path)
  vim.fn.bufload(cpp_bufnr)
  local cpp_lines = vim.api.nvim_buf_get_lines(cpp_bufnr, 0, -1, false)

  -- Check if definition already exists
  if method_name then
    local pat = escape_pattern(class_name) .. "::" .. escape_pattern(method_name) .. "%s*%("
    for _, line in ipairs(cpp_lines) do
      if line:match(pat) then
        vim.notify("Definition already exists for " .. class_name .. "::" .. method_name, vim.log.levels.WARN)
        return
      end
    end
  end

  -- Find insertion point: after the previous method's definition in the .cpp
  local insert_after = #cpp_lines -- default: end of file

  local prev_method = find_previous_method(bufnr, row)
  if prev_method then
    local pat = escape_pattern(class_name) .. "::" .. escape_pattern(prev_method) .. "%s*%("
    for i, line in ipairs(cpp_lines) do
      if line:match(pat) then
        local block_end = find_block_end(cpp_lines, i)
        if block_end then
          insert_after = block_end
        end
        break
      end
    end
  end

  -- Insert: blank line + definition
  local def_lines = vim.split("\n" .. definition, "\n", { plain = true })
  vim.api.nvim_buf_set_lines(cpp_bufnr, insert_after, insert_after, false, def_lines)

  -- Switch to the source file and place cursor inside the empty body
  vim.api.nvim_set_current_buf(cpp_bufnr)
  vim.api.nvim_win_set_cursor(0, { insert_after + 3, 0 })

  vim.notify("Generated " .. class_name .. "::" .. (method_name or "definition"))
end

return M
