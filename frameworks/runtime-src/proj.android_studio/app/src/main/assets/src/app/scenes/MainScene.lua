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

    --init
    self:initData()
    self:initView()
end

function MainScene:run()
end

function MainScene:initView()
    display.newBackgroud({
            file   = nk.Res.main_bg,
            pos    = cc.p(display.cx, display.cy),
            parent = self
        })
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

function MainScene:initData()
end

function MainScene:onExit()
end

function MainScene:onCleanup()
end

function MainScene:onEnter()
end

return MainScene
