--[[
    数字图片UI
    author : ClarkWu
    date   : 2016/10/03
]]
local NumberImage = class("NumberImage", function()
    return display.newNode();
end)

function NumberImage:ctor(uiPath, ...)
    self.muiPath = uiPath;
    self.w = 0;
    self.h = 0;
end

function NumberImage:setNumber(formatNumber,isShowLobby,scaleWidth)
    self:removeAllChildren();

    local x,y = 0,0;

    scaleWidth = scaleWidth or 0;

    for i = 1, string.len(formatNumber) do
    	local c = string.sub(formatNumber,i,i);

    	if self.muiPath[c] then
    	    local numImg = cc.ui.UIImage.new(self.muiPath[c]);

    	    if numImg then
    	        local size = numImg:getContentSize();

    	        numImg:pos(x, y);
    	        x = x + size.width - scaleWidth;
    	        self.w = x;
    	        self.h = size.height;
    	        self:addChild(numImg);
                numImg:setTag(i);
                if isShowLobby then
                    y = y + 8;

                    self:setContentSize(x, size.height);
                else
                    numImg:align(display.CENTER_LEFT);
                    self:setContentSize(x, size.height);
                end
            end
    	end
    end
end

function NumberImage:setNumberCenter(formatNumber,distant, needCalWidthContainDistant)
    self:removeAllChildren();
    distant = distant or 0;
    local x,y = 0,0;

    local scaleHeight = 0;
    local width = 0;

    for i = 1, string.len(formatNumber) do
        local c = string.sub(formatNumber,i,i);
        if self.muiPath[c] then
            local numImg = cc.ui.UIImage.new(self.muiPath[c]);

            if numImg then
                local size = numImg:getContentSize();
                numImg:align(display.CENTER_LEFT);
                numImg:pos(x, y);
                x = x + size.width - distant;
                self.w = x;
                self.h = size.height;

                if needCalWidthContainDistant then
                    width = width + numImg:getContentSize().width - distant
                else
                    width = width + numImg:getContentSize().width
                end

                self:addChild(numImg);
                numImg:setTag(i);
                self:setContentSize(x, size.height);
                scaleHeight = size.height;
            end
        end
    end

    return scaleHeight, 0, width;
end

function NumberImage:setFormatNumber(formatNumber)
    local flag = false;
     local x,y = 0,0;

    for i = 1, string.len(formatNumber) do
        local c = string.sub(formatNumber,i,i);

        if self.muiPath[c] then
            local numImg = self:getChildByTag(i);

            if numImg then
                numImg:setSpriteFrame(string.sub(self.muiPath[c],2));
                local size = numImg:getContentSize();
                numImg:align(display.CENTER_LEFT);
                numImg:pos(x, y);
                numImg:setVisible(true);
                x = x + size.width;
                flag = true;
                self:setContentSize(x, size.height);

            else
                numImg = cc.ui.UIImage.new(self.muiPath[c]);
                numImg:align(display.CENTER_LEFT);
                numImg:pos(x, y);
                local size = numImg:getContentSize();
                x = x + size.width;
                self:addChild(numImg);
                numImg:setTag(i);
                self:setContentSize(x, size.height);

            end
        end
    end

    local childCount = self:getChildrenCount();

    for i = string.len(formatNumber) + 1, childCount do
        local numImg = self:getChildByTag(i);
        numImg:setVisible(false);
    end
end

function NumberImage:opacity(opacity)
    local childCount = self:getChildrenCount();

    for i = 1, childCount do
        local numImg = self:getChildByTag(i);
        if numImg then
            numImg:opacity(opacity);
        end
    end
end

return NumberImage;