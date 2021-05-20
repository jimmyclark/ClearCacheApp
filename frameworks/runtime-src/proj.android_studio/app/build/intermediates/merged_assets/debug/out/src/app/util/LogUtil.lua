-- LogUtil.lua
-- Author: Amnon
-- Date: 2017-03-24 23:50:52
-- Desc: 日志管理

require("lfs")
local inspect = require("app.util.inspect")
_G.LogUtil = _G.LogUtil or {}

local M = _G.LogUtil

-- 最大日志数量
M.MAX_LONG_LOG_NUM = 50000

function M.init()
    local filePath     = device.writablePath .. "log" .. device.directorySeparator
    if (not io.exists(filePath)) then
        lfs.mkdir(filePath)
    end
    M.filePath = filePath
    M.isOpen = DEBUG > 0 and true or false
    M.logList = {}
    return true
end

function M.v(tag, ...)
    M.base(1, "VERBORSE -- ",tag,...)
end

function M.g(tag, ...)
    M.base(2, "RESPONSE -- ",tag,...)
end

function M.d(tag, ...)
    M.base(3, "DEBUG -- ",tag,...)
end

function M.i(tag, ...)
    M.base(4, "INFO -- ",tag,...)
end

function M.e(tag, ...)
    M.base(5, "ERROR -- ",tag,...)
end

function M.w(tag, ...)
    M.base(6, "WARN -- ",tag,...)
end

function M.a(tag, ...)
    M.base(7, "ASSERT -- ",tag,...)
end

function M.vWF(tag, ...)
    M.v(tag, ...)
    M.writeFile(tag, ...)
end

function M.dWF(tag, ...)
    M.d(tag, ...)
    M.writeFile(tag, ...)
end

function M.iWF(tag, ...)
    M.i(tag, ...)
    M.writeFile(tag, ...)
end

function M.eWF(tag, ...)
    M.e(tag, ...)
    M.writeFile(tag, ...)
end

function M.wWF(tag, ...)
    M.w(tag, ...)
    M.writeFile(tag, ...)
end

function M.aWF(tag, ...)
    M.a(tag, ...)
    M.writeFile(tag, ...)
end

-- 特殊输出
-- @param tag 标记
-- @param options { 打印参数
--          depth   打印深度
--          newline 换行标示 默认 ‘\n’
--          indent  缩进 默认 '  '
--          process 对打印数据进行修改【暂不深入研究,可见此处 https://github.com/kikito/inspect.lua 】
-- }
function M.s(tag, options, ...)
    if (not M.isLogOpen()) then
        return
    end
    local tagPrefix = "CUSTOM_LOG --"
    local info = ""
    for _,v in pairs({...}) do
        if (type(v) == "string") then
            info = info .. v
        else
            info = info .. inspect(v, options)
        end
    end

    if #M.logList + 1 > M.MAX_LONG_LOG_NUM then
        local needRemoveNum = #M.logList + 1 - M.MAX_LONG_LOG_NUM

        local count = 0

        for i = 1, needRemoveNum do
            table.remove(M.logList, 1)
        end
    end

    local strInfo = string.format("%s%s:%s",tostring(tagPrefix),tostring(tag),tostring(info))
    print(strInfo)
    M.logList[#M.logList + 1] = os.date("%Y-%m-%d %H:%M:%S") .. "::::" .. cc.net.SocketTCP:getTime() .. " : " .. strInfo
end

function M.writeFile(tag, ...)
    if (not M.isLogOpen()) then
        return
    end
    local datePreFix   = os.date("%Y-%m-%d %H:%M:%S") or ""
    datePreFix = datePreFix .. "::::" .. cc.net.SocketTCP:getTime()
    local strInfo      = string.format("%s%s%s%s", datePreFix , " : ", M.getData("", tag,...) , "\n")
    io.writefile(M.filePath, strInfo, "a+")
end

-- 日志基础类
-- @param level 日志级别
-- @param tagPrefix 标记前缀
-- @param tag 标记
-- @param ... 可变参数
function M.base(level, tagPrefix, tag, ...)
    if (not M.isLogOpen()) then
        return
    end
    local strInfo = M.getData(tagPrefix, tag, ...)
    print(strInfo)

    if #M.logList + 1 > M.MAX_LONG_LOG_NUM then
        local needRemoveNum = #M.logList + 1 - M.MAX_LONG_LOG_NUM

        local count = 0

        for i = 1, needRemoveNum do
            table.remove(M.logList, 1)
        end
    end

    M.logList[#M.logList + 1] = os.date("%Y-%m-%d %H:%M:%S") .. "::::" ..  cc.net.SocketTCP:getTime() .. " : " .. strInfo
end

-- 获取日志数据
function M.getData(tagPrefix, tag, ...)
    tag = tag or ""
    tagPrefix = tagPrefix or "INFO--"
    local info = ""
    for _,v in pairs({...}) do
        if (type(v) == "string") then
            info = info .. v .. " "
        else
            info = info .. inspect(v) .. " "
        end
    end
    return string.format("%s%s:%s",tostring(tagPrefix),tostring(tag),tostring(info))
end

-- 日志写到文件中
-- 耗时操作
function M.writeToFile(mid)
    local fileName = ""

    local mode = "a+"
    local dateName     = os.date("%Y%m%d_%H%M%S") or ""
    local fileName     = M.filePath .. dateName .. ".log"

    if mid then
        fileName = string.gsub(fileName, "%.log", "_" .. mid .. "_" .. BUILD_TIME .. ".log")
    end

    local file = io.open(fileName, mode)

    if file then
        local listCount = #M.logList

        for i = 1, listCount do
            file:write(M.logList[i] .. "\n")
        end

        file:write("************ 此包的打包时间: **************: " .. BUILD_TIME .. "\n")

        io.close(file)
    end

    return fileName
end

---
-- 是否需要输出日志
function M.isLogOpen ()
    if _G.DEBUG > 0 and M.isOpen then
        return true
    end
    return false
end

M.init()
