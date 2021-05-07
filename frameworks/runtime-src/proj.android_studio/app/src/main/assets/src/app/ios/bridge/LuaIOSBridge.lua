local TAG = "LuaIOSBridge"
local M   = class(TAG)

function M:ctor()

end

function M:call_(iosClassName, methodName, tableParams)
    local ok,ret = luaoc.callStaticMethod(iosClassName, methodName, tableParams)
    if not ok then
    	local msg = string.format("luaoc.callStaticMethod(\"%s\", \"%s\", \"%s\") - error: [%s] ",
                iosClassName, methodName, tostring(tableParams), tostring(ret))
        if ret == -1 then
            LogUtil.d(TAG, " call_ ", msg .. "INVALID PARAMETERS")
        elseif ret == -2 then
            LogUtil.d(TAG, " call_ ", msg .. "CLASS NOT FOUND")
        elseif ret == -3 then
            LogUtil.d(TAG, " call_ ", msg .. "METHOD NOT FOUND")
        elseif ret == -4 then
            LogUtil.d(TAG, " call_ ", msg .. "EXCEPTION OCCURRED")
        elseif ret == -5 then
            LogUtil.d(TAG, " call_ ", msg .. "INVALID METHOD SIGNATURE")
        else
            LogUtil.d(TAG, " call_ ", msg .. "UNKNOWN")
        end
    else
        return ok, ret
    end
    return false, nil
end

-- 初始化参数设置
function M:getInitThings()
    local ok, ret = self:call_("Platform","getInitThings",{})

    LogUtil.d(TAG, " getInitThings ret = ", ret)
    if ok then
        return json.encode(ret)
    end
    return ""
end

return M
