local M = {}


local utils = require("global_registers.utils")
local config = require("global_registers.config").options


M.get = function()
    local path = config.save_file
    local file = io.open(path, "r")
    if file == nil then
        return {}
    end
    local content = file:read("*a")
    file:close()
    if content == "" then
        return {}
    end
    return vim.fn.json_decode(content)
end


M.write = function(data)
    local path = config.save_file
    local file = io.open(path, "w")
    if file == nil then
        utils.error("Could not open file for writing: " .. path)
        return {}
    end
    file:write(vim.fn.json_encode(data))
    file:close()
end


return M
