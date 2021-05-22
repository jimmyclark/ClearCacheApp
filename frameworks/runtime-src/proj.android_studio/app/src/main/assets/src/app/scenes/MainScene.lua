require("app.util.bit")

local cjson = require "cjson"
json = cjson.new()

json.encode_sparse_array(true,1)

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

MainScene.TIDE_DATA = "TIDE_DATA"

MainScene.VAR_DISTANT = 1024 * 1024 * 5  -- 每次需要判断与上一次保存的值的差值

MainScene.VAR_PERCENT = {
    ["notmove"]  = {2, 7},    -- 无法移动文件占比
    ["sequence"] = {2, 5},    -- 连续文件的占比
}

-- 减少的量
MainScene.VAR_TIDE_PERCENT = {
    [1] = {
        ["confuse"] = {5, 22},
        ["sequence"] = {0.2, 0.5},
    },

    [2] = {
        ["confuse"] = {2, 4},
        ["sequence"] = {0.1, 0.25},
    },

    [3] = {
        ["confuse"] = {0.5, 3},
        ["sequence"] = {0.02, 0.05},
    },

    [4] = {
        ["confuse"] = {0, 0.5},
        ["sequence"] = {0, 0.01},
    },
}

function MainScene:ctor()
    -- 添加键盘事件
    nk.KeypadManager:addToScene(self, 0)

    self.m_statusTitleStr       = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_TOP_STATUS")               -- 磁盘状态
    self.m_usePreviousStr       = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_USE_PREVIOUS")             -- 整理前磁盘使用量
    self.m_useAfterStr          = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_USE_AFTER")                -- 整理后磁盘使用量

    self.m_deviceStr            = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_DEVICE_NAME")              -- 设备名称: %s
    self.m_netStr               = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_NET_STATUS")               -- 网络状态: %s
    self.m_totalPromptStr       = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_TOTAL_SIZE")               -- 磁盘大小: %s
    self.m_totalAvailableStr    = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_AVALIABLE_SIZE")           -- 可用空间: %s

    self.m_playingExitStr       = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_PLAYING_EXIT")             -- 正在整理中，中途退出会停止整理，确定退出？
    self.m_playingExitCertain   = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_PLAYING_EXIT_CERTAIN")     -- 确定
    self.m_playingExitCancel    = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_PLAYING_EXIT_CANCEL")      -- 取消

    self.m_alreadyFinStr        = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_ALREADY_FIN")              -- 磁盘已整理完成
    self.m_tidyStr              = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDY_TEXT")                     -- 整理
    self.m_tidingStr            = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDING_TEXT")                   -- 整理中
    self.m_tidedStr             = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDED_TEXT")                    -- 已完成

    --init
    self:initData()

    self:addSpriteFrames()
    self:initView()
    self:initViewData()
end

function MainScene:getMainExitParams()
    self:stopAllActions()
    self:updateBottomProgress(self.m_nowProgressValue)

    return {
        content = self.m_playingExitStr, 
        certain = self.m_playingExitCertain,
        cancel  = self.m_playingExitCancel,
        cancelFunc = function()
            self.m_backFlag = false

            local time = math.random(0.2, 2)
            self:refreshProgress(time)
        end
    }
end

function MainScene:run()
end

function MainScene:initView()
    self.m_bg = display.newBackgroud({
                    file   = nk.Res.main_bg,
                    pos    = cc.p(display.cx, display.cy),
                    parent = self
                })

    self.m_title = display.newSprite(nk.Res.main_bg_title)
                    :pos(display.cx, display.top - 75)
                    :addTo(self)

    -- top
    self.m_topStatusBg = display.newScale9Sprite(nk.Res.main_bg_top_bg, display.cx, display.top - 318, cc.size(664, 310))
    self.m_topStatusBg:addTo(self)

    self.m_topStatusDeviceName = cc.ui.UILabel.new({
                                    UILabelType = 2,
                                    text = string.format(self.m_deviceStr, nk.Const.model),
                                    size = 26,
                                    color = cc.c3b(177,165,177),
                                    align = cc.ui.TEXT_ALIGN_LEFT,
                                })
                                :pos(275, 220)
                                :addTo(self.m_topStatusBg)

    self.m_topStatusNetName = cc.ui.UILabel.new({
                                    UILabelType = 2,
                                    text = string.format(self.m_netStr, nk.Const.net),
                                    size = 26,
                                    color = cc.c3b(177,165,177),
                                    align = cc.ui.TEXT_ALIGN_LEFT,
                                })
                                :pos(275, 155)
                                :addTo(self.m_topStatusBg)

    self.m_topStatusTotalSize = cc.ui.UILabel.new({
                                    UILabelType = 2,
                                    text = string.format(self.m_totalPromptStr, self:formatDeviceSize(self.m_totalDeviceSize)),
                                    size = 26,
                                    color = cc.c3b(177,165,177),
                                    align = cc.ui.TEXT_ALIGN_LEFT,
                                })
                                :pos(275, 100)
                                :addTo(self.m_topStatusBg)

    self.m_topStatusAvaliableSize = cc.ui.UILabel.new({
                                        UILabelType = 2,
                                        text = string.format(self.m_totalAvailableStr, self:formatDeviceSize(self.m_avaliableDeviceSize)),
                                        size = 26,
                                        color = cc.c3b(177,165,177),
                                        align = cc.ui.TEXT_ALIGN_LEFT,
                                    })
                                    :pos(275, 45)
                                    :addTo(self.m_topStatusBg)

    self.m_topStatusDi = display.newSprite(nk.Res.main_bg_topStatus)
                            :pos(self.m_topStatusBg:getContentSize().width/2, self.m_topStatusBg:getContentSize().height - 32)
                            :addTo(self.m_topStatusBg)

    self.m_topStatusLabel = cc.ui.UILabel.new({
                                UILabelType = 2,
                                text = self.m_statusTitleStr,
                                size = 28,
                                color = cc.c3b(255, 255, 255),
                                align = cc.ui.TEXT_ALIGN_CENTER,
                            })
                            :addTo(self.m_topStatusDi)
    self.m_topStatusLabel:pos(self.m_topStatusDi:getContentSize().width/2 - self.m_topStatusLabel:getContentSize().width/2, self.m_topStatusDi:getContentSize().height/2)

    self.m_topDiskSprite = display.newSprite(nk.Res.main_bg_topDisk)
                            :addTo(self.m_topStatusBg)
    self.m_topDiskSprite:pos(123, self.m_topStatusBg:getContentSize().height/2 - 40)

    self.m_topDiskSplit = display.newScale9Sprite(nk.Res.main_bg_split,
        display.cx, display.top - 318 - self.m_topStatusBg:getContentSize().height + 116, cc.size(684, 2))
    self.m_topDiskSplit:addTo(self)

    -- 中间区域
    self.m_contentNode = display.newNode()
                            :pos(display.cx, display.cy)
                            :addTo(self)

    self.m_previousTitle = cc.ui.UILabel.new({
                                UILabelType = 2,
                                text = self.m_usePreviousStr,
                                size = 26,
                                color = cc.c3b(255, 255, 255),
                                align = cc.ui.TEXT_ALIGN_CENTER,
                            })
                            :addTo(self.m_contentNode)

    self.m_previousTitle:pos(-336, 78)

    -- 使用前进度条
    self.m_previousProgress = nk.ui.ColorfulProgress.new({
                                bgs = {
                                    nk.Res.main_bg_progress_bg,
                                    nk.Res.main_bg_progressBlue,
                                    nk.Res.main_bg_progressYellow,
                                    nk.Res.main_bg_progressGray,
                                },

                                width = 674,
                                height = 43,
                                minWidth = 20,
                            })
                            :pos(0, 33)
                            :addTo(self.m_contentNode)
    self:updatePreviousProgress({0, 0, 0})

    self.m_afterTitle = cc.ui.UILabel.new({
                                UILabelType = 2,
                                text = self.m_useAfterStr,
                                size = 26,
                                color = cc.c3b(255, 255, 255),
                                align = cc.ui.TEXT_ALIGN_CENTER,
                            })
                            :addTo(self.m_contentNode)

    self.m_afterTitle:pos(-336, 78)

    -- 使用后进度条
    self.m_afterProgress = nk.ui.ColorfulProgress.new({
                                bgs = {
                                    nk.Res.main_bg_progress_bg,
                                    nk.Res.main_bg_progressBlue,
                                    nk.Res.main_bg_progressYellow,
                                    nk.Res.main_bg_progressGray,
                                },

                                width = 674,
                                height = 43,
                                minWidth = 20,
                            })
                            :pos(0, 33)
                            :addTo(self.m_contentNode)
    self:updateAfterProgress({0, 0, 0})

    self:hideAfterProgressView()

    self.m_promptStr = display.newSprite(nk.Res.main_bg_prompt)
    self.m_promptStr:pos(0, -44)
    self.m_promptStr:addTo(self.m_contentNode)

    self.m_contentSplit = display.newScale9Sprite(nk.Res.main_bg_split,
        0, -215, cc.size(684, 2))
    self.m_contentSplit:addTo(self.m_contentNode)

    self.m_bottomNode = display.newNode()
                        :pos(display.cx, display.bottom + 205)
                        :addTo(self)

    self.m_bottomProgress = nk.ui.CustomProgress.new({
                                bg     = nk.Res.main_bg_progressDi,
                                foreBg = nk.Res.main_bg_progress,
                                text   = {
                                    fontSize = 24,
                                    fontColor = cc.c3b(255,255,255),
                                    pos = cc.p(0, -1),
                                },
                                width = 674,
                                height = 30,
                                minWidth = 36,
                            })
                            :pos(0, 160)
                            :addTo(self.m_bottomNode, 2)
    self:updateBottomProgress(0)

    self.m_promptSuccessStr = cc.ui.UILabel.new({
                                UILabelType = 2,
                                text = self.m_alreadyFinStr,
                                size = 26,
                                color = cc.c3b(186,113,121),
                                align = cc.ui.TEXT_ALIGN_CENTER,
                            })
                            :addTo(self.m_bottomNode)
    self.m_promptSuccessStr:pos(-self.m_promptSuccessStr:getContentSize().width/2, 115)
    self:hidePromptSuccess()

    self.m_btn      = nk.ui.Button.new({normal = nk.Res.main_bg_normal_btn,
                        disabled = nk.Res.main_bg_gray_btn})
    self.m_btn:onButtonClicked(function()
        self:onBtnClicked()
    end)
    self.m_btn:addTo(self.m_bottomNode)

    self.m_btnText  = cc.ui.UILabel.new({
                        UILabelType = 2,
                        text = "",
                        size = 46,
                        color = cc.c3b(255, 255, 255),
                        align = cc.ui.TEXT_ALIGN_CENTER,
                    })
                    :addTo(self.m_btn)

    self:showTidyBtnStatus()
end

function MainScene:initViewData()
    -- 计算出几个值
    local confusePercent = 0
    local sequencePercent = 0
    local avaliablePercent = 0
    local cannotPercent = 0
    
    if nk.Const.deviceTotalSize > 0 then 
        cannotPercent    = self.m_cannotMoveDeviceSize / nk.Const.deviceTotalSize * 100
        sequencePercent  = self.m_sequenceDeviceSize / nk.Const.deviceTotalSize * 100
        avaliablePercent = tonumber(self.m_avaliableDeviceSize) / nk.Const.deviceTotalSize * 100

        confusePercent    = 100 - cannotPercent - sequencePercent - avaliablePercent
        self.m_confusedDeviceSize = (confusePercent / 100) * nk.Const.deviceTotalSize
    end

    self:updatePreviousProgress({confusePercent, sequencePercent, cannotPercent})
end

function MainScene:showPromptSuccess()
    if self.m_promptSuccessStr then
        self.m_promptSuccessStr:show()
    end
end

function MainScene:hidePromptSuccess()
    if self.m_promptSuccessStr then
        self.m_promptSuccessStr:hide()
    end
end

function MainScene:showTidedBtnStatus()
    if self.m_btn then
        self.m_btn:setButtonEnabled(false)
    end

    self:updateBtnText(self.m_tidedStr)
end

function MainScene:showTidyingBtnStatus()
    if self.m_btn then
        self.m_btn:setButtonEnabled(false)
    end

    self:updateBtnText(self.m_tidingStr)
end

function MainScene:showTidyBtnStatus()
    if self.m_btn then
        self.m_btn:setButtonEnabled(true)
    end

    self:updateBtnText(self.m_tidyStr)
end

function MainScene:updateBtnText(text)
    if self.m_btnText then
        self.m_btnText:setString(text)
        self.m_btnText:pos(-self.m_btnText:getContentSize().width/2, 5)
    end
end

function MainScene:updateBottomProgress(value)
    if self.m_bottomProgress then
        self.m_bottomProgress:setProgressValue(value)
    end
end

function MainScene:updatePreviousProgress(progrssValue)
    if self.m_previousProgress then
        self.m_previousProgress:setProgressValue(progrssValue)
    end
end

function MainScene:updateAfterProgress(progrssValue)
    if self.m_afterProgress then
        self.m_afterProgress:setProgressValue(progrssValue)
    end
end

function MainScene:hideAfterProgressView()
    if self.m_afterProgress then
        self.m_afterProgress:hide()
    end

    if self.m_afterTitle then
        self.m_afterTitle:hide()
    end
end

function MainScene:showAfterProgressView()
    if self.m_afterProgress then
        self.m_afterProgress:show()
    end

    if self.m_afterTitle then
        self.m_afterTitle:show()
    end
end

function MainScene:isPlaying()
    return self.m_isPlaying
end

function MainScene:onBtnClicked()
    self.m_isPlaying = true

    local confuseDeviceSize          = self.m_confusedDeviceSize
    self.m_afterCanNotMoveDeviceSize = self.m_cannotMoveDeviceSize

    -- 整理的次数超过了最大的次数
    if self.m_hasTideCount + 1 > #MainScene.VAR_TIDE_PERCENT then 
        -- 使用当前的值
        self.m_afterConfuseDeviceSize    = confuseDeviceSize
        self.m_afterSequenceDeviceSize   = self.m_sequenceDeviceSize

    -- 第self.m_hasTideCount + 1整理
    else 
        local index           = self.m_hasTideCount + 1
        local confusePercent  = 100 - math.random(MainScene.VAR_TIDE_PERCENT[index]["confuse"][1], MainScene.VAR_TIDE_PERCENT[index]["confuse"][2])
        local sequencePercent = 100 - math.random(MainScene.VAR_TIDE_PERCENT[index]["sequence"][1], MainScene.VAR_TIDE_PERCENT[index]["sequence"][2])

        self.m_afterConfuseDeviceSize    = confuseDeviceSize * (confusePercent / 100)
        self.m_afterSequenceDeviceSize   = self.m_sequenceDeviceSize * (sequencePercent  / 100)
    end

    self.m_afterAvailableDeivceSize = nk.Const.deviceTotalSize - self.m_afterConfuseDeviceSize - self.m_afterSequenceDeviceSize - self.m_afterCanNotMoveDeviceSize

    -- 计算出几个值
    local confusePercent    = 0
    local sequencePercent   = 0
    local avaliablePercent  = 0
    local cannotPercent     = 0
    
    if nk.Const.deviceTotalSize > 0 then 
        cannotPercent     = self.m_afterCanNotMoveDeviceSize / nk.Const.deviceTotalSize * 100
        sequencePercent   = self.m_afterSequenceDeviceSize / nk.Const.deviceTotalSize * 100
        confusePercent    = self.m_afterConfuseDeviceSize / nk.Const.deviceTotalSize * 100
        avaliablePercent  = 100 - cannotPercent - sequencePercent - confusePercent
    end

    self:updateAfterProgress({confusePercent, sequencePercent, cannotPercent})

    -- 计算当前零碎文件的空间 * 每个MB 为 0.5 - 1秒
    self.m_needTime = (confuseDeviceSize / 1024 / 1024 / 512) * math.random(0.5, 2)

    if self.m_hasTideCount + 1 > #MainScene.VAR_TIDE_PERCENT then 
        self.m_needTime = math.random(1, 2)
    end

    self:showTidyingBtnStatus()
    self:runProgress(self.m_needTime)
end

function MainScene:runAfterProgressView()
    local TIME_SECOND = 0.5

    self:showAfterProgressView()

    if self.m_afterTitle then
        local moveToProgressTitleAction = cc.MoveTo:create(TIME_SECOND, cc.p(-336, -40))
        self.m_afterTitle:runAction(cc.EaseElasticOut:create(moveToProgressTitleAction))
    end

    if self.m_afterProgress then
        local moveToProgressAction = cc.MoveTo:create(TIME_SECOND, cc.p(0, -88))
        self.m_afterProgress:runAction(cc.EaseElasticOut:create(moveToProgressAction))
    end

    if self.m_promptStr then
        local moveToAction = cc.MoveTo:create(TIME_SECOND, cc.p(0, -165))
        self.m_promptStr:runAction(cc.EaseElasticOut:create(moveToAction))
    end
end

function MainScene:onEnterTransitionFinish()
    -- 关闭闪屏页
    if nk.Const.isNeedFirstClose then
        nk.Const.isNeedFirstClose = false
        if DEBUG > 0 and nk.GameState:getBool("testStartDialog") then
            nk.GameState:putBool("testStartDialog", false)

            if self.m_loginView then
                self.m_loginView:onEnterTransitionFinish()
            end

            return
        end

        if device.platform == "android" or device.platform == "ios" then
            if not nk.Const.isErrorInStart then
                nk.Native:closeStartScreen()
            end
        end
    end
end

function MainScene:addSpriteFrames()
    display.addSpriteFrames(nk.Res.main_bg_frame.plist, nk.Res.main_bg_frame.png)
    display.addSpriteFrames(nk.Res.main_bg_frame_lang.plist, nk.Res.main_bg_frame_lang.png)
end

function MainScene:initData()
    -- 读取缓存，判断上一次是否整理过
    nk.GameFile:readToCache("ClearCache")
    local tideData  = nk.GameFile:getString(MainScene.TIDE_DATA)

    -- 上一次是否整理过参数
    local lastIsTideFlag = false
    local tideDataArray


    if tideData == nil or tideData == "" then
        lastIsTideFlag = false

    else
        tideDataArray = json.decode(tideData)

        if tideDataArray == nil or table.isEmpty(tideDataArray) then
            lastIsTideFlag = false

        else
            -- 如果上一次整理过，则取出上一次的原始磁盘可用大小
            local lastDeviceAvaliableSize = tideDataArray.originAvaliableSize

            -- 比较原始磁盘可用大小和当前的可用大小的差值是否在5M之内
            if math.abs(lastDeviceAvaliableSize - nk.Const.deviceAvalibleSize) <= MainScene.VAR_DISTANT then 
                print("//原始磁盘大小 - 当前磁盘大小 <= 5M 则使用上一次整理后的参数")
                lastIsTideFlag = true 

                self.m_lastDeviceAvaliableSize = lastDeviceAvaliableSize

            else
                lastIsTideFlag = false 
            end
        end
    end

    -- 上一次是否整理过
    self.m_lastIsTideFlag = lastIsTideFlag

    -- 如果上一次整理过
    if self.m_lastIsTideFlag then 
        -- 从整理数据中获取参数
        self.m_avaliableDeviceSize  = tideDataArray.avaliableSize            -- 上一次整理后的可用空间
        self.m_confusedDeviceSize   = tideDataArray.confuseSize              -- 上一次整理后的零碎空间
        self.m_sequenceDeviceSize   = tideDataArray.sequenceSize             -- 上一次整理后的连续空间
        self.m_cannotMoveDeviceSize = tideDataArray.cannotMoveSize           -- 上一次整理后的无法移动的空间
        self.m_hasTideCount         = tideDataArray.tideCount                -- 一共整理的次数

    else
        self.m_avaliableDeviceSize  = nk.Const.deviceAvalibleSize
        self.m_cannotMoveDeviceSize = nk.Const.deviceTotalSize * (math.random(MainScene.VAR_PERCENT["notmove"][1], MainScene.VAR_PERCENT["notmove"][2]) / 100)
        self.m_sequenceDeviceSize   = nk.Const.deviceTotalSize * (math.random(MainScene.VAR_PERCENT["sequence"][1], MainScene.VAR_PERCENT["sequence"][2]) / 100)
        self.m_hasTideCount         = 0
    end

    self.m_totalDeviceSize = nk.Const.deviceTotalSize
end

function MainScene:runProgress(needTime)
    self.m_curProgressNeedTime = needTime / 100     -- 每进1的进度需要的耗时

    self.m_nowProgressValue = 0

    local time = math.random(0.2, 2)
    self:performWithDelay(function()
        self:refreshProgress(time)
    end, time)
end

function MainScene:refreshProgress(time)
    self.m_nowProgressValue = self.m_nowProgressValue + time

    self:updateBottomProgress(self.m_nowProgressValue)

    if self.m_nowProgressValue > 100 then 
        self:runAfterProgressView()
        self:showPromptSuccess()
        self:showTidedBtnStatus()

        self.m_isPlaying = false
        self:saveCurStatus()
        return 
    end

    if self.m_backFlag then 
        -- 物理键点击
        print("物理键点击")
        return 
    end

    local time = math.random(0.2, 2)
    self:performWithDelay(function()
        self:refreshProgress(time)
    end, time)
end

function MainScene:saveCurStatus()
    -- 保存参数
    local needSaveParams = {}
    needSaveParams.avaliableSize    = self.m_afterAvailableDeivceSize
    needSaveParams.confuseSize      = self.m_afterConfuseDeviceSize
    needSaveParams.sequenceSize     = self.m_afterSequenceDeviceSize 
    needSaveParams.cannotMoveSize   = self.m_afterCanNotMoveDeviceSize
    needSaveParams.tideCount        = self.m_hasTideCount + 1

    if self.m_lastIsTideFlag then 
        needSaveParams.originAvaliableSize = self.m_lastDeviceAvaliableSize

    else
        needSaveParams.originAvaliableSize = self.m_avaliableDeviceSize
    end

    nk.GameFile:putString(MainScene.TIDE_DATA, json.encode(needSaveParams))
    nk.GameFile:commit()
end

function MainScene:formatDeviceSize(size)
    if not size then
        return "0 B"
    end

    size = tonumber(size)

    -- B
    if size < 1024 then
        return size .. " B"

    -- KB
    elseif size < 1024 * 1024 then
        return math.round(size / 1024, 2) .. " KB"

    -- MB
    elseif size < 1024 * 1024 * 1024 then
        return math.round(size / 1024 / 1024, 2) .. " MB"

    -- GB
    elseif size < 1024 * 1024 * 1024 * 1024 then
        return math.round(size / 1024 / 1024 / 1024, 2) .. " GB"

    -- TB
    else
        return math.round(size / 1024 / 1024 / 1024 / 1024, 2) .. " TB"
    end
end

function MainScene:onExit()
end

function MainScene:onCleanup()
end

function MainScene:onEnter()
end

function MainScene:setBackingFlag(backFlag)
    self.m_backFlag = backFlag
end

function MainScene:isBackingFlag()
    return self.m_backFlag
end

return MainScene