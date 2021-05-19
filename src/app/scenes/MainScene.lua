require("app.util.bit")

local cjson = require "cjson"
json = cjson.new()

json.encode_sparse_array(true,1)

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- 添加键盘事件
    -- nk.KeypadManager:addToScene(self, nk.Const.BACK_INDEX_LOGIN)
    -- nk.Const.BG_SCENE = nk.Const.BACK_INDEX_LOGIN

    self.m_statusTitleStr = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_TOP_STATUS")        -- 磁盘状态
    self.m_usePreviousStr = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_USE_PREVIOUS")      -- 整理前磁盘使用量
    self.m_useAfterStr    = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_USE_AFTER")         -- 整理后磁盘使用量

    self.m_alreadyFinStr  = poker.LangUtil:getText("MAIN_VIEW", "MAIN_VIEW_ALREADY_FIN")       -- 磁盘已整理完成
    self.m_tidyStr        = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDY_TEXT")              -- 整理
    self.m_tidingStr      = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDING_TEXT")            -- 整理中
    self.m_tidedStr       = poker.LangUtil:getText("MAIN_VIEW", "MAIN_TIDED_TEXT")             -- 已完成

    --init
    self:initData()

    self:addSpriteFrames()
    self:initView()
end

function MainScene:run()
end

function MainScene:initView()
    self.m_bg = display.newBackgroud({
                    file   = nk.Res.main_bg,
                    pos    = cc.p(display.cx, display.cy),
                    parent = self
                })

    -- 测试背景
    -- self.m_testBg = display.newSprite("image/main_test_bg.jpg")
    --                 :pos(display.cx, display.cy)
    --                 :addTo(self)

    self.m_title = display.newSprite(nk.Res.main_bg_title)
                    :pos(display.cx, display.top - 75)
                    :addTo(self)

    -- top
    self.m_topStatusBg = display.newScale9Sprite(nk.Res.main_bg_top_bg, display.cx, display.top - 318, cc.size(664, 310))
    self.m_topStatusBg:addTo(self)

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

    -- TODO 使用前进度条

    self.m_afterTitle = cc.ui.UILabel.new({
                                UILabelType = 2,
                                text = self.m_useAfterStr,
                                size = 26,
                                color = cc.c3b(255, 255, 255),
                                align = cc.ui.TEXT_ALIGN_CENTER,
                            })
                            :addTo(self.m_contentNode)

    self.m_afterTitle:pos(-336, -40)

    -- TODO 使用后进度条

    self.m_promptStr = display.newSprite(nk.Res.main_bg_prompt)
    self.m_promptStr:pos(0, -165)
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
        print("//TODO 整理")
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
end

function MainScene:onExit()
end

function MainScene:onCleanup()
end

function MainScene:onEnter()
end

return MainScene
