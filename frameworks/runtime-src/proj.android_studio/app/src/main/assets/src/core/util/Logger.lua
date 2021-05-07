--[[
    Class Name          : Logger
    description         : to log every class.
    author              : ClarkWu
]]
local Logger = class("Logger");

Logger.LEVEL_FETAL  = 1;
Logger.LEVEL_ERROR  = 2;
Logger.LEVEL_WARN   = 3;
Logger.LEVEL_INFO   = 4;
Logger.LEVEL_DEBUG  = 5;

Logger.LEVEL_TAGS   = {"FETAL", "ERROR", "WARN", "INFO", "DEBUG"};

if device.platform == "windows" then
    Logger.outputs = {print};
else
    Logger.outputs = {printInfo};
end

function Logger:ctor(name)
    self.m_name = name;
    self.m_isEnabled = true;
end

--[[
    设置标签名称方法
    create-author       : ClarkWu
]]
function Logger:setTag(name)
    self.m_name = name;
    return self;
end

--[[
    设置是否可以使用方法
    @param  isEnabled   Boolean
            true - 可用       false - 不可用
    @return  self
    create-author       : ClarkWu
]]
function Logger:enabled(isEnabled)
    self.m_isEnabled = isEnabled;
    return self;
end

--[[
    显示日志方法(直接显示日志) ==> Log.d
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:debug(...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_DEBUG, self.m_name, "%s", self:concatParams(...))
                or self;
end

--[[
    显示日志方法(显示格式化日志) ==> Log.d
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:debugf(fmt, ...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_DEBUG, self.m_name, fmt, ...)
                or self;
end

--[[
    显示日志方法(直接显示日志) ==> Log.i
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:info(...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_INFO, self.m_name, "%s", self:concatParams(...))
                or self;
end

--[[
    显示日志方法(显示格式化日志) ==> Log.i
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:infof(fmt, ...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_INFO, self.m_name, fmt, ...)
                or self;
end

--[[
    显示日志方法(直接显示日志) ==> Log.w
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:warn(...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_WARN, self.m_name, "%s", self:concatParams(...))
                or self;
end

--[[
    显示日志方法(显示格式化日志) ==> Log.w
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:warnf(fmt, ...)
    return self.m_isEnabled and self:log(false, Logger.LEVEL_WARN, self.m_name, fmt, ...)
        or self;
end

--[[
    显示日志方法(直接显示日志) ==> Log.e
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:error(...)
    return self.m_isEnabled and self:log(true, Logger.LEVEL_ERROR, self.m_name, "%s", self:concatParams(...))
        or self;
end

--[[
    显示日志方法(显示格式化日志) ==> Log.e
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:errorf(fmt, ...)
    return self.m_isEnabled and self:log(true, Logger.LEVEL_ERROR, self.m_name, fmt, ...)
            or self;
end

--[[
    普通打印方法
    @param msg String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:normalPrint(msg)
    if DEBUG >= Logger.LEVEL_DEBUG then
        if type(msg) == "table" then
            sendClientLog(json.encode(msg));

        else
            sendClientLog(msg);
        end
    end
end

--[[
    显示日志方法
    @param stackTrace 是否有堆栈信息
           level      日志级别
           tag        标签名称
           fmt        格式化文本
           ...        String  其他参数
    @return  self
    create-author       : ClarkWu
]]
function Logger:log(stackTrace, level, tag, fmt, ...)
    if DEBUG >= level then
        LogUtil.d("[Logger]", tag, fmt)
    end

    return self;
end

--[[
    连接文本方法
    @param ... String 信息
    @return  self
    create-author       : ClarkWu
]]
function Logger:concatParams(...)
    local para = {...};
    local spara = {};

    for i,v in ipairs(para) do
        if type(v) == "table" then
            spara[#spara + 1] = json.encode(v);
        else
            spara[#spara + 1] = tostring(v);
        end
    end

    return table.concat(spara, " ");
end

return Logger;
