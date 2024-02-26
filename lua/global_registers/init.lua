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
local global_registers = {}

--- Setup the plugin
---@param options Config: config table
---@eval { ['description'] = require('global_registers.config').__format_keys() }
global_registers.setup = function(options)
  require("global_registers.config").__setup(options)

  if require("global_registers.config").options.on_load then
    require("global_registers.handlers").setup()
  end
end

return global_registers
