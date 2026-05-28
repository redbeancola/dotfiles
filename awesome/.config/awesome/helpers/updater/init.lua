-- helpers/updater/init.lua
-- Entry point: `require("helpers.updater")`.
-- Wires together config, state, runner, popup, the periodic timer,
-- and the lxpolkit/pkexec window-placement rule.

local gears  = require("gears")
local ruled  = require("ruled")

local cfg    = require("helpers.updater.config")
local runner = require("helpers.updater.runner")

-- Load popup last; it connects signals that runner emits.
local popup  = require("helpers.updater.popup")  -- noqa: unused local (side-effects)

-- ── Periodic update check ─────────────────────────────────────────────────────
gears.timer {
    timeout   = cfg.check_interval,
    call_now  = true,
    autostart = true,
    callback  = runner.check,
}

-- ── lxpolkit window placement ─────────────────────────────────────────────────
-- Keeps the pkexec auth dialog at a fixed position.
-- If you prefer to manage rules centrally, move this block to rules.lua.
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

-- Return the popup module so callers can do:
--   local updater = require("helpers.updater")
--   updater.toggle()
return popup
