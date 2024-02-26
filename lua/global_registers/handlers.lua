local M = {}

-- plan:
-- 1. whenever user changes mode or leaves recording, update the global registers
-- "ModeChanged", "RecordingLeave"
-- vim.fn.getreginfo({register})
-- vim.fn.setreg({register}, {text}, {linewise})
-- vim.fn.getreg({register})
-- 2. every time designated file gets updated, update the global registers
-- https://neovim.io/doc/user/lua.html#vim.uv

local config = require("global_registers.config").options
local utils = require("global_registers.utils")
local db = require("global_registers.database")

local changed = false

local function registers_updated(registers)
  for _, register in ipairs(config.global_registers) do
    local current = vim.fn.getreg(register)
    local saved = registers[register]
    if current ~= saved then
      return true
    end
  end
  return false
end

local function update_db()
  local data = {}
  for _, register in ipairs(config.global_registers) do
    local info = vim.fn.getreginfo(register)
    if info.regcontents == nil then
      info = {
        regcontents = "",
      }
    end
    if type(info.regcontents) == "table" then
      for i, v in ipairs(info.regcontents) do
        info.regcontents[i] = vim.fn.keytrans(v)
      end
    else
      info.regcontents = vim.fn.keytrans(info.regcontents)
    end
    data[register] = info
  end
  changed = true
  db.write(data)
end

local function check_update()
  local data = db.get()
  if data == nil then
    return
  end

  if registers_updated(data) then
    config.hooks.on_change(data)
    update_db()
  end
end

local function update_registers()
  local data = db.get()
  if data == nil then
    return
  end

  for _, register in ipairs(config.global_registers) do
    local info = data[register]
    if info == nil then
      goto continue
    end
    if type(info.regcontents) == "table" then
      for i, v in ipairs(info.regcontents) do
        info.regcontents[i] = vim.api.nvim_replace_termcodes(v, true, true, true)
      end
    else
      info.regcontents = vim.api.nvim_replace_termcodes(info.regcontents, true, true, true)
    end
    vim.fn.setreg(register, info)
    ::continue::
  end
end

local function watch_file()
  local uv = vim.loop
  local handle = uv.new_fs_event()
  local flags = {
    watch_entry = false,
    stat = false,
    recursive = false,
  }

  if handle == nil then
    utils.error("Error creating file update event")
    return
  end
  uv.fs_event_start(handle, config.save_file, flags, function(err, _, _)
    if err then
      vim.schedule(function()
        utils.error("Error in file update event: " .. err)
      end)
      return
    end

    if changed then
      changed = false
    else
      vim.schedule(update_registers)
    end
    uv.fs_event_stop(handle)
    watch_file()
  end)
end

M.setup = function()
  local group = vim.api.nvim_create_augroup("global_registers", { clear = true })

  for _, event in ipairs(config.update_event) do
    vim.api.nvim_create_autocmd(event, {
      group = group,
      callback = check_update,
    })
  end
  watch_file()
end

return M
