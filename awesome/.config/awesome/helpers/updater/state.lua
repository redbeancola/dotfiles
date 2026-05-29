-- helpers/updater/state.lua
-- All modules read/write through this table

-- Private backing store
local _data = {
    -- Public (readable via awesome-client)
    count   = 0,    -- number of pending updates
    percent = 0,    -- current download progress
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
        if     k == "count"   then update_count   = v
        elseif k == "percent" then update_percent = v
        elseif k == "running" then update_running = v
        end
    end,
})

update_count   = _data.count
update_percent = _data.percent
update_running = _data.running

return M
