nk = nk or {};

-- 设置元素
local mt = {};
function mt.__index(t, k)
    if k == "userData" then
        return poker.DataProxy:getData(nk.dataKeys.USER_DATA);

    elseif k == "runningScene" then
        return cc.Director:getInstance():getRunningScene();

    elseif k == "userDefault" then
        return cc.UserDefault:getInstance();
    end
end

setmetatable(nk, mt);

-- 平台特性管理类
if device.platform == "android" then
    nk.Native = require("app.android.bridge.LuaJavaBridge").new();

elseif device.platform == "ios" then
    nk.Native = require("app.ios.bridge.LuaIOSBridge").new();

else
    nk.Native = require("app.bridge.BridgeAdapter").new();
end

-- 常量
nk.Const = require("app.common.Const");

-- 数据管理类
nk.GameState = require("app.util.GameState").new();
nk.GameFile = require("app.util.GameFile").new();

-- 公共UI
nk.ui = require("app.ui.init");

if (not nk.GlobalFunction) then
    nk.GlobalFunction = require("app.common.GlobalFunction").new()
end

return nk;
