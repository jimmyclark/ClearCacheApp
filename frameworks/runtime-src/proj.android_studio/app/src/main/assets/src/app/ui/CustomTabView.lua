-- File: CustomTabView.lua
-- Author: luaide-lite
-- Date: 2018-05-12 10:24:38
-- Desc:
-- Usage:
--[[
local param = {
    bg         = "images/tab_bg.png",
    bgScale9   = true,
    size       = cc.size(500, 50),
    selectedBg = "images/tab_selected_bg.png",
    list       = {
        { tag = 1, title = "tab 1" },
        { tag = 2, title = "tab 2" },
        { tag = 3, title = "tab 3" },
        { tag = 4, title = "tab 4" }
    }
}
local tabView = CustomTabView.new(param, function (_index)
        if (not tolua.isnull(self)) then
            self:onTabChange(_index)
        end
    end)
    :addTo(self)
    :pos(75, display.top - 260)
]]
local TAG = "CustomTabView"

local M = class(TAG, function ( ... )
    return display.newNode()
end)

function M:ctor (param, callback)
    self.m_titleContent       = {}
    self.m_titleSelected      = {}
    self.m_curSelectePosition = {}
    self.m_curTab             = 1
    self.m_tabTitleBg         = nil
    self.m_param              = clone(param) or {}
    self.m_callback           = callback

    local bgFileName = param.bg or ""
    local bgScale9   = param.bgScale9 or false
    local bgSize     = param.size or cc.size(0, 0)
    local list       = param.list or {}
    local curSelBg   = param.selectedBg or ""
    local tabBg
    if (bgScale9) then
        tabBg = display.newScale9Sprite(bgFileName, 0, 0, cc.size(bgSize.width, bgSize.height), false)
        :addTo(self)
    else
        tabBg = display.newSprite(bgFileName)
        :addTo(self)
    end
    local tabBgSize = tabBg:getContentSize()
    tabBg:pos(tabBgSize.width / 2, tabBgSize.height / 2)

    local count        = #list
    local itemWidth    = tabBgSize.width / count
    local itemHeight   = tabBgSize.height
    local bgSelected = display.newScale9Sprite(curSelBg, 0, 0, cc.size(itemWidth, itemHeight))
        :addTo(self)
        -- :hide()
    for i = 1, count do
        local title = list[i].title
        local tag = list[i].tag
        local fontSize = 24
        if (count > 6) then
            fontSize = math.floor(6 / count * 24)
        end
        local titleLabel = cc.ui.UILabel.new({
            UILabelType = 2,
            text        = title,
            size        = fontSize,
            color       = cc.c3b(255, 255, 255)
        })
            :align(display.CENTER, i * itemWidth - itemWidth / 2, itemHeight / 2)
            :addTo(self)
        local itemNodeTouch = display.newNode()
            :align(display.LEFT_CENTER, (i - 1) * itemWidth, itemHeight / 2)
            :addTo(self)
            :setContentSize(itemWidth, itemHeight)
        self.m_titleSelected[i]    = itemNodeTouch
        setButtonEvent(self.m_titleSelected[i], function()
            LogUtil.d(TAG, "onTabClick = ", i)
            self:changeTab(i)
        end)
        if (i == 1) then
            titleLabel:setColor(cc.c3b(255, 255, 255))
        else
            titleLabel:setColor(cc.c3b(240, 146, 36))
        end
        self.m_curSelectePosition[i] = cc.p(i * itemWidth - itemWidth / 2, itemHeight / 2)
        self.m_titleContent[i]       = titleLabel
    end
    if (self.m_curSelectePosition[1]) then
        bgSelected:pos(self.m_curSelectePosition[1].x or 0, self.m_curSelectePosition[1].y or 0)
    end
    self.m_tabTitleBg = bgSelected
    self:setContentSize(cc.size(tabBgSize.width, itemHeight))
end

function M:changeTab(index)
    if index == self.m_curTab then
        return
    end
    self.m_curTab = index
    if self.m_tabTitleBg then
        local position = self.m_curSelectePosition[index]
        self.m_tabTitleBg:stopAllActions()
        self.m_tabTitleBg:runAction(
            transition.sequence({
                cc.MoveTo:create(0.2, cc.p(position.x, position.y)),
                cc.CallFunc:create(function()
                    if self.m_titleContent then
                        for i = 1, #self.m_titleContent do
                            self.m_titleContent[i]:setColor(cc.c3b(240, 146, 36));
                        end
                        if self.m_titleContent[self.m_curTab] then
                            self.m_titleContent[self.m_curTab]:setColor(cc.c3b(255, 255, 255))
                        end
                    end
                end)
            })
        )
        if (self.m_callback) then
            -- LogUtil.d(TAG, "callback self.m_param = ", self.m_param)
            self.m_callback(self.m_curTab, self.m_param)
        end
    end
end

return M
