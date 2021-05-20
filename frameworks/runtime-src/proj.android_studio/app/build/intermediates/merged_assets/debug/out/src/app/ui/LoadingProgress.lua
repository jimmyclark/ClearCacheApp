-- Author: Jam
-- Date: 2016.09.08
local LoadingProgress = class("LoadingProgress", function()
    return display.newSprite(nk.Res.Common_Blank)
end)

function LoadingProgress:ctor(backgroundSkin, fillSkin, fillSize)

    self.progress = display.newScale9Sprite(backgroundSkin)
        :addTo(self)
    self.fill = cc.ui.UILoadingBar.new({ 
            scale9 = true, 
            capInsets = cc.rect(0, 0, 0, 0), 
            percent = 1, 
            direction = 0, 
            image = fillSkin, 
            viewRect = cc.rect(0, 0, fillSize.w, fillSize.h)})
        :addTo(self.progress)
    self.fill:setPosition(2, 3)
    self:setPercent(0)
end

function LoadingProgress:fillPosition(x, y)
    self.fill:setPosition(x, y)
    return self
end

function LoadingProgress:pos(x, y)
    self.progress:align(display.CENTER, x, y)
    return self
end

function LoadingProgress:setPercent(val)
    if val == self.value_ then
        return self
    end
    if val <= 0 then val = 0 end
    if val >= 100 then val = 100 end
    self.value_ = val
    if self.value_ == 0 then
        self.fill:hide()
    else
        self.fill:show()
    end
    if self.value_ > 0 and self.value_ < 6 then
        self.fill:setPercent(6)
    else
        self.fill:setPercent(self.value_)
    end

    return self
end

function LoadingProgress:size(w, h)
    self.progress:setContentSize(w, h)
    self:setContentSize(w, h)
    return self
end

return LoadingProgress