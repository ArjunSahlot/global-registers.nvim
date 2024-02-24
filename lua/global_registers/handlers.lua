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


local function registers_updated(registers)
    for _, register in ipairs(utils.vim_registers) do
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
    for _, register in ipairs(utils.vim_registers) do
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
    db.write(data)
end

M.update_db = update_db

local function check_update()
    local data = db.get()
    if data == nil then
        return
    end

    if registers_updated(data) then
        update_db()
        print("Global registers updated")
    end
end

local function update_registers()
    local data = db.get()
    print("p1")
    if data == nil then
        return
    end
    print("p2")

    if not registers_updated(data) then
        return
    end
    print("p3")

    for _, register in ipairs(utils.vim_registers) do
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
        print("Setting register " .. register)
        vim.fn.setreg(register, info)
        ::continue::
    end
    print("Local registers updated")
end

M.update_registers = update_registers

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
    uv.fs_event_start(handle, config.save_file, flags, function(err, fname, _)
        if err then
            vim.schedule(function()
                utils.error("Error in file update event: " .. err)
            end)
            return
        end

        print("File updated: " .. fname)
        vim.schedule(update_registers)
        uv.fs_event_stop(handle)
        watch_file()
    end)
end


M.setup = function()
    -- local group = vim.api.nvim_create_augroup("global_registers", { clear = true })
    -- vim.api.nvim_create_autocmd("ModeChanged", {
    --     group = group,
    --     callback = check_update,
    -- })
    -- vim.api.nvim_create_autocmd("RecordingLeave", {
    --     group = group,
    --     callback = check_update,
    -- })
    watch_file()
end


return M
