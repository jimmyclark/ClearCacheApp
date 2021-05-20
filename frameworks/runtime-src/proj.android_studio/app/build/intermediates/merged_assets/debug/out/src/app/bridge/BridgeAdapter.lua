local BridgeAdapter = class("BridgeAdapter")

function BridgeAdapter:ctor()
    if device.platform == "android" then
        self.m_luaBridge = require("app.android.bridge.LuaJavaBridge").new()

    elseif device.platform == "mac" then
        self.m_luaBridge = require("app.ios.bridge.LuaMacBridge").new()

    elseif device.platform == "ios" then
        self.m_luaBridge = require("app.ios.bridge.LuaIOSBridge").new()

    elseif device.platform == "windows" then
        self.m_luaBridge = require("app.bridge.LuaWinBridge").new()
    end
end

function BridgeAdapter:getInitThings()
    return ""
end

return BridgeAdapter