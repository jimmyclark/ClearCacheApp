-- UDConfig.lua

local M = {}

M.UDTYPE = {
    HALL = 1,
    GAME = 2
}

M.EVENT_RELOAD_GAME  = "EVENT_RELOAD_GAME"

M.UPDATE_CONFIG      = "UPDATE_CONFIG"

M.MANIFEST           = "res/project.manifest"
M.LOCAL_STORAGE      = "ud"
M.VERSION_NAME       = device.writablePath .. "ud/version"
M.UD_CONFIG_FILE     = device.writablePath .. "ud/ud.config"

M.currentVersion     = 0

M.udConfig           = device.writablePath .. M.LOCAL_STORAGE

return M
