local M = {}

local utils = require("global_registers.utils")
local config = require("global_registers.config").options

M.get = function()
  config.hooks.pre_read_file()

  local path = config.save_file
  local file = io.open(path, "r")
  if file == nil then
    return {}
  end
  local content = file:read("*a")
  file:close()

  local data = {}
  if content ~= "" then
    data = vim.fn.json_decode(content)
  end

  config.hooks.post_read_file(data)

  return data
end

M.write = function(data)
  config.hooks.pre_write_file(data)
  local path = config.save_file
  local file = io.open(path, "w")
  if file == nil then
    utils.error("Could not open file for writing: " .. path)
    return {}
  end

  file:write(vim.fn.json_encode(data))
  file:close()
  config.hooks.post_write_file(data)
end

return M
