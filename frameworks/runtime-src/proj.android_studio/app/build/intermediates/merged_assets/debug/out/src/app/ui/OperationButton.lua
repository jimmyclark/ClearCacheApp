-- Author: Jam
-- Date: 2015.004.15
--[[
  操作按钮  
]]

local OperationButton = class("OperationButton", function()
    return display.newNode()
end)

local  TouchHelper = poker.TouchHelper

OperationButton.BUTTON_WIDTH = 179
OperationButton.BUTTON_HEIGHT = 90 

function OperationButton:ctor(oprbgUp, oprbgDown)
    self.touchHelper_ = TouchHelper.new(self, self.onTouch_)
    self.touchHelper_:enableTouch()

    self.isEnabled_ = true
    self.isCheckMode_ = true
    self.isChecked_ = false
    self.isPressed_ = false

    local btnW = OperationButton.BUTTON_WIDTH
    local btnH = OperationButton.BUTTON_HEIGHT
    self.backgrounds_ = {
        oprUp = display.newSprite(oprbgUp):scale(0.75):addTo(self),
        oprDown = display.newSprite(oprbgDown):scale(0.75):addTo(self),
    }
    
    self.label_ = cc.ui.UILabel.new({text = "", size = 24, color = cc.c3b(0xcf, 0xea, 0xd0)})
        :align(display.CENTER, 0, 0)
        :addTo(self)
    self:updateView_()
end

function OperationButton:setEnabled(isEnabled)
    self.isEnabled_ = isEnabled
    self:updateView_()
    return self
end

function OperationButton:setLabel(label_)
    self.label_:setString(label_)
    return self
end

function OperationButton:getLabel()
    return self.label_:getString()
end

function OperationButton:isChecked()
    return self.isChecked_
end

function OperationButton:setChecked(isChecked, triggerHandler)
    local oldChecked = self.isChecked_
    self.isChecked_ = isChecked
    if isChecked ~= oldChecked and self.checkHandler_ and triggerHandler then
        self.checkHandler_(self, isChecked)
    end
    self:updateView_()
    return self
end

function OperationButton:setCheckMode(isCheckMode)
    self.isCheckMode_ = isCheckMode
    self:updateView_()
    return self
end

function OperationButton:onTouch(touchHandler)
    self.touchHandler_ = touchHandler
    return self
end

function OperationButton:onCheck(checkHandler)
    self.checkHandler_ = checkHandler
    return self
end

function OperationButton:onTouch_(evt)
    if self.isEnabled_ then
        if evt == TouchHelper.CLICK then
            self.isPressed_ = false
            if self.isCheckMode_ then
                self.isChecked_ = not self.isChecked_
                if self.checkHandler_ then
                    self.checkHandler_(self, self.isChecked_)
                end
            end
        elseif evt == TouchHelper.TOUCH_BEGIN then
            self.isPressed_ = true
        elseif evt == TouchHelper.TOUCH_END then
            self.isPressed_ = false
        end
        self:updateView_()
        if self.touchHandler_ then
            self.touchHandler_(evt)
        end
    end
end

function OperationButton:updateView_()
    if self.isCheckMode_ then
        --self.iconCheckBg_:show()
        if self.isChecked_ then
            --self.iconCheckIcon_:show()
        else
            --self.iconCheckIcon_:hide()
        end
        --self.label_:pos(20, 0)
    else
        --self.iconCheckBg_:hide()
        --self.iconCheckIcon_:hide()
        --self.label_:pos(0, 0)
    end

    if not self.isEnabled_ then
        --self:selectBackground("checkDown")
        self.label_:setColor(cc.c3b(0x83, 0x88, 0x91))
    elseif self.isCheckMode_ then
        if self.isPressed_ then
            --self:selectBackground("checkDown")
            self.label_:setColor(cc.c3b(0x5f, 0x8e, 0x60))
        elseif self.isChecked_ then
            --self:selectBackground("checkSelected")
            self.label_:setColor(cc.c3b(0xcf, 0xea, 0xd0))
        else
            --self:selectBackground("checkUp")
            self.label_:setColor(cc.c3b(0xcf, 0xea, 0xd0))
        end
    else
        if self.isPressed_ then
            self:selectBackground("oprDown")
            self.label_:setColor(cc.c3b(0x5f, 0x8e, 0x60))
        else 
            self:selectBackground("oprUp")
            self.label_:setColor(cc.c3b(0xcf, 0xea, 0xd0))
        end
    end
end

function OperationButton:selectBackground(name)
    for k,v in pairs(self.backgrounds_) do
        if k == name then
            v:show()
        else
            v:hide()
        end
    end
end

return OperationButton

