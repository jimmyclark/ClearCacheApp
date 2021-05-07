--[[
    Class Name          : GameState
    description         : 用户状态信息管理类.
    author              : ClarkWu
]]
local GameState = class("GameState");

function GameState:ctor()
end

--[[
    保存布尔类型的值到文件中
    @param key String    - 键值
    @param value Boolean - 布尔值
    create-author       : ClarkWu
]]
function GameState:putBool(key, value)
    cc.UserDefault:getInstance():setBoolForKey(key, value);
    cc.UserDefault:getInstance():flush();
end

--[[
    保存数值(double)类型的值到文件中
    @param key String           - 键值
    @param value Number(double) - 数值
    create-author       : ClarkWu
]]
function GameState:putDouble(key, value)
    cc.UserDefault:getInstance():setDoubleForKey(key, value);
    cc.UserDefault:getInstance():flush();
end

--[[
    保存数值(float)类型的值到文件中
    @param key String           - 键值
    @param value Number(float)  - 数值
    create-author       : ClarkWu
]]
function GameState:putFloat(key, value)
    cc.UserDefault:getInstance():setFloatForKey(key, value);
    cc.UserDefault:getInstance():flush();
end

--[[
    保存数值(Int)类型的值到文件中
    @param key String           - 键值
    @param value Number(Int)    - 数值
    create-author       : ClarkWu
]]
function GameState:putInt(key, value)
    cc.UserDefault:getInstance():setIntegerForKey(key, value);
    cc.UserDefault:getInstance():flush();
end

--[[
    保存字符串类型的值到文件中
    @param key String           - 键值
    @param value String         - 字符串
    create-author       : ClarkWu
]]
function GameState:putString(key, value)
    if key and value then
        cc.UserDefault:getInstance():setStringForKey(key, value);
        cc.UserDefault:getInstance():flush();
    end
end

--[[
    从文件中得到键值key对应的布尔值
    @param key String          - 键值
    @param defaultBool Boolean - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameState:getBool(key,defaultBool)
    return cc.UserDefault:getInstance():getBoolForKey(key, defaultBool or false);
end

--[[
    从文件中得到键值key对应的Number(double)值
    @param key String             - 键值
    @param default Number(double) - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameState:getDouble(key,default)
    return cc.UserDefault:getInstance():getDoubleForKey(key, default or 0);
end

--[[
    从文件中得到键值key对应的Number(float)值
    @param key String             - 键值
    @param default Number(float)  - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameState:getFloat(key,default)
    return cc.UserDefault:getInstance():getFloatForKey(key, default or 0);
end

--[[
    从文件中得到键值key对应的Number(int)值
    @param key String             - 键值
    @param default Number(int)    - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameState:getInt(key,default)
    return cc.UserDefault:getInstance():getIntegerForKey(key, default or 0);
end

--[[
    从文件中得到键值key对应的字符串值
    @param key String             - 键值
    @param default String         - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameState:getString(key,default)
    return cc.UserDefault:getInstance():getStringForKey(key, default or "");
end

return GameState;