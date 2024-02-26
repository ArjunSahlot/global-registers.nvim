---@class ConfigModule
---@field defaults Config: default options
---@field options Config: config table extending defaults
local M = {}

local utils = require("global_registers.utils")

M.defaults = {
  save_file = vim.fn.stdpath("data") .. "/global_registers.json",
  global_registers = { "*" },
  update_event = { "ModeChanged", "RecordingLeave" },
  hooks = {
    pre_write_file = function(_) end,
    post_write_file = function(_) end,
    pre_read_file = function() end,
    post_read_file = function(_) end,
    on_change = function(_) end,
  },
  on_load = false,
}

---@class Config
---@field save_file string: path to the file where the global registers will be saved, must be json
---@field global_registers table: list of global registers
---@field update_event table: list of events that will trigger the update of the global registers (includes 'time')
---@field hooks table: list of hooks to be called before and after reading and writing files
---@field on_load boolean: if true, the global registers will be loaded on plugin load
M.options = {}

--- Setup options by extending defaults with the options proveded by the user
---@param options Config: config table
M.__setup = function(options)
  M.options = vim.tbl_deep_extend("force", {}, M.defaults, options or {})

  if not M.options.save_file:match("%.json$") then
    M.options.save_file = M.options.save_file .. ".json"
  end

  if vim.tbl_contains(M.options.global_registers, "*") then
    M.options.global_registers = utils.vim_registers
  end
end

---Format the defaults options table for documentation
---@return table
M.__format_keys = function()
  local tbl = vim.split(vim.inspect(M.defaults), "\n")
  table.insert(tbl, 1, "<pre>")
  table.insert(tbl, 2, "Defaults: ~")
  table.insert(tbl, #tbl, "</pre>")
  return tbl
end

return M
