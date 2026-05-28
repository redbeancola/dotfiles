-- helpers/updates/state.lua
-- Single shared-state table for the updater subsystem.
-- All modules read/write through this table so there are no circular deps.

local M = {
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

-- Legacy global aliases expected by external callers (awesome-client, widgets).
-- Writing to M.count etc. also updates the globals.
local _mt = {
    __newindex = function(t, k, v)
        rawset(t, k, v)
        if     k == "count"   then update_count   = v
        elseif k == "percent" then update_percent = v
        elseif k == "running" then update_running = v
        end
    end,
}
setmetatable(M, _mt)

-- Initialise globals now so they exist from the start.
update_count   = M.count
update_percent = M.percent
update_running = M.running

return M
