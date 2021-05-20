local DJSlidingBar = class("DJSlidingBar", cc.ui.UISlider);

function DJSlidingBar:ctor(direction, images, options)
    DJSlidingBar.super.ctor(self, direction, images, options)

    if images.foreBg then
        self.m_foreProgressSprite = display.newSprite(images.foreBg);
        self.m_foreProgress = display.newProgressTimer(self.m_foreProgressSprite, display.PROGRESS_TIMER_BAR)
        self.m_foreProgress:addTo(self,2)

        if direction == display.LEFT_TO_RIGHT then
            self.m_foreProgress:setMidpoint(cc.p(0, 1))
            self.m_foreProgress:setBarChangeRate(cc.p(1, 0))

        elseif direction == display.RIGHT_TO_LEFT then
            self.m_foreProgress:setMidpoint(cc.p(1,0))
            self.m_foreProgress:setBarChangeRate(cc.p(1, 0))

        elseif direction == display.TOP_TO_BOTTOM then
            self.m_foreProgress:setMidpoint(cc.p(0,1))
            self.m_foreProgress:setBarChangeRate(cc.p(0, 1))

        elseif direction == display.BOTTOM_TO_TOP then
            self.m_foreProgress:setMidpoint(cc.p(1,0))
            self.m_foreProgress:setBarChangeRate(cc.p(0, 1))
        end
    end
end

function DJSlidingBar:updateButtonPosition_()
    if not self.barSprite_ or not self.buttonSprite_ then return end

    local x, y = 0, 0
    local barSize = self.barSprite_:getContentSize()
    barSize.width = barSize.width * self.barSprite_:getScaleX()
    barSize.height = barSize.height * self.barSprite_:getScaleY()
    local buttonSize = self.buttonSprite_:getContentSize()
    local offset = (self.value_ - self.min_) / (self.max_ - self.min_)
    local ap = self:getAnchorPoint()
    if self.isHorizontal_ then
        x = x - barSize.width * ap.x
        y = y + barSize.height * (0.5 - ap.y)
        self.buttonPositionRange_.length = barSize.width - buttonSize.width / 2
        -- self.buttonPositionRange_.length = barSize.width
        self.buttonPositionRange_.min = x + buttonSize.width / 4
        -- self.buttonPositionRange_.min = x
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self.scale9Size_ then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(offset * self.buttonPositionRange_.length, self.scale9Size_[2]))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self.direction_ == display.LEFT_TO_RIGHT then
            x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length

        else
            if self.barfgSprite_ and self.scale9Size_ then
                lbPos.x = lbPos.x + (1-offset)*self.buttonPositionRange_.length
            end
            x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
        end
        if self.barfgSprite_ and self.scale9Size_ then
            self.barfgSprite_:setPosition(lbPos)
        end
    else
        x = x - barSize.width * (0.5 - ap.x)
        y = y - barSize.height * ap.y
        self.buttonPositionRange_.length = barSize.height
        self.buttonPositionRange_.min = y
        self.buttonPositionRange_.max = self.buttonPositionRange_.min + self.buttonPositionRange_.length

        local lbPos = cc.p(0, 0)
        if self.barfgSprite_ and self.scale9Size_ then
            self:setContentSizeAndScale_(self.barfgSprite_, cc.size(self.scale9Size_[1], offset * self.buttonPositionRange_.length))
            lbPos = self:getbgSpriteLeftBottomPoint_()
        end
        if self.direction_ == display.TOP_TO_BOTTOM then
            y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
            if self.barfgSprite_ and self.scale9Size_ then
                lbPos.y = lbPos.y + (1-offset)*self.buttonPositionRange_.length
            end
        else
            y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
            if self.barfgSprite_ then
            end
        end
        if self.barfgSprite_ and self.scale9Size_ then
            self.barfgSprite_:setPosition(lbPos)
        end
    end

    self.buttonSprite_:setPosition(x, y)
end

function DJSlidingBar:setSliderValue(value)
    assert(value >= self.min_ and value <= self.max_, "UISlider:setSliderValue() - invalid value")
    if self.value_ ~= value then
        self.value_ = value
        self:updateButtonPosition_()

        if self.m_foreProgress then
            self.m_foreProgress:setPercentage(self.value_);
        end

        self:dispatchEvent({name = DJSlidingBar.VALUE_CHANGED_EVENT, value = self.value_})
    end
    return self
end

return DJSlidingBar;