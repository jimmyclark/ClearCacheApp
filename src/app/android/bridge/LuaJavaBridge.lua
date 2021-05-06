local TAG = "LuaJavaBridge"
local M   = class(TAG)

function M:ctor()

end

function M:call_(javaClassName, javaMethodName, javaParams, javaMethodSig)
    local ok,ret = luaj.callStaticMethod(javaClassName, javaMethodName, javaParams, javaMethodSig)
    if not ok then
        if ret == -1 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -1 不支持的参数类型或返回值类型")
        elseif ret == -2 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -2 无效的签名")
        elseif ret == -3 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -3 没有找到指定的方法")
        elseif ret == -4 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -4 Java 方法执行抛出了异常")
        elseif ret == -5 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -5 Java 虚拟机出错")
        elseif ret == -6 then
            LogUtil.d(TAG, "call ", javaMethodName, " failed, -6 Java 虚拟机出错")
        end
    else
        return ok,ret
    end
    return false, nil
end

function M:getInitThings()
    local ok,ret = self:call_("com/game/core/Function","getInitThings",{},"()Ljava/lang/String;")
    if ok then
        return ret
    end
    return ""
end

function M:closeEditBox()
    local ok,ret = self:call_("com/game/core/Function","hideEditDialog",{},"()V")

    if ok then
        return ret
    end

    return ""
end

function M:closeStartScreen()
    self:call_("com/game/core/Function", "closeStartScreen", {}, "()V")
end

return M
