# global-registers.nvim
Copy and paste seamlessly between active neovim instances!

`global-registers.nvim` is a neovim plugin that allows you to share your registers between all your neovim instances. This means that you can copy some text in one neovim instance, and paste it seamlessly into another neovim instance! **Everything works as you expect it to!**

## Install & Configure

### Minimal

```lua
{
    "ArjunSahlot/global-registers.nvim",
    config = function()
        -- use the default configuration
        require("global_registers").setup({})
    end
}
```

### Default

```lua
{
    "ArjunSahlot/global-registers.nvim",
    config = function()
        require("global_registers").setup({
            -- Start tracking/updating registers as soon as you open a new neovim instance.
            on_load = true,

            -- This is the list of registers that will be shared between all instances.
            -- global-registers.nvim will only be aware of the registers in this list,
            -- and it will be completely oblivious to any other registers.
            -- If you want to share all registers, use { "*" }.
            -- Example: { "a", "b", "c" }
            global_registers = { "*" },

            -- This is where all the global registers are saved
            -- If file doesn't end in .json, it will be appended automatically
            save_file = vim.fn.stdpath("data") .. "/global_registers.json",

            -- This is the time (milliseconds) that global-registers.nvim will wait before
            -- writing to the global registers file. This is to prevent writing to the file
            -- while neovim is exiting, which will create a hangup. If you're experiencing
            -- hangs, try increasing this value.
            lag = 50,

            -- This is the list of events that will trigger an update to the global
            -- registers. Unfortunately, neovim doesn't natively track register updates,
            -- so we have to workaround this by listening to certain events where
            -- registers are likely to be updated.
            -- These 2 events will cover 95% of your use cases.
            update_event = { "ModeChanged", "RecordingLeave" },

            -- These are the hooks that you can use to trigger custom behavior
            -- at certain points.
            hooks = {
                -- Before writing to the global registers file.
                -- args: (registers: table)
                pre_write_file = function(_) end,

                -- After writing to the global registers file.
                -- args: (registers: table)
                post_write_file = function(_) end,

                -- Before reading from the global registers file.
                pre_read_file = function() end,

                -- After reading from the global registers file.
                -- args: (registers: table)
                post_read_file = function(_) end,

                -- global-registers.nvim notices that the registers have changed.
                -- args: (registers: table)
                on_change = function(_) end,
            },
        })
    end
}
```


## Usage

`global-registers.nvim` was built to be as unobtrusive as possible. Press `yy` here, press `p` there. Press `qq` here, press `@q` there. It just works! Think of it as a missing feature that should have been built into `neovim` from the start. Once you start using it, you won't even know it exists!


## Behind the scenes (how it works)

In order to have the same registers across all your neovim instances, `global-registers.nvim` has to keep track of all the (configured) registers in a file. Whenever you edit these registers in a local instance of neovim, it will update the save file. Whenever other neovim instances detect a change in the save file, they will refresh their own registers to match the save file.


## Troubleshooting

`global-registers.nvim` tries to do things which neovim doesn't provide native support for, such as tracking register changes. This means that there are some edge cases where it might not work as expected. If you're experiencing any issues, please check this section and open an issue if you don't find a solution.

#### Hangs on exit

If you're experiencing hangs when exiting neovim, try increasing the `lag` value in the configuration. This is the time (milliseconds) that `global-registers.nvim` will wait before writing to the global registers file. This is to prevent writing to the save file while neovim is exiting, which will create a hangup.


## Contributing

Contributions are not only welcome, but encouraged! I'm rather new to neovim plugin development, so I'm sure there are many ways to improve this plugin. If you have any ideas, feel free to open an issue or a pull request!

If you do plan on contributing, I have added how the project is structured below. This should help you understand the codebase and make it easier for you to contribute.


### Project structure

#### GitHub Workflows

* `docs`
    * Documentation is automatically generated and updated in the `doc/global_registers.txt` file. This is done using  [`docgen`](https://github.com/tjdevries/tree-sitter-lua/tree/master/lua/docgen). This happens every time you push to the repository.
* `lint`
    * This workflow runs `luacheck` and `stylua` to ensure that the code is linted and formatted correctly. This happens every time you push to the repository.
* `test`
    * This workflow runs the tests in the `tests` directory using [`plenary.nvim`](https://github.com/nvim-lua/plenary.nvim). This happens every time you push to the repository.
* `release`
    * This workflow is triggered when a new release is created. It will automatically create a new release on the GitHub repository and upload the plugin to [luarocks](https://luarocks.org/).


#### Plugin Structure

* `plugin/global_registers.lua`
    * This is the main file that is sourced by neovim. It calls the setup function. Doesn't need to be changed.
* `lua/global_registers/`
    * `init.lua`:
    Contains the setup function, which loads configuration and sets up handlers if `on_load` is true.
    * `config.lua`:
    Configuration file. This is where the default configuration is set and the user configuration is merged with the default configuration.
    * `handlers.lua`:
    This file contains the bulk of the code. It sets up the handlers that listen for register changes and also save file changes, it even updates local registers. Think of this as a file that handles and interfaces with everything.
    * `utils.lua`:
    Utility things. List of vim registers for `{ "*" }` (all register configuration) and error function for now.
    * `database.lua`:
    This file contains the functions that interface with the save file ("database"). It can read and write to the save file.

