-- DevNode.lua
-- Author: Amnon
-- Date: 2019-02-21 16:44:18
-- Desc:
-- Usage:
--

local TAG = "DevNode"

local M = class(TAG, function ( ... )
    return display.newNode()
end)

M.m_maxLuaMemory = 0

addProperty(M, "curLuaMemory", 0, false)

function M:ctor(parent)
    local curScene = parent or display.getRunningScene()
    if (curScene) then
        self:addTo(parent, 99999)
    end
    display.newButton({
        file = "test/tools_btn.png",
        pos  = cc.p(display.width - 52, display.height - 125),
        parent = self
    }, function ()
        self:showTestMenuPopup()
    end)
    self:setMemoryTips()
    self:schedule(function ( ... )
        self:setMemoryTips()
    end, 2)

    display.newLabel({
        str = BUILD_TIME,
        parent = self,
        pos = cc.p(display.left + 3, display.bottom + 80),
        color = cc.c3b(255, 255, 255),
        hAlign = cc.TEXT_ALIGNMENT_LEFT,
        align = display.LEFT_CENTER,
    })
end


function M:setMemoryTips()
    local curLuaMemory = self:getCurLuaMemory()
    if (curLuaMemory > M.m_maxLuaMemory) then
        M.m_maxLuaMemory = curLuaMemory
    end
    if (not self.m_luaMemoryLabel) then
        self.m_luaMemoryLabel = display.newLabel({
            str = string.format("c : %.2d, m : %.2d", curLuaMemory, M.m_maxLuaMemory),
            parent = self,
            pos = cc.p(display.left + 200, display.bottom + 20),
            color = cc.c3b(255, 0, 0),
            hAlign = cc.TEXT_ALIGNMENT_LEFT,
            align = display.LEFT_CENTER,
        })
    else
        self.m_luaMemoryLabel:setString(string.format("c : %.2d, m : %.2d", curLuaMemory, M.m_maxLuaMemory))
    end
end

function M:getCurLuaMemory()
    self.m_curLuaMemory = collectgarbage("count")
    return self.m_curLuaMemory
end

function M:showTestMenuPopup()
    if (not self.m_testMenuPopup) then
        self.m_testMenuPopup = require("app.test.monitor.popup.TestMenuPopup").new()
            :addTo(self)
    end
    self.m_testMenuPopup:show()
end

return M
