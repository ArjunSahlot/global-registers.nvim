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


local function possible_update()
    local data = db.get()
    if data == nil then
        return
    end

    for _, register in ipairs(data) do
        local info = vim.fn.getreginfo(register)
        if info.regcontents == nil then
            info.regcontents = ""
        end
        if info.regcontents ~= data[register] then
            vim.fn.setreg(register, data[register])
        end
    end
end

M.write_all_registers_to_file = function()
    local data = {}
    for _, register in ipairs(utils.vim_registers) do
        local info = vim.fn.getreginfo(register)
        if info.regcontents == nil then
            info.regcontents = ""
        end
        data[register] = info.regcontents
    end
    db.write(data)
end


M.setup = function()
    local group = vim.api.nvim_create_augroup("global_registers")
    vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        callback = possible_update,
    })
    vim.api.nvim_create_autocmd("RecordingLeave", {
        group = group,
        callback = possible_update,
    })
end


return M
