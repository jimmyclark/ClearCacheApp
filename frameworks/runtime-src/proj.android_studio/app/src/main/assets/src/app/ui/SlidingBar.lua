
--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--------------------------------
-- @module SlidingBar

--[[--

quick 滑动控件


]]

local SlidingBar = class("SlidingBar", function()
    return display.newNode()
end)

SlidingBar.BAR             = "bar"
SlidingBar.BUTTON          = "button"
SlidingBar.BAR_PRESSED     = "bar_pressed"
SlidingBar.BUTTON_PRESSED  = "button_pressed"
SlidingBar.BAR_DISABLED    = "bar_disabled"
SlidingBar.BUTTON_DISABLED = "button_disabled"

SlidingBar.PRESSED_EVENT = "PRESSED_EVENT"
SlidingBar.RELEASE_EVENT = "RELEASE_EVENT"
SlidingBar.STATE_CHANGED_EVENT = "STATE_CHANGED_EVENT"
SlidingBar.VALUE_CHANGED_EVENT = "VALUE_CHANGED_EVENT"

SlidingBar.BAR_ZORDER = 0     -- background bar
SlidingBar.BARFG_ZORDER = 1   -- foreground bar
SlidingBar.BUTTON_ZORDER = 2

-- start --

--------------------------------
-- 滑动控件的构建函数
-- @function [parent=#SlidingBar] new
-- @param number direction 滑动的方向
-- @param table images 各种状态对应的图片路径
-- @param table options 参数表

--[[--

滑动控件的构建函数

图片对应的状态:

-   bar 滑动图片
-   button 背景图片


可用参数有：

-   scale9 图片是否可缩放
-   min 最小值
-   max 最大值
-   touchInButton 是否只在触摸在滑动块上时才有效，默认为真

]]
-- end --

function SlidingBar:ctor(direction, images, options,distantPosition)
    self.fsm_ = {}
    cc(self.fsm_)
        :addComponent("components.behavior.StateMachine")
        :exportMethods()
    self.fsm_:setupState({
        initial = {state = "normal", event = "startup", defer = false},
        events = {
            {name = "disable", from = {"normal", "pressed"}, to = "disabled"},
            {name = "enable",  from = {"disabled"}, to = "normal"},
            {name = "press",   from = "normal",  to = "pressed"},
            {name = "release", from = "pressed", to = "normal"},
        },
        callbacks = {
            onchangestate = handler(self, self.onChangeState_),
        }
    })

    makeUIControl_(self)
    self:setLayoutSizePolicy(display.FIXED_SIZE, display.FIXED_SIZE)

    options = checktable(options)
    self.sizes = options.sizes;
    self.m_distantPosition = distantPosition;
    self.direction_ = direction
    self.isHorizontal_ = direction == display.LEFT_TO_RIGHT or direction == display.RIGHT_TO_LEFT
    self.images_ = clone(images)
    self.scale9_ = options.scale9
    self.scale9Size_ = nil
    self.min_ = checknumber(options.min or 0)
    self.max_ = checknumber(options.max or 100)
    self.value_ = self.min_
    self.buttonPositionRange_ = {min = 0, max = 0}
    self.buttonPositionOffset_ = {x = 0, y = 0}
    self.touchInButtonOnly_ = true
    if type(options.touchInButton) == "boolean" then
        self.touchInButtonOnly_ = options.touchInButton
    end

    self.buttonRotation_ = 0
    self.barSprite_ = nil
    self.buttonSprite_ = nil
    self.currentBarImage_ = nil
    self.currentButtonImage_ = nil

    self:updateImage_()
    self:updateButtonPosition_()

    self:setTouchEnabled(true)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
        -- if self.m_rotatedFlag then
        --     return self:onTouch_(event.name, event.y, event.x)

        -- else
            return self:onTouch_(event.name, event.x, event.y)
        -- end
    end)

    self.args_ = {direction, images, options}
end

function SlidingBar:setRotate(rotate)
    if rotate == 90 or rotate == -90 then
        self.m_rotatedFlag = true;

    else
        self.m_rotatedFlag = false;
    end

    return self:setRotation(rotate);
end

-- start --

--------------------------------
-- 设置滑动控件的大小
-- @function [parent=#SlidingBar] setSliderSize
-- @param number width 宽度
-- @param number height 高度
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:setSliderSize(width, height)
    -- assert(self.scale9_, "SlidingBar:setSliderSize() - can't change size for non-scale9 slider")
    self.scale9Size_ = {width, height}
    if self.barSprite_ then
        if self.scale9_ then
            self.barSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            self:setFgBarSize_(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        else
            self:setContentSizeAndScale_(self.barSprite_, cc.size(self.scale9Size_[1], self.scale9Size_[2]))
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1], self.scale9Size_[2]))
        end
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件的是否起效
-- @function [parent=#SlidingBar] setSliderEnabled
-- @param boolean enabled 有效与否
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:setSliderEnabled(enabled)
    self:setTouchEnabled(enabled)
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = SlidingBar.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = SlidingBar.STATE_CHANGED_EVENT, state = self.fsm_:getState()})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件停靠位置
-- @function [parent=#SlidingBar] align
-- @param integer align 停靠方式
-- @param integer x X方向位置
-- @param integer y Y方向位置
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:align(align, x, y)
    display.align(self, align, x, y)
    self.m_x = x;
    self.m_y = y;
    self:updateImage_()
    return self
end

-- start --

--------------------------------
-- 滑动控件是否有效
-- @function [parent=#SlidingBar] isButtonEnabled
-- @return boolean#boolean

-- end --

function SlidingBar:isButtonEnabled()
    return self.fsm_:canDoEvent("disable")
end

-- start --

--------------------------------
-- 得到滑动进度的值
-- @function [parent=#SlidingBar] getSliderValue
-- @return number#number

-- end --

function SlidingBar:getSliderValue()
    return self.value_
end

-- start --

--------------------------------
-- 设置滑动进度的值
-- @function [parent=#SlidingBar] setSliderValue
-- @param number value 进度值
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:setSliderValue(value)
    -- assert(value >= self.min_ and value <= self.max_, "SlidingBar:setSliderValue() - invalid value")
    if self.value_ ~= value then
        self.value_ = value
        self:updateButtonPosition_()
        self:dispatchEvent({name = SlidingBar.VALUE_CHANGED_EVENT, value = self.value_})
    end
    return self
end

-- start --

--------------------------------
-- 设置滑动控件的旋转度
-- @function [parent=#SlidingBar] setSliderButtonRotation
-- @param number rotation 旋转度
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:setSliderButtonRotation(rotation)
    self.buttonRotation_ = rotation
    self:updateImage_()
    return self
end

function SlidingBar:addSliderValueChangedEventListener(callback)
    return self:addEventListener(SlidingBar.VALUE_CHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户滑动监听
-- @function [parent=#SlidingBar] onSliderValueChanged
-- @param function callback 监听函数
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:onSliderValueChanged(callback)
    self:addSliderValueChangedEventListener(callback)
    return self
end

function SlidingBar:addSliderPressedEventListener(callback)
    return self:addEventListener(SlidingBar.PRESSED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户按下监听
-- @function [parent=#SlidingBar] onSliderPressed
-- @param function callback 监听函数
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:onSliderPressed(callback)
    self:addSliderPressedEventListener(callback)
    return self
end

function SlidingBar:addSliderReleaseEventListener(callback)
    return self:addEventListener(SlidingBar.RELEASE_EVENT, callback)
end

-- start --

--------------------------------
-- 注册用户抬起或离开监听
-- @function [parent=#SlidingBar] onSliderRelease
-- @param function callback 监听函数
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:onSliderRelease(callback)
    self:addSliderReleaseEventListener(callback)
    return self
end

function SlidingBar:addSliderStateChangedEventListener(callback)
    return self:addEventListener(SlidingBar.STATE_CHANGED_EVENT, callback)
end

-- start --

--------------------------------
-- 注册滑动控件状态改变监听
-- @function [parent=#SlidingBar] onSliderStateChanged
-- @param function callback 监听函数
-- @return SlidingBar#SlidingBar

-- end --

function SlidingBar:onSliderStateChanged(callback)
    self:addSliderStateChangedEventListener(callback)
    return self
end

function SlidingBar:onTouch_(event, x, y)
    if event == "began" then
        if not self:checkTouchInButton_(x, y) then return false end
        -- local posx, posy = self.buttonSprite_:getPosition()
        -- local buttonPosition = self:convertToWorldSpace(cc.p(posx, posy))
        -- self.buttonPositionOffset_.x = buttonPosition.x - x
        -- self.buttonPositionOffset_.y = buttonPosition.y - y
        self.m_isPressed = true;
        -- local buttonBgPosition = self.barSprite_:getRootNode():getPosition();
        self.m_targetBgX = self.sizes.positionX;
        self.fsm_:doEvent("press")
        self:dispatchEvent({name = SlidingBar.PRESSED_EVENT, x = x, y = y, touchInTarget = true})
        return true
    end

    if self.m_isPressed then
        if self.m_rotatedFlag then
            local value = (y - self.m_targetBgX) /self.sizes.bgWidth;

            self:setSliderValue(value);
        else
            local value = (x - self.m_targetBgX) /self.sizes.bgWidth;
            self:setSliderValue(value);
        end

    end
    -- local touchInTarget = self:checkTouchInButton_(x, y)
    -- x = x + self.buttonPositionOffset_.x
    -- y = y + self.buttonPositionOffset_.y
    -- local buttonPosition = self:convertToNodeSpace(cc.p(x, y))
    -- x = buttonPosition.x
    -- y = buttonPosition.y
    -- local offset = 0

    -- if self.isHorizontal_ then
    --     if x < self.buttonPositionRange_.min then
    --         x = self.buttonPositionRange_.min
    --     elseif x > self.buttonPositionRange_.max then
    --         x = self.buttonPositionRange_.max
    --     end
    --     if self.direction_ == display.LEFT_TO_RIGHT then
    --         offset = (x - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
    --     end
    -- else
    --     if y < self.buttonPositionRange_.min then
    --         y = self.buttonPositionRange_.min
    --     elseif y > self.buttonPositionRange_.max then
    --         y = self.buttonPositionRange_.max
    --     end
    --     if self.direction_ == display.TOP_TO_BOTTOM then
    --         offset = (self.buttonPositionRange_.max - y) / self.buttonPositionRange_.length
    --     else
    --         offset = (y - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
    --     end
    -- end

    -- self:setSliderValue(offset * (self.max_ - self.min_) + self.min_)

    if event ~= "moved" and self.fsm_:canDoEvent("release") then
        self.m_isPressed = false;
        self.fsm_:doEvent("release")
        self:dispatchEvent({name = SlidingBar.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
    end
end

function SlidingBar:getPressed()
    return self.m_isPressed;
end

function SlidingBar:checkTouchInButton_(x, y)
    if not self.buttonSprite_ then return false end
    if self.touchInButtonOnly_ then
        return self.buttonSprite_:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    else
        return self:getCascadeBoundingBox():containsPoint(cc.p(x, y))
    end
end

function SlidingBar:updateButtonPosition_()
    if not self.barSprite_ or not self.buttonSprite_ then return end

    local x, y = 0, 0
    if self.value_ <= 0.05 then self.value_ = 0 end
    if self.value_ >= 1 then self.value_ = 1 end

    if self.value_ == 0 then
        self.barfgSprite_:hide()
    else
        self.barfgSprite_:show()
    end


    if self.value_ <= self.sizes.fillWidth / self.maxFillWidth_ then
        x = self.sizes.fillWidth;
        self.barfgSprite_:setContentSize(cc.size(self.sizes.fillWidth, self.sizes.fillHeight))
    else
        x = self.maxFillWidth_ * self.value_;
        self.barfgSprite_:setContentSize(cc.size(self.maxFillWidth_ * self.value_, self.sizes.fillHeight))
    end

    if self.value_ == 0 then
        x = 20;
    end

    local barSize = self.barSprite_:getContentSize();
    local barFgSize = self.barfgSprite_:getContentSize();

    -- barSize.width = barSize.width * self.barSprite_:getScaleX()
    -- barSize.height = barSize.height * self.barSprite_:getScaleY()
    local buttonSize = self.buttonSprite_:getContentSize();
    -- local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
    -- local ap = self:getAnchorPoint()

    -- if self.isHorizontal_ then
    --     x = x - barSize.width * ap.x
    --     y = y + barSize.height * (0.5 - ap.y)
        -- self.buttonPositionRange_.length = barSize.width - buttonSize.width
        -- self.buttonPositionRange_.min = x + buttonSize.width / 2
        -- self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

    --     local lbPos = cc.p(0, 0)
    --     if self.barfgSprite_ and self.scale9Size_ then
    --         self:setContentSizeAndScale_(self.barfgSprite_, cc.size(offset * self.buttonPositionRange_.length + 15 * offset, self.scale9Size_[2]))
    --         lbPos = self:getbgSpriteLeftBottomPoint_()
    --     end
    --     if self.direction_ == display.LEFT_TO_RIGHT then
    --         x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
    --     else
    --         if self.barfgSprite_ and self.scale9Size_ then
    --             lbPos.x = lbPos.x + (1-offset)*self.buttonPositionRange_.length
    --         end
    --         x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
    --     end
    --     if self.barfgSprite_ and self.scale9Size_ then
    --         self.barfgSprite_:setPosition(lbPos)
    --     end
    -- else
    --     x = x - barSize.width * (0.5 - ap.x)
    --     y = y - barSize.height * ap.y
        -- self.buttonPositionRange_.length = barSize.height - buttonSize.height
        -- self.buttonPositionRange_.min = y + buttonSize.height / 2
        -- self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

    --     local lbPos = cc.p(0, 0)
    --     if self.barfgSprite_ and self.scale9Size_ then
    --         self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1] + 15, offset * self.buttonPositionRange_.length))
    --         lbPos = self:getbgSpriteLeftBottomPoint_()
    --     end
    --     if self.direction_ == display.TOP_TO_BOTTOM then
    --         y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
    --         if self.barfgSprite_ and self.scale9Size_ then
    --             lbPos.y = lbPos.y + (1-offset)*self.buttonPositionRange_.length
    --         end
    --     else
    --         y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
    --         if self.barfgSprite_ then
    --         end
    --     end
    --     if self.barfgSprite_ and self.scale9Size_ then
    --         self.barfgSprite_:setPosition(lbPos)
    --     end
    -- end

    if self.m_distantPosition then
        self.buttonSprite_:setPosition(x + self.m_distantPosition.x,barSize.height/2 + self.m_distantPosition.y);
    else
        self.buttonSprite_:setPosition(x, barSize.height/2)
    end
end

function SlidingBar:updateImage_()
    local state = self.fsm_:getState()

    local barImageName = "bar"
    local barfgImageName = "barfg"
    local buttonImageName = "button"
    local barImage = self.images_[barImageName]
    local barfgImage = self.images_[barfgImageName]
    local buttonImage = self.images_[buttonImageName]
    if state ~= "normal" then
        barImageName = barImageName .. "_" .. state
        buttonImageName = buttonImageName .. "_" .. state
    end

    if self.images_[barImageName] then
        barImage = self.images_[barImageName]
    end
    if self.images_[buttonImageName] then
        buttonImage = self.images_[buttonImageName]
    end

    if barImage then
        if self.currentBarImage_ ~= barImage then
            if self.barSprite_ then
                self.barSprite_:removeFromParent(true)
                self.barSprite_ = nil
            end

            if self.scale9_ then
                self.barSprite_ = display.newScale9Sprite(barImage,0,0,cc.size(self.sizes.bgWidth,self.sizes.bgHeight))
                self.m_targetPosition = self.barSprite_:getPosition();
                -- if not self.scale9Size_ then
                --     local size = self.barSprite_:getContentSize()
                --     self.scale9Size_ = {size.width, size.height}
                -- else
                --     self.barSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                -- end
            else

            end
            self:addChild(self.barSprite_, SlidingBar.BAR_ZORDER)
        end

        self.barSprite_:setAnchorPoint(self:getAnchorPoint())
        self.barSprite_:setPosition(0, 0)
    else
        printError("SlidingBar:updateImage_() - not set bar image for state %s", state)
    end

    if barfgImage then
        if not self.barfgSprite_ then
            if self.scale9_ then
                self.maxFillWidth_ = self.sizes.bgWidth - (self.sizes.bgHeight - self.sizes.fillHeight)
                self.barfgSprite_ = display.newScale9Sprite(barfgImage,0,0,cc.size(self.sizes.fillWidth,self.sizes.fillHeight))
                -- if self.scale9Size_[1] ~= 0 then
                --     self.barfgSprite_:setContentSize(cc.size(self.scale9Size_[1], self.scale9Size_[2]))
                -- else
                --     self.barfgSprite_:setContentSize(cc.size(self.scale9Size_[1] , self.scale9Size_[2]))
                -- end
            else

            end

            self:addChild(self.barfgSprite_, SlidingBar.BARFG_ZORDER)
            self.barfgSprite_:setAnchorPoint(cc.p(0, 0))
            self.barfgSprite_:setPosition(self.barSprite_:getPosition())
        end
    end

    if buttonImage then
        if self.currentButtonImage_ ~= buttonImage then
            if self.buttonSprite_ then
                self.buttonSprite_:removeFromParent(true)
                self.buttonSprite_ = nil
            end
            self.buttonSprite_ = display.newSprite(buttonImage)
            self:addChild(self.buttonSprite_, SlidingBar.BUTTON_ZORDER)
        end

        self.buttonSprite_:setPosition(0, 0)
        -- self.buttonSprite_:setRotation(self.buttonRotation_)
        self:updateButtonPosition_()
    else
        printError("SlidingBar:updateImage_() - not set button image for state %s", state)
    end
end

function SlidingBar:getButtonPosition()
    return self.buttonSprite_:getPosition();
end

function SlidingBar:onChangeState_(event)
    if self:isRunning() then
        self:updateImage_()
    end
end

function SlidingBar:setFgBarSize_(size)
    if not self.barfgSprite_ then
        return
    end

    if size ~= 0 then
        self.barfgSprite_:setContentSize(size)
    else
        self.barfgSprite_:setContentSize(0,0)
    end
end

function SlidingBar:getbgSpriteLeftBottomPoint_()
    if not self.barSprite_ then
        return cc.p(0, 0)
    end

    local posX, posY = self.barSprite_:getPosition()
    local size = self.barSprite_:getBoundingBox()
    local ap = self.barSprite_:getAnchorPoint()
    posX = posX - size.width*ap.x
    posY = posY - size.height*ap.y

    local point = cc.p(posX, posY)
    return point
end

function SlidingBar:setContentSizeAndScale_(node, s)
    if not node then
        return
    end

    local size = node:getContentSize()
    local scaleX
    local scaleY
    scaleX = s.width/size.width
    scaleY = s.height/size.height
    node:setScaleX(scaleX)
    node:setScaleY(scaleY)
end


function SlidingBar:createCloneInstance_()
    return SlidingBar.new(unpack(self.args_))
end

function SlidingBar:copySpecialProperties_(node)
    if node.scale9Size_ then
        self:setSliderSize(unpack(node.scale9Size_))
    end

    self:setSliderEnabled(node:isButtonEnabled())
    self:setSliderValue(node:getSliderValue())
    self:setSliderButtonRotation(node.buttonRotation_)
end

function SlidingBar:copyClonedWidgetChildren_()
end

return SlidingBar
