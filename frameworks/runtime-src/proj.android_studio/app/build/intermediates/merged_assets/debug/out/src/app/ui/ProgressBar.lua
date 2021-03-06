--[[
    取值范围：0~1
    local bar = ProgressBar.new("#progress_bar_bg.png", "#progress_bar_fill.png", 200)
    bar:addTo(container)
    bar:setValue(0.3)
]]

local ProgressBar = class("ProgressBar", function ()
    return display.newNode()
end)

function ProgressBar:ctor(backgroundSkin, fillSkin, sizes)
    self.sizes_ = sizes
    self.background_ = display.newScale9Sprite(backgroundSkin, 0, 0, cc.size(sizes.bgWidth + 4, sizes.bgHeight))
        :align(display.LEFT_CENTER, 0, 0)
        :addTo(self)
    self.fill_ = display.newScale9Sprite(fillSkin, 0, 0, cc.size(sizes.fillWidth, sizes.fillHeight))
        :align(display.LEFT_CENTER, (sizes.bgHeight - sizes.fillHeight) * 0.5, 0)
        :addTo(self)
    self.value_ = 0
    self.maxFillWidth_ = sizes.bgWidth - (sizes.bgHeight - sizes.fillHeight)
end

function ProgressBar:setValue(val)
    --if val == self.value_ then
    --    return self
    --end
    if val <= 0 then val = 0 end
    if val >= 1 then val = 1 end
    self.value_ = val
    if self.value_ <= 0.01 then
        self.fill_:hide()
    else
        self.fill_:show()
    end
    local minWidth = self.m_minWidth or 18;

    if self.value_ <= self.sizes_.fillWidth / self.maxFillWidth_ then
        if self.sizes_.fillWidth * self.value_ <= minWidth then
            self.fill_:setContentSize(cc.size(minWidth, self.sizes_.fillHeight))

        else
            self.fill_:setContentSize(cc.size(self.sizes_.fillWidth * self.value_, self.sizes_.fillHeight))
        end

    else
        self.fill_:setContentSize(cc.size(self.maxFillWidth_ * self.value_, self.sizes_.fillHeight))
    end

    return self
end

function ProgressBar:setMinWidth(minWidth)
    self.m_minWidth = minWidth;
end

function ProgressBar:setFillPosition(x,y)
    if self.fill_ then
        self.fill_:pos(x,y);
    end
end

return ProgressBar
