---@tag global_registers

---@brief [[
---This is a template for a plugin. It is meant to be copied and modified.
---The following code is a simple example to show how to use this template and how to take advantage of code
---documentation to generate plugin documentation.
---
---This simple example plugin provides a command to calculate the maximum or minimum of two numbers.
---Moreover, the result can be rounded if specified by the user in its configuration using the setup function.
---
--- <pre>
--- `:PluginName {number} {number} {max|min}`
--- </pre>
---
--- The plugin can be configured using the |global_registers.setup()| function.
---
---@brief ]]

---@class GlobalRegistersModule
---@field setup function: setup the plugin
---@field file function: output the save file path
local global_registers = {}

local config = require("global_registers.config").options

--- Setup the plugin
---@param options Config: config table
---@eval { ['description'] = require('global_registers.config').__format_keys() }
global_registers.setup = function(options)
  require("global_registers.config").__setup(options)
  require("global_registers.handlers").setup()
end

---Output the save file path
---@return string
global_registers.file = function()
  local path = config.save_file
  print("The global registers are saved at: " .. path)
end

return global_registers
