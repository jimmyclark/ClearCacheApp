--[[
    Class Name          : KeypadManager
    description         : 监听返回键和菜单键管理器.
    author              : ClarkWu
]]
local KeypadManager = class("KeypadManager")

local logger = poker.Logger.new("KeypadManager")

function KeypadManager:ctor()
    -- 存放弹窗的Table
    self.m_popup_object = {}
end

--[[
    为界面添加返回键值方法
    @scene  userData - 场景
    @mtype Number    - 标记唯一场景的数值
    create-author       : ClarkWu
]]
function KeypadManager:addToScene(scene, mtype)
    local layer = display.newLayer()
    scene:addChild(layer)
    layer:setKeypadEnabled(true)

    self.m_popup_object[#self.m_popup_object+1] = mtype

    layer:addNodeEventListener(cc.KEYPAD_EVENT, function(event)
        if DEBUG > 0 then

        end

        if event.key == "back" or tonumber(event.key or 0) == 149 then
            if nk.PopupManager:isTopLevelPop() then
                if nk.PopupManager:isForceUpdatePopup() then
                    self:showExitPopup()
                    return
                end

                if nk.PopupManager:isNotBackCancel() then
                    return
                end

                if not nk.PopupManager:isBackCanClosePopu() then
                    nk.PopupManager:removeTopPopupIf()
                end

                return
            end

        elseif event.key == "menu" then

        end
    end)
end

return KeypadManager
