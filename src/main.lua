local breakSocketHandle, debugXpCall

function debug.getlistvars()
    local str = ''
    local function stradd(value, i, j, strtype)
        if value then
            if type(value) == 'userdata' then
                str = str .. strtype .. '      userdata  ，'
            else
                str = str .. strtype .. '     "' .. tostring(value) .. '"   ，'
            end
        else
            str =     str .. strtype .. '     "'..'nil'..'"   ，'
        end
    end
    for i = 2, 3 do
        for j = 1, 3 do
            if debug.getlocal(i,j) then
                local x, y = debug.getlocal(i, j)
                stradd(x, i, j, 'name')
                stradd(y, i, j, 'value')
                -- str= str..'\n'
            end
                -- str= str..'--------------------\n'
        end
    end
    -- str= str..'--------------------  end\n\n'
    return str
end

function __G__TRACKBACK__(errorMessage)
    printError("----------------------------------------")
    printError("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    printError(debug.traceback("", 2))
    printError("----------------------------------------")

    if nk and nk.Const then
        errorMessage = "[" .. nk.Const.currentMid .. "]" .. tostring(errorMessage);
    end
    local tracebackStr = tostring(debug.traceback("", 2))
    if (device.platform == "ios") then
        if (nk and nk.Const) then
            local replaceStr = string.format("Users/amnon/devWorkspace/svn_workspaces/Bigfoot/dict/normal/v%s/build/temp/", nk.Const.GAME_VERSION)
            tracebackStr = string.replace(tracebackStr, "/" .. replaceStr, "")
            errorMessage = string.replace(errorMessage, "/ " .. replaceStr, "")
        end
        -- buglyReportLuaException(errorMessage)
        buglyReportLuaException(tostring(errorMessage) .. "\n"
        .. tracebackStr)
    else
        nk.Native:umengError(tostring(errorMessage) .. "\n"
        .. tracebackStr)

    end

    if DEBUG > 0 then
        nk.TopTipManager:showTopTip("有错误日志上报")
        local key = string.find(errorMessage, "\n");
        if key then
            sendErrorLog(tostring(errorMessage) .. "\n" .. debug.traceback("", 2), 0, string.sub(errorMessage, 1, key))
        else
            sendErrorLog(tostring(errorMessage) .. "\n" .. debug.traceback("", 2), 0, crypto.md5(debug.traceback("", 2)))
        end
        if (debugXpCall) then
            debugXpCall()
        end
    end
end

package.path = package.path .. ";src/?.lua";
cc.FileUtils:getInstance():setPopupNotify(false);

require("app.MyApp").new():run();

if (DEBUG > 0) then
    breakSocketHandle, debugXpCall = require("LuaDebug")("localhost", 7003)
    cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle, 0.3, false)
end
