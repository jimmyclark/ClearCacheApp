---
-- 跑马灯节点视图
-- 接收一个列表（str) 和 配置表，然后以固定的形式播放列表里的数据，可以设置循环播放
-- 后续可以支持（展示富文本，订制动画时间，动态修改列表数据，过滤重复项 等）
-- @module MarqueeUI.lua
-- @author Amnon
-- @date 2019-11-29 17:05:26
-- @usage require("app.pokerUI.MarqueeUI").new()

local TAG = "MarqueeUI"

local M = class(TAG, function ()
    return display.newNode()
end)

addProperty(M, "loop", false, true, false)
addProperty(M, "msgList", {}, true, false)

local DEFAULT_CONFIG = {
    icon = {
        file = nk.Res.LuckyFlopPopup_icon_notice,
        pos  = cc.p(-12, 14)
    },
    clipNode = {
        rect = cc.rect(0, 0, 700, 30),
    },
    label = {
        pos      = cc.p(0, 0),
        fontSize = 22,
        color    = cc.c3b(0xb8, 0xad, 0xe6),
        align    = display.CENTER_LEFT,
        hAlign   = cc.TEXT_ALIGNMENT_LEFT,
    },
    anim = {
        rightToLeft = {cc.p(0, 15), cc.p(0, 15)},
        bottomToTop = {cc.p(0, 15), cc.p(0, 80)},
        bottomToTop2 = {cc.p(0, -20), cc.p(0, 15)},
    }
}

function M:ctor(uiConfig, msgList)
    LogUtil.d(TAG, "msgList = ", msgList)
    self.m_uiConfig = uiConfig or DEFAULT_CONFIG
    self:setMsgList(msgList)
    self:initView()
end

function M:initView()
    if (self.m_uiConfig.bg) then
        if (not self.m_bg) then
            self.m_bg = display.newImage({
                file = self.m_uiConfig.bg.file,
                pos  = self.m_uiConfig.bg.pos,
                parent = self
            })
        else
            self.m_bg:setSpriteFrame(string.sub(self.m_uiConfig.bg.file, 2))
        end
    end

    if (not self.m_clipNode) then
        self.m_clipNode = display.newClippingRectangleNode(self.m_uiConfig.clipNode.rect)
            :addTo(self)
        self.m_showWidth = self.m_uiConfig.clipNode.rect.width
    end
    local msgStr = self:dequeueMsg()
    if (not self.m_msgLabel) then
        self.m_msgLabel = display.newLabel({
            str      = msgStr,
            pos      = self.m_uiConfig.label.pos,
            fontSize = self.m_uiConfig.label.fontSize,
            color    = self.m_uiConfig.label.color,
            align    = self.m_uiConfig.label.align,
            hAlign   = self.m_uiConfig.label.hAlign,
            parent   = self.m_clipNode,
        })
    else
        self.m_msgLabel:setString(msgStr)
    end
    local msg2Str = self:dequeueMsg()
    if (not msg2Str) then
        msg2Str = msgStr
    end
    if (not self.m_msgLabel2) then
        self.m_msgLabel2 = display.newLabel({
            str      = msg2Str,
            pos      = self.m_uiConfig.label.pos,
            fontSize = self.m_uiConfig.label.fontSize,
            color    = self.m_uiConfig.label.color,
            align    = self.m_uiConfig.label.align,
            hAlign   = self.m_uiConfig.label.hAlign,
            parent   = self.m_clipNode,
        })
    else
        self.m_msgLabel2:setString(msgStr)
    end
    if (not self.m_icon) then
        self.m_icon = display.newImage({
            file = self.m_uiConfig.icon.file,
            pos  = self.m_uiConfig.icon.pos,
            parent = self
        })
    else
        self.m_icon:setSpriteFrame(string.sub(self.m_uiConfig.icon.file, 2))
    end
    self.m_msgLabel:hide()
    self.m_msgLabel2:hide()
    return self
end

function M:setLoop(isLoop)
    self.m_loop = isLoop and true or false
    return self
end

function M:setMsgList(msgList)
    self.m_msgList = msgList or {}
    return self
end

---
-- 获取下一条需要展示的消息
function M:dequeueMsg()
    if (table.isEmpty(self.m_msgList)) then
        return
    end
    return table.remove(self.m_msgList, 1)
end

---
-- 播放下一条
function M:playNext()
    if (self:getLoop()) then
        table.insert(self.m_msgList, self.m_msgLabel:getString())
    end
    local msgStr = self:dequeueMsg()
    if (string.isEmpty(msgStr) or isCObjEmpty(self.m_msgLabel)) then
        self:stop()
        self:hide()
        return
    end
    -- LogUtil.d(TAG, "playNext self.m_msgList = ", #self.m_msgList, self.m_msgList)
    local lastMsg = self.m_msgLabel2:getString()
    self.m_msgLabel:setString(lastMsg)
    self.m_msgLabel2:setString(msgStr)
    self:start()
end

function M:start()
    if (not self.m_msgLabel) then
        return self
    end
    -- LogUtil.d(TAG, "start msg begin ")
    self.m_msgLabel:show()
    self.m_msgLabel:stopAllActions()
    self.m_msgLabel:pos(self.m_uiConfig.anim.rightToLeft[1].x, self.m_uiConfig.anim.rightToLeft[1].y)
    self.m_msgLabel2:show()
    self.m_msgLabel2:stopAllActions()
    self.m_msgLabel2:pos(self.m_uiConfig.anim.bottomToTop2[1].x, self.m_uiConfig.anim.bottomToTop2[1].y)
    local msgSize  = self.m_msgLabel:getContentSize()
    local maxWidth = self.m_showWidth or 700
    if (msgSize.width > maxWidth) then
        local offsetX = maxWidth - msgSize.width
        local rightToLeftPos = cc.p(offsetX, self.m_uiConfig.anim.rightToLeft[2].y)
        local bottomToTopPos = cc.p(offsetX, self.m_uiConfig.anim.bottomToTop[2].y)
        self.m_msgLabel:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.MoveTo:create(0.5, rightToLeftPos),
                cc.DelayTime:create(2),
                cc.MoveTo:create(1, bottomToTopPos)
            )
        )
        self.m_msgLabel2:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(4.5),
                cc.MoveTo:create(1, self.m_uiConfig.anim.bottomToTop2[2]),
                cc.CallFunc:create(function ()
                    -- LogUtil.d(TAG, "start msg end and to playNext ")
                    -- if (self:getLoop()) then
                    --     table.insert(self.m_msgList, self.m_msgLabel2:getString())
                    -- end
                    self:playNext()
                end)
            )
        )
    else
        self.m_msgLabel:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.MoveTo:create(1, self.m_uiConfig.anim.bottomToTop[2])
            )
        )
        self.m_msgLabel2:runAction(
            cc.Sequence:create(
                cc.DelayTime:create(2),
                cc.MoveTo:create(1, self.m_uiConfig.anim.bottomToTop2[2]),
                cc.CallFunc:create(function ()
                    -- LogUtil.d(TAG, "start msg end and to playNext ")
                    -- if (self:getLoop()) then
                    --     table.insert(self.m_msgList, self.m_msgLabel2:getString())
                    -- end
                    self:playNext()
                end)
            )
        )
    end

    return self
end

function M:stop()
    if (not isCObjEmpty(self.m_msgLabel)) then
        self.m_msgLabel:stopAllActions()
    end
    if (not isCObjEmpty(self.m_msgLabel2)) then
        self.m_msgLabel2:stopAllActions()
    end
    self.m_isPlaying = false
    return self
end

return M
