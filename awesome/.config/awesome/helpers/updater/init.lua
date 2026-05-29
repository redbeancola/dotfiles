-- helpers/updater/init.lua
-- Entry point: `require("helpers.updater")`.

local gears  = require("gears")
local ruled  = require("ruled")

local cfg    = require("helpers.updater.config")
local runner = require("helpers.updater.runner")

-- Load popup last; it connects signals that runner emits.
local popup  = require("helpers.updater.popup")  

-- Periodic update check 
gears.timer {
    timeout   = cfg.check_interval,
    call_now  = true,
    autostart = true,
    callback  = runner.check,
}

-- lxpolkit window placement
-- Keeps the pkexec auth dialog at a fixed position.
-- you can move this block to whatever file you define your rules
ruled.client.append_rule {
    id       = "lxpolkit_fixed",
    rule_any = { class = { "lxpolkit", "Lxpolkit" } },
    properties = {
        floating             = true,
        ontop                = true,
        maximized            = false,
        maximized_horizontal = false,
        maximized_vertical   = false,
    },
    callback = function(c)
        c:geometry({ x = cfg.polkit.x, y = cfg.polkit.y })
    end,
}

-- Return the module, global variables and methods can be
-- called externally via awesome-client or required by other modules.
return popup
