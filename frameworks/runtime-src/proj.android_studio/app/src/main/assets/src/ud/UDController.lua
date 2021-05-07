local TAG = "UDController"
local UDConfig = require("ud.UDConfig")
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
local LocalFileUtils = require("app.util.LocalFileUtils")

local M = class(TAG)

function M:ctor(udType, gameId, isSingleThread)
    if (udType ~= UDConfig.UDTYPE.HALL) then
        LogUtil.w(TAG, "not support ud type = ", udType)
        return
    end
    -- 字符标识
    self.m_configStr        = poker.LangUtil:getText("HOTUD","READY_UPDATE")       -- 正在配置更新, 请耐心等待...
    self.m_updateStr        = poker.LangUtil:getText("HOTUD","UPDATING")           -- 正在更新资源, 请耐心等待...
    self.m_succStr          = poker.LangUtil:getText("HOTUD","FINISH")             -- 更新完成, 正在准备资源, 请耐心等待...
    if (device.platform == "ios") then
        self.m_configStr = poker.LangUtil:getText("HOTUD", "WAITING")
        self.m_updateStr = self.m_configStr
        self.m_succStr   = self.m_configStr
    end
    self.m_remote_api_version = nk.Const.HOT_UD_FILE .. "/" .. nk.Const.GAME_VERSION .. "/version_" .. nk.Const.currentApi .. ".manifest"
    local projectManifest = string.format("res/project_%s.manifest", nk.Const.currentApi)
    self.m_assetManager   = cc.AssetsManagerEx:create(projectManifest, UDConfig.udConfig)
    self.m_requestTimeout = 1
    if (self.m_assetManager) then
        self.m_assetManager:retain()
        if (isSingleThread) then
            self.m_assetManager:singleThread()
        end
    end
end

-- 设置委托对象
function M:setDelegate(obj)
    self.m_delegate = obj
end

function M:readFile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*all")
        io.close(file)
        return content
    end
    return nil
end

-- 是否需要更新
function M:needUpdate()
    local lastDownloadSize, curDownloadSize = 0, 0
    local hasDownloadFile, totalFile        = 0, 0
    local totalSize                         = 0
    local beginTime                         = poker.getTime()
    local lastTime                          = beginTime
    local isSkipCheckSpeed                  = false
    local timeoutCounts                     = 0
    local function onUpdateEvent(event)
        local eventCode = event:getEventCode()
        if eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_NO_LOCAL_MANIFEST then
            LogUtil.d("No local manifest file found, skip assets update.")
            self:normalExit()
        elseif  eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_PROGRESSION then
            local assetId       = event:getAssetId()
            local percent       = event:getPercent()
            local downloadState = event:getDownloadState()
            local percentFile   = event:getPercentByFile()
            -- LogUtil.d("----------------------------------------------")
            -- LogUtil.d(TAG, "assetId = ", assetId)
            -- LogUtil.d(TAG, "update Resource = ", percent)
            -- LogUtil.d(TAG, "update Resource file = ", percentFile)
            -- 设置当前的下载状态
            if (downloadState and string.len(downloadState) > 0) then
                local tempDownloadState = string.split(downloadState, ",")
                if (not table.isEmpty(tempDownloadState)) then
                    -- hasDownloadFile = tonumber(tempDownloadState[1])
                    totalFile       = tonumber(tempDownloadState[2])
                    curDownloadSize = (tonumber(tempDownloadState[3]) == -1) and curDownloadSize or tonumber(tempDownloadState[3])
                    totalSize       = tonumber(tempDownloadState[4])
                end
            end
            if assetId == cc.AssetsManagerExStatic.VERSION_ID then
                self:updateProgress(1)
                isSkipCheckSpeed = true
            elseif assetId == cc.AssetsManagerExStatic.MANIFEST_ID then
                if (tonumber(percent) >= 100) then
                    beginTime = poker.getTime()
                    lastTime  = 0
                    lastDownloadSize = 0
                end
                self:updateProgress(2, percent)
                isSkipCheckSpeed = true
                -- self:showTest()
            else
                self:updateProgress(3, percent)
            end
            self.m_requestTimeout = 0
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DOWNLOAD_MANIFEST or
            eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_PARSE_MANIFEST then
            LogUtil.d("Fail to download manifest file, update skipped.")
            self:failedLogic(eventCode)
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.NEW_VERSION_FOUND then
            LogUtil.d("发现新版本开始升级")
            self.m_requestTimeout = 0
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ASSET_UPDATED then
            -- 每个文件更新完会调用一次
            hasDownloadFile = hasDownloadFile + 1
            LogUtil.d("asset updated", " assetId = ", event:getAssetId())
            self.m_requestTimeout = 0
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FAILED then
            LogUtil.d("update failed")
            self:failedLogic(eventCode)
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_DECOMPRESS then
            LogUtil.d("error decompress")
            self:failedLogic(eventCode)
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ALREADY_UP_TO_DATE or
            eventCode == cc.EventAssetsManagerEx.EventCode.UPDATE_FINISHED then
            LogUtil.d("Update finished.")
            if (self.m_delegate and self.m_delegate.onUpdateTxtProgress) then
                self.m_delegate:onUpdateTxtProgress(self.m_succStr)
            end
            self:normalSuccess()
        elseif eventCode == cc.EventAssetsManagerEx.EventCode.ERROR_UPDATING then
            LogUtil.d("Asset ", event:getAssetId() .. " " .. event:getMessage())
            -- nk.TopTipManager:showTopTip("有文件下载失败，退出更新")
            if (self.m_assetManager) then
                self.m_assetManager:cancel()
            end
            self:failedLogic(eventCode)
        end
    end
    if (not self.m_secondUpdate) then
        self.m_secondUpdate = scheduler.scheduleGlobal(function ()
            -- LogUtil.d("onProgress curDownloadSize, lastDownloadSize, isSkipCheckSpeed = ", curDownloadSize, lastDownloadSize, isSkipCheckSpeed)
            -- 设计一个超时定时器
            if (totalSize > 0) then
                if isSkipCheckSpeed then return end
                local maxTime = totalSize / 5
                if (maxTime < 30) then
                    maxTime = 30
                elseif (maxTime > 300) then
                    maxTime = 300
                end
                local diffTime = poker.getTime() - beginTime
                -- LogUtil.d("UDController diffTime = ", diffTime)
                if (diffTime >= maxTime) then
                    -- nk.TopTipManager:showTopTip("超时了，退出更新！")
                    if (self.m_assetManager) then
                        self.m_assetManager:cancel()
                    end
                    self:failedLogic("timeout")
                end
            end
            isSkipCheckSpeed = false
        end, 5)
    end
    if (self.m_assetManager) then
        local listener = cc.EventListenerAssetsManagerEx:create(self.m_assetManager, onUpdateEvent)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
        self.m_assetManager:update()
        self.m_updateListener = listener
    end
end

function M:showTest( ... )
    if (not self.m_testBtn and self.m_delegate) then
        self.m_testBtn = ccui.Button:create("test/test_btn.png"):addTo(self.m_delegate)
        self.m_testBtn:pos(display.cx, display.cy)
        self.m_testBtn:addTouchEventListener(function(sender, eventType)
            if 2 == eventType then
                if (self.m_assetManager) then
                    self.m_assetManager:cancel()
                end
                self:failedLogic("timeout")

            end
        end)
    end
end

-- 格式化输出速度
-- @param speed 单位(kb)
function M:formatSpeed(speed)
    speed          = speed or 0
    local speedStr = ""
    local gb       = 1024 * 1024
    local mb       = 1024
    local kb       = 1
    if speed >= gb then
        speedStr = string.format("%.2fG", speed / gb)
    elseif speed >= mb then
        speedStr = string.format("%.2fM", speed / mb)
    elseif speed >= kb then
        speedStr = string.format("%.2fK", speed / kb)
    else
        speedStr = "<1K"
    end
    return speedStr
end

-- 更新下载进度
-- @param index 1 version 文件 2 manifest 文件 3 热更新
function M:updateProgress(index, progress, stateStr)
    -- LogUtil.d(TAG, "updateProgress index, progress = ", tostring(index), tostring(progress))
    local updateStr = ""
    if (index and index == 1) then
        updateStr = self.m_configStr
    else
        updateStr = self.m_updateStr
    end
    if (self.m_delegate) then
        if (self.m_delegate.onUpdateProgress) then
            self.m_delegate:onUpdateProgress(progress or 0)
        end
        if (self.m_delegate.onUpdateTxtProgress) then
            self.m_delegate:onUpdateTxtProgress(updateStr, true)
        end
    end
end

-- 更新下载速度
function M:updateSpeed(progressStr, speedStr)
    if (self.m_delegate and self.m_delegate.onUpdateProgressState) then
        self.m_delegate:onUpdateProgressState(progressStr, speedStr)
    end
end

function M:update(gameId)
    nk.Const.isHotUD    = true
    -- 检查本地的配置文件
    if not network.isInternetConnectionAvailable()
        or not self.m_assetManager:getLocalManifest():isLoaded() then
        LogUtil.d("net failed, step skipped.")
        self:normalExit()
    else
        -- if (self.m_assetManager:getLocalManifest() and self.m_assetManager:getLocalManifest():isLoaded()) then
        --     LogUtil.d(TAG, "update() version file url = ", self.m_assetManager:getLocalManifest():getVersionFileUrl())
        --     nk.TopTipManager:showTopTip(self.m_assetManager:getLocalManifest():getVersionFileUrl())
        -- end
        self.m_requestTimeout = 1
        self:needUpdate()
        -- 添加一个超时请求，如果遇到解析 host 失败的情况，有一个超时直接结束
        if (not self.m_requestVerScheduler) then
            self.m_requestVerScheduler = scheduler.scheduleGlobal(function ( ... )
                -- 超时了
                if (self.m_requestTimeout == 1) then
                    self:failedLogic(99)
                end
                self.m_requestTimeout = 0
                if (self.m_requestVerScheduler) then
                    scheduler.unscheduleGlobal(self.m_requestVerScheduler)
                end
            end, 10)
        end
    end
end

-- 用于在退出时做一些操作
-- 移除一些东西
function M:removeSomething( ... )
    if (self.m_assetManager and not tolua.isnull(self.m_assetManager)) then
        -- just close the release
        -- self.m_assetManager:release()
    end
    if (self.m_secondUpdate) then
        scheduler.unscheduleGlobal(self.m_secondUpdate)
        self.m_secondUpdate = nil
    end
    if (self.m_requestVerScheduler) then
        scheduler.unscheduleGlobal(self.m_requestVerScheduler)
        self.m_requestVerScheduler = nil
    end
end

function M:enterGame()
    local eventDispatcher = cc.Director:getInstance():getEventDispatcher()
    if self.m_updateListener then
        eventDispatcher:removeEventListener(self.m_updateListener)
        self.m_updateListener = nil
    end
end

-- 记录文件个数
function M:recordFileNumber(gameId)
    local path = ""
    local fileList, count
    local updateConfig = json.decode(LocalFileUtils:getStringFromFile(UDConfig.UD_CONFIG_FILE, "{}"))
    path = UDConfig.udConfig
    gameId = "0"
    fileList, count = LocalFileUtils:listFiles(path)
    updateConfig[tostring(gameId)] = count
    local luaFileList = {}
    if (not table.isEmpty(fileList)) then
        for i = 1, #fileList do
            if (fileList[i] and string.find(fileList[i], "%.lua")) then
                luaFileList[#luaFileList + 1] = fileList[i]
            end
        end
    end
    updateConfig[tostring(gameId) .. "_lua"] = luaFileList
    nk.UDHelper:reloadLuaFile(luaFileList)
    LocalFileUtils:writeStringToFile(UDConfig.UD_CONFIG_FILE, json.encode(updateConfig))
end

-- 无更新正常退出
function M:normalExit()
    if (self.m_isExited) then return end
    self.m_isExited = true
    LogUtil.d("正常更新退出(无需更新)")
    self:removeSomething()
    self:enterGame()
    if self.m_delegate and self.m_delegate.onNormalExit then
        self.m_delegate:onNormalExit()
    end
end

-- 成功调用
function M:normalSuccess()
    -- 大厅更新才保存 version 文件
    if (not self.m_curGameId) then
        if (not cc.FileUtils:getInstance():isFileExist(UDConfig.UD_CONFIG_FILE)) then
            LocalFileUtils:writeStringToFile(UDConfig.UD_CONFIG_FILE, "{}")
        end
        cc.FileUtils:getInstance():addSearchPath(UDConfig.udConfig .. "/res/",true)
        cc.FileUtils:getInstance():addSearchPath(UDConfig.udConfig .. "/src/",true)
    end
    -- 更新带小版本号的版本
    local lastVerStr = nk.Const.GAME_VERSION_UPDATE
    if (self.m_assetManager and not tolua.isnull(self.m_assetManager)
        and self.m_assetManager:getLocalManifest() and self.m_assetManager:getLocalManifest():isLoaded()) then
        local verStr = self.m_assetManager:getLocalManifest():getVersion()
        if (verStr and string.len(verStr) > 0) then
            nk.Const.GAME_VERSION_UPDATE = verStr
        end
    end
    self:removeSomething()
    LogUtil.d(TAG, "normalSuccess 成功加载")
    self:recordFileNumber(self.m_curGameId)
    if (self.m_delegate and self.m_delegate.onSuccess) then
        self.m_delegate:onSuccess(lastVerStr)
    end
end

-- 失败调用
function M:failedLogic(errorCode)
    -- todo show the tips for failedLogic
    if self.m_isCalled then return end
    self.m_isCalled = true

    self:removeSomething()
    LogUtil.d("failed::::本次热更新没有成功哦！！删除version")
    if (self.m_delegate and self.m_delegate.onFailure) then
        self.m_delegate:onFailure(errorCode)
    end
end

function M:cancel( ... )
    if (self.m_assetManager) then
        self.m_assetManager:cancel()
    end
end

return M
