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

`global-registers.nvim` was built to be as unobtrusive as possible. Press `yy` here, press `p` there, and it just works! It's sort of a missing feature that should have been built into `neovim` from the start. Once you start using it, you won't even know it exists!


## Behind the scenes (how it works)

In order to have the same registers across all your neovim instances, `global-registers.nvim` has to keep track of all the (configured) registers in a file. 
