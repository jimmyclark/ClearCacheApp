--[[
    Class Name          : MyApp
    description         : to wrap the application how to enter in.
    author              : ClarkWu
]]
require("config");

require("cocos.init");
require("framework.init");

require("app.util.LogUtil")

require("core.init");
require("app.init");

local MyApp = class("MyApp", cc.mvc.AppBase);

local logger = poker.Logger.new("MyApp");

function MyApp:ctor()
    MyApp.super.ctor(self);
end

function MyApp:onEnterBackground()
    sendClientLog("应用切到后台")

    if nk.SoundManager:isMusicCanPlay() then
        audio.pauseMusic()
    end
end

function MyApp:onEnterForeground()
    sendClientLog("应用恢复前台")

    if nk.SoundManager:isMusicCanPlay() then
        audio.resumeMusic()

    else
        audio.pauseMusic()
    end

    self:closeAllScreenPopup()
end

-- 关闭弹框
-- 目前只关闭全屏弹框且只在 android 调用
function MyApp:closeAllScreenPopup()
    if (nk and nk.PopupManager and nk.PopupManager:getTopPopup()) then
        local popup = nk.PopupManager:getTopPopup()
        local name = popup.__cname
    end
end

function MyApp:run()
    -- iOS 设置一个全局回调方法
    if (device.platform == "ios") then
        nk.Native:setGlobalFuncToOc()
    end
    -- 随机种子
    math:newrandomseed(tostring(os.time()):reverse():sub(1,6));

    collectgarbage("collect")
    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 5000)

    cc.FileUtils:getInstance():addSearchPath("res/")

    self:initConfigThings()

    self:addSpriteFrames()

    app:enterScene("app.scenes.MainScene");

    -- TEST_PERFORMANCE = 1
    if (TEST_PERFORMANCE and TEST_PERFORMANCE > 0) then
        self:openCostTimeLog()
    end
end

function MyApp:addSpriteFrames()

end

-- 开启每帧消耗多少时间日志
-- 会占用一部分性能
function MyApp:openCostTimeLog()
    if (not self.m_globalScheduler) then
        if (not self.m_lastRefreshTime) then
            self.m_lastRefreshTime = cc.net.SocketTCP.getTime()
        end
        self.m_globalScheduler = require("framework.scheduler").scheduleUpdateGlobal(function ()
            local newTime = cc.net.SocketTCP.getTime()
            local diffTime = newTime - self.m_lastRefreshTime
            self.m_lastRefreshTime = newTime
            local showTime = 0.025
            if (device.platform == "windows" or device.platform == "mac") then
                showTime = 0.0175
            end
            if (diffTime > showTime) then
                LogUtil.d("MyApp", "---- [ cost - time ] = ", diffTime * 1000)
            end
        end)
    end
end

--[[
    初始化常量参数方法
    create-author       : ClarkWu
]]
function MyApp:initConfigThings()
    -- 初始化常量参数
    local ret,errMsg = pcall(function()
        local initResult = nk.Native:getInitThings()

        if initResult ~= "" then
            local initTable = json.decode(initResult)

            nk.Const.GAME_VERSION        = initTable.version or nk.Const.DEFAULT_GAME_VERSION
            nk.Const.GAME_VERSION_UPDATE = nk.Const.GAME_VERSION .. ".0"
            nk.Const.rat = initTable.rat or ""
            nk.Const.imei = initTable.imei or ""
            nk.Const.osv = initTable.osv or ""
            nk.Const.net = initTable.net or ""
            nk.Const.operator = string.trim(initTable.operator or "")
            nk.Const.imsi = initTable.imsi or ""
            nk.Const.mac = initTable.mac or ""
            nk.Const.iconName = initTable.iconName
            nk.Const.supportSDCard = tonumber(initTable.supportSDCard or 0)
            nk.Const.uniqueId = initTable.uniqueId or ""
            nk.Const.deviceId = initTable.deviceId or ""
            nk.Const.androidId = initTable.androidId or ""
            nk.Const.isFirst = (initTable.isFirstStart or "0") == "0"
            nk.Const.versionCode = initTable.versionCode or ""
            nk.Const.locale = initTable.locale or ""
            nk.Const.buildId = initTable.buildId or ""
            nk.Const.phoneNumber = initTable.phonenumber or ""
            nk.Const.isAndroid10 = (initTable.isAndroid10 or "0") == "1"
            local appleSignin = tonumber(initTable.appleSignin) or 0
            nk.Const.supportAppleLogin = (appleSignin == 1) and true or false

            if device.platform ~= "android" then
                nk.Const.supportSDCard = 1
            end

            if initTable.google_id and initTable.google_id ~= "" then
                nk.Const.isGooglePush = true
                nk.Const.googleSid = initTable.google_sid
            end

            nk.Const.model = initTable.model or ""
            nk.Const.model = string.trim(nk.Const.model);

            nk.Const.deviceTotalSize = tonumber(initTable.deviceTotalSize) or 0
            nk.Const.deviceAvalibleSize = tonumber(initTable.deviceAvaliableSize) or 0
        end

        nk.Const.currentApi = nk.Const.defaultApi

        if device.platform == "windows" then
            nk.Const.model = "UnKnown"
            nk.Const.deviceId = getSitemid()
            nk.Const.net      = "未知"

            nk.Const.deviceTotalSize = 1024 * 1024 * 1024 * 10
            nk.Const.deviceAvalibleSize = 1024 * 1024 * 1024 * 3.2
        end
    end)

    local function requireRes()
        local ret, msg = pcall(function ( ... )
            nk.Res = require("app.common.Res")
        end)
    end

    requireRes()

    nk.KeypadManager = require("app.manager.KeypadManager").new()

    if device.platform == "windows" or device.platform == "mac" then
        nk.Const.GAME_VERSION = nk.Const.DEFAULT_GAME_VERSION

    elseif nk.Const.GAME_VERSION == nil then
        nk.Const.GAME_VERSION = nk.Const.DEFAULT_GAME_VERSION
    end

    if not nk.Const.model then
        nk.Const.model = ""
    end

    if not nk.Const.operator then
        nk.Const.operator = ""
    end

    if not nk.Const.phoneNumber then
        nk.Const.phoneNumber = ""
    end

    nk.Const.model = string.gsub(nk.Const.model,"([^%s%a%d%._-])","")
    nk.Const.operator = string.gsub(nk.Const.operator,"([^%s%a%d%._-])","")
    nk.Const.phoneNumber = string.gsub(nk.Const.phoneNumber, "([^%s%a%d%._-])","")

    nk.Const.model = string.trim(nk.Const.model)
    nk.Const.operator = string.trim(nk.Const.operator)
end

--[[
    跳入场景方法
    @param sceneName        - 场景名称
    @param args             - 场景参数
    @param transitionType   - 切换场景类型
    @param time             - 切换时间
    @param more             - 其他参数
    create-author       : ClarkWu
]]
function MyApp:enterScene(sceneName, args, transitionType, time, more)
    if nk.Native then
        if device.platform == "android" then
            nk.Native:closeEditBox()
        end
    end

    if (nk and nk.Const) then
        nk.Const.IS_CHANGING_SCENE = true
    end

    local scenePackageName = sceneName
    local sceneClass = require(scenePackageName)
    local scene = sceneClass.new(unpack(checktable(args)))
    display.replaceScene(scene, transitionType, time, more)

    nk.Const.lastSceneName = sceneName
    return sceneClass
end

return MyApp
