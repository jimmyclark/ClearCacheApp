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
    self.m_testBg = display.newSprite("image/main_test_bg.jpg")
                    :pos(display.cx, display.cy)
                    :addTo(self)

    self.m_title = display.newSprite(nk.Res.main_bg_title)
                    :pos(display.cx, display.top - 75)
                    :addTo(self)

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
    self.m_topDiskSprite:pos(50, self.m_topStatusBg:getContentSize().height/2)
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
