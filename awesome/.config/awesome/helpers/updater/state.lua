-- helpers/updater/state.lua
-- Single shared-state table for the updater subsystem.
-- All modules read/write through this table so there are no circular deps.

-- Private backing store — keys never exist on M directly, so __newindex
-- fires reliably on every write (including to pre-initialised fields).
local _data = {
    -- Public (readable via awesome-client)
    count   = 0,    -- number of pending updates
    percent = 0,    -- current download progress (0-100)
    running = false,

    -- Private process state
    pid             = nil,
    output          = "",
    current_package = "",
    pending_prompt  = false,

    -- Widget references (set by popup.lua, read by status.lua)
    status_text          = nil,
    update_btn_container = nil,
    cancel_btn_container = nil,
    prompt_btn_container = nil,
    popup                = nil,
}

local M = {}

setmetatable(M, {
    __index = function(_, k)
        return _data[k]
    end,
    __newindex = function(_, k, v)
        _data[k] = v
        -- Keep legacy globals in sync so awesome-client / widgets can read them.
        if     k == "count"   then update_count   = v
        elseif k == "percent" then update_percent = v
        elseif k == "running" then update_running = v
        end
    end,
})

-- Initialise globals now so they exist from the start.
update_count   = _data.count
update_percent = _data.percent
update_running = _data.running

return M
