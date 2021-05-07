local DJSlidingBar = import(".DJSlidingBar");
local DJCustomSlidingBar = class("DJCustomSlidingBar", DJSlidingBar);

function DJCustomSlidingBar:ctor(direction, images, options,isNeedSliderAnim)
    DJCustomSlidingBar.super.ctor(self,direction, images, options)

    self.m_isNeedSliderAnim = isNeedSliderAnim;
    self.m_btnSprite = images.button;
    self.m_btnSpriteHeight =  display.newSprite(self.m_btnSprite):getContentSize().height;
    self.m_sliderButtons = {};

    if images.labelArrays and #images.labelArrays > 0 then
        self.m_defaultFontScale = images.defaultFontScale or 1;
        self.m_changeFontScale = images.changeFontScale or 1;
        self.m_defaultFontColor = images.defaultFontColor or cc.c3b(255,255,255);
        self.m_changeFontColor = images.changeFontColor or cc.c3b(255,255,255);
        local offsetX = images.offsetX or 0;
        local offsetY = images.offsetY or 0;

        self.m_labels = {};

        local ap = self:getAnchorPoint();
        for i = 1, #images.labelArrays do
            self.m_labels[i] = cc.Label:createWithSystemFont(images.labelArrays[i], display.DEFAULT_TTF_FONT, images.labelSize or 22)
            self.m_labels[i]:setAnchorPoint(0.5,0.5)
            if i == 1 then
                self.m_labels[i]:setScale(self.m_changeFontScale);
                self.m_labels[i]:setColor(self.m_changeFontColor);

            else
                self.m_labels[i]:setScale(self.m_defaultFontScale);
                self.m_labels[i]:setColor(self.m_defaultFontColor);
            end
            self.m_labels[i]:addTo(self);

            local barSize = self.barSprite_:getContentSize()
            barSize.width = barSize.width * self.barSprite_:getScaleX()
            barSize.height = barSize.height * self.barSprite_:getScaleY()
            local offset = ((i - 1) - self.min_) / (self.max_ - self.min_)
            local x,y = 0,0;

            if self.isHorizontal_ then
                x = 0
                y = y + barSize.height * (0.5 - ap.y) + 20 + offsetY;

                if self.direction_ == display.LEFT_TO_RIGHT then
                    x = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length

                else
                    x = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length
                end

                x = x - barSize.width /2 + offsetX;

            else
                x = x - barSize.width * (0.5 - ap.x) + offsetX;
                y = 0;

                if self.direction_ == display.TOP_TO_BOTTOM then
                    y = self.buttonPositionRange_.min + (1 - offset) * self.buttonPositionRange_.length

                else
                    y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length
                end

                y = y - barSize.height / 2 + offsetY;
            end

            self.m_labels[i]:pos(x,y);
        end
    end
end

function DJCustomSlidingBar:setSliderValue(value)
    assert(value >= self.min_ and value <= self.max_, "DJCustomSlidingBar:setSliderValue() - invalid value")
    if self.value_ ~= value then
        self.value_ = value
        self:updateButtonPosition_()

        if self.m_foreProgress then
            if self.max_ > 0 then
                self.m_foreProgress:setPercentage(self.value_ /self.max_ * 100);

            else
                self.m_foreProgress:setPercentage(self.value_);
            end
        end

        local textStr = "";

        if self.m_labels and self.m_labels[value + 1] then
            self.m_labels[value + 1]:setScale(self.m_changeFontScale or 1);
            self.m_labels[value + 1]:setColor(self.m_changeFontColor or cc.c3b(255,255,255))
            textStr = self.m_labels[value + 1]:getString();

            for i = 1, #self.m_labels do
                if i ~= (value + 1) then
                    self.m_labels[i]:setScale(self.m_defaultFontScale or 1);
                    self.m_labels[i]:setColor(self.m_defaultFontColor or cc.c3b(255,255,255));
                end
            end
        end

        self:dispatchEvent({name = DJSlidingBar.VALUE_CHANGED_EVENT, value = self.value_,text = textStr })
    end

    if self.m_isNeedSliderAnim then
        self:changeSliderAnim(value)
    end

    return self
end

function DJCustomSlidingBar:setContentPosition(x,y)
    if self.m_foreProgress then
        self.m_foreProgress:pos(x,y)
    end
end

function DJCustomSlidingBar:setButtonPosition(x,y)
    if self.barSprite_ then
        self.barSprite_:pos(x,y)
    end
end

function DJCustomSlidingBar:onTouch_(event, x, y)
    if event == "began" then
        if not self:checkTouchInButton_(x, y) then
            -- self:dispatchEvent({name = DJCustomSlidingBar.PRESSED_EVENT, x = x, y = y, touchInTarget = true})

            -- self.fsm_:doEvent("press")
            return true;
        end
        -- bugfix:dispatchEvent may change position, so call it first
        -- self:dispatchEvent({name = DJCustomSlidingBar.PRESSED_EVENT,touchInTarget = true})
        -- local posx, posy = self.buttonSprite_:getPosition()
        -- local buttonPosition = self:convertToWorldSpace(cc.p(posx, posy))
        -- self.buttonPositionOffset_.x = buttonPosition.x - x
        -- self.buttonPositionOffset_.y = buttonPosition.y - y
        -- self.fsm_:doEvent("press")
        return true
    end

    local touchInTarget = self:checkTouchInButton_(x, y)
    x = x + self.buttonPositionOffset_.x
    y = y + self.buttonPositionOffset_.y
    local buttonPosition = self:convertToNodeSpace(cc.p(x, y))
    x = buttonPosition.x
    y = buttonPosition.y
    local offset = 0

    if self.isHorizontal_ then
        if x < self.buttonPositionRange_.min then
            x = self.buttonPositionRange_.min
        elseif x > self.buttonPositionRange_.max then
            x = self.buttonPositionRange_.max
        end
        if self.direction_ == display.LEFT_TO_RIGHT then
            offset = (x - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        else
            offset = (self.buttonPositionRange_.max - x) / self.buttonPositionRange_.length
        end
    else
        if y < self.buttonPositionRange_.min then
            y = self.buttonPositionRange_.min
        elseif y > self.buttonPositionRange_.max then
            y = self.buttonPositionRange_.max
        end
        if self.direction_ == display.TOP_TO_BOTTOM then
            offset = (self.buttonPositionRange_.max - y) / self.buttonPositionRange_.length
        else
            offset = (y - self.buttonPositionRange_.min) / self.buttonPositionRange_.length
        end
    end

    self:setSliderValue(checkint(offset * (self.max_ - self.min_) + self.min_))

    if event ~= "moved" then
        -- self.fsm_:doEvent("press")
        -- self.fsm_:doEvent("release")
        self:dispatchEvent({name = DJCustomSlidingBar.RELEASE_EVENT, x = x, y = y, touchInTarget = touchInTarget})
    end
end

function DJCustomSlidingBar:getButtonPosition()
    return self.buttonSprite_:getPosition();
end

function DJCustomSlidingBar:changeSliderAnim(value)
    if self.m_isNeedSliderAnim then
        if not self.m_currentHeight then
            self.m_currentHeight = 0;
        end

        local valueStr = "";

        if not self.m_lastValue then
            self.m_lastValue = value;

            if value > 0 then
                valueStr = "+";
            end

        else
            if value - self.m_lastValue >= 0 then
                valueStr = "+";

            elseif value - self.m_lastValue < 0 then
                valueStr = "-";
            end

            self.m_lastValue = value;
        end

        local temp_x, temp_y = 0, 0;
        local barSize = self.barSprite_:getContentSize()
        local ap = self:getAnchorPoint()
        temp_x = temp_x - barSize.width * (0.5 - ap.x)
        temp_y = temp_y - barSize.height * ap.y
        local offset = (self.value_ - self.min_) / (self.max_ - self.min_)

        temp_y = self.buttonPositionRange_.min + offset * self.buttonPositionRange_.length

        if valueStr == "+" then
            -- self:schedule(function()
            while(self.m_currentHeight < temp_y)
            do
                if self.m_currentHeight >= temp_y then
                    -- self:stopAllActions();
                    return;
                end

                self.m_sliderButtons[#self.m_sliderButtons + 1] = display.newSprite(self.m_btnSprite)
                self.m_sliderButtons[#self.m_sliderButtons]:pos(temp_x, self.m_currentHeight)
                self.m_sliderButtons[#self.m_sliderButtons]:addTo(self)

                self.m_currentHeight = self.m_currentHeight + self.m_btnSpriteHeight/2;

            end


            -- end,0.001)

        elseif valueStr == "-" then
            self:stopAllActions();

            while(self.m_currentHeight > temp_y + self.m_btnSpriteHeight/2)
            do
                if self.m_sliderButtons and #self.m_sliderButtons > 0 then
                    poker.safeRemoveNode(self.m_sliderButtons[#self.m_sliderButtons]);
                    table.remove(self.m_sliderButtons);
                end

                self.m_currentHeight = self.m_currentHeight - self.m_btnSpriteHeight/2;
            end
        end
    end
end

function DJCustomSlidingBar:onSliderRelease(callback)
    self:addSliderReleaseEventListener(callback)
    return self;
end

return DJCustomSlidingBar;
