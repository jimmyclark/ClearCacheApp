-- UDView.lua
-- Author: Amnon
-- Date: 2019-07-26 11:36:58
-- Desc: re geng 新节点视图
-- Usage:
--

local TAG       = "UDView"
local UDConfig  = require("ud.UDConfig")

local M = class(TAG, function()
    return display.newNode()
end)

-- 暂时不需要传递什么参数来初始化
-- @param udType int 更新类型（大厅，游戏）
-- @param gameId int 游戏ID
-- @param isSingleThread boolean 是否为单线程，解决在失败之后退出导致的闪退，用于不能强制结束或者持有 UI 的地方
-- @param config table 单独的配置表 已废弃，等有需求再启用
function M:ctor(udType, gameId, isSingleThread, config)
    self.m_config = nk.PlatformFactory:getCurPlatform():getUdViewConfig()
    if (self.m_config.spriteFrame) then
        display.addSpriteFrames(self.m_config.spriteFrame.plist, self.m_config.spriteFrame.png)
    end
    if (table.isEmpty(self.m_config)) then return end

    self.m_configStr = poker.LangUtil:getText("HOTUD","READY_UPDATE")       -- 正在检查更新, 请耐心等待...

    self.m_curUdType = UDConfig.UDTYPE.HALL
    self.m_curGameId = gameId or 0

    self:initView(self.m_config)

    self.m_udController = require("ud.UDController").new(self.m_curUdType, gameId, isSingleThread)
    self.m_udController:setDelegate(self)
end

function M:initView()
    local nodeConfig  = self.m_config.progress
    self.m_viewProgress = nk.ui.LoadingProgress.new(nodeConfig.bg, nodeConfig.front, nodeConfig.frontSize)
        :pos(nodeConfig.x, nodeConfig.y)
        :size(nodeConfig.size.width, nodeConfig.size.height)
        :fillPosition(nodeConfig.fillPosX, nodeConfig.fillPosY)
        :setPercent(0)
        :addTo(self)
    nodeConfig = self.m_config.shadowBg
    if (not table.isEmpty(nodeConfig)) then
        self.m_labelBg = display.newImage({
            file   = nodeConfig.file,
            pos    = nodeConfig.pos,
            parent = self,
        })
    end
    nodeConfig        = self.m_config.tipsLabel
    -- 一开始显示（无进度条）的文本位置
    self.m_defaultPos = nodeConfig.pos
    -- 进度条出来的文本位置
    self.m_offsetPos  = nodeConfig.offsetPos
    self.m_txtProgressTips = cc.ui.UILabel.new({
            text        = self.m_configStr,
            color       =  nodeConfig.color,
            shadowColor = nodeConfig.shadowColor,
            size        = nodeConfig.fontSize
        })
        :align(nodeConfig.align, nodeConfig.pos.x, nodeConfig.pos.y)
        :addTo(self)
end

-- 更新当前进度和当前状态
function M:onUpdateProgress(progress)
    if (self.m_viewProgress) then
        self.m_viewProgress:setPercent(progress)
    end
end

-- 更新进度状态
function M:onUpdateProgressState(stateStr, speedStr)

end

function M:onUpdateTxtProgress(text, isChangeUpdate)
    if isChangeUpdate then
        self.m_str = text
        if (self.m_txtProgressTips) then
            self.m_txtProgressTips:pos(self.m_offsetPos)
        end
        if (self.m_labelBg) then
            self.m_labelBg:pos(self.m_offsetPos)
        end
        if (self.m_viewProgress) then
            self.m_viewProgress:setVisible(true)
        end
    end
    if not self.m_configNum then
        self.m_configNum = 0
    end
    if (self.m_txtProgressTips and text and string.len(text) > 0) then
        self.m_txtProgressTips:setString(string.sub(text, 1, self.m_configNum % 3 - 3))
    end
end

-- 更新成功
function M:onSuccess(versionStr)
    versionStr = versionStr or nk.Const.GAME_VERSION_UPDATE
    self.m_updateLog = {}
    local version  = string.gsub(versionStr, "%.", "_")
    self.m_updateLog = {
        kUmengUDSuccess,
        version,
        "_GameId_",
        self.m_curGameId or 0,
    }
    if (self and self.exitUpdate) then
        self:exitUpdate(1)
    end
end

-- 无更新，正常退出即可
function M:onNormalExit()
    if (self and self.exitUpdate) then
        self:exitUpdate(2)
    end
end

-- 更新失败
function M:onFailure(errorCode)
    errorCode = errorCode or 0
    local version  = string.gsub(nk.Const.GAME_VERSION_UPDATE, "%.", "_")
    local errorLogMap = {
        kUmengUDFailed,
        version,
        "_GameId_",
        self.m_curGameId or 0,
        "_errorCode",
        errorCode or 0
    }
    local msg, _   = table.concat(errorLogMap, "")
    LogUtil.d(TAG, "onFailure msg = ", msg)
    -- -1 如果是 Version 文件下载失败的话，那么不用上报
    if (errorCode ~= -1) then
        nk.Umeng:reportMap(kUmengUDKey, kUmengUDState, msg)
    end
    if (self and self.exitUpdate) then
        self:exitUpdate(3)
    end
end

-- 退出更新
function M:exitUpdate(updateStatus)
    if (self.m_updateLog and not table.isEmpty(self.m_updateLog)) then
        local msg, _   = table.concat(self.m_updateLog, "")
        LogUtil.d(TAG, "exitUpdate self.m_updateLog = ", msg)
        nk.Umeng:reportMap(kUmengUDKey, kUmengUDState, msg)
        self.m_updateLog = {}
    end
    self:cleanUpdateUI()
    self:hide()
    if self.m_callBack then
        self.m_callBack(updateStatus, self.m_curGameId)
    end
end

-- 清除 UI
function M:cleanUpdateUI()
    self:stopAllActions()

    if (self.m_viewProgress) then
        self.m_viewProgress:hide()
    end
    if (self.m_txtProgressTips) then
        self.m_txtProgressTips:hide()
    end
    if (self.m_labelBg) then
        self.m_labelBg:hide()
    end
end

-- 开始更新
function M:startUpdate(callback, gameId)
    self.m_callBack = callback
    self.m_udController:update(gameId)
    self.m_curGameId = gameId
    self.m_str = self.m_configStr
    self:schedule(function ( ... )
        -- LogUtil.d(TAG, "self.m_updateStrSchedule schedule")
        if (not self or tolua.isnull(self)) then
            return
        end
        if not self.m_configNum then
            self.m_configNum = 0
        end
        if (self.onUpdateTxtProgress) then
            self:onUpdateTxtProgress(self.m_str)
        end
        self.m_configNum = self.m_configNum + 1
    end, 1)
    if (not gameId) then
        if self.m_txtProgressTips then
            self.m_txtProgressTips:pos(self.m_defaultPos)
        end
        if (self.m_labelBg) then
            self.m_labelBg:pos(self.m_defaultPos)
        end
        if self.m_viewProgress then
            self.m_viewProgress:setVisible(false)
        end
    end
end

function M:cancel()
    if (self.m_udController) then
        self.m_udController:cancel()
    end
end

return M
