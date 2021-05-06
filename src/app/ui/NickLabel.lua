--[[
    专门用来单行展示文本，如果文本展示过长，直接用三个点替换
]]
local NickLabel = class("NickLabel", function()
     return display.newNode()
end)

function NickLabel:ctor(params)
    self.m_fontSize  = params.fontSize or 22
    self.m_fontColor = params.fontColor or cc.c3b(255, 255, 255)
    self.m_align     = params.align or cc.ui.TEXT_ALIGN_LEFT
    self.m_text      = params.text or ""
    self.m_maxWidth  = params.maxWidth

    self:initView()
end

function NickLabel:initView()
    self.m_pointLabel = cc.ui.UILabel.new({
                        UILabelType = 2,
                        text = "...",
                        size = self.m_fontSize,
                        color = self.m_fontColor,
                        align = self.m_align,
                 })
    self.m_pointLabel:addTo(self)

    self.m_label = cc.ui.UILabel.new({
                        UILabelType = 2,
                        text = self.m_text,
                        size = self.m_fontSize,
                        color = self.m_fontColor,
                        align = self.m_align,
                 })
    self.m_label:setAnchorPoint(0, 0.5)

    self.m_clippingNode = cc.ClippingNode:create():addTo(self)

    self.m_stencil      = display.newRect(cc.rect(0, -15, self.m_maxWidth - self.m_pointLabel:getContentSize().width,
        self.m_label:getContentSize().height + 30), {borderColor = cc.c4f(0,1,0,1), borderWidth = 1})
    self.m_clippingNode:setStencil(self.m_stencil)
    -- self.m_stencil:addTo(self)

    self.m_label:addTo(self.m_clippingNode)
    -- self.m_label:addTo(self)

    -- 判断是否需要使用...
    if self.m_label:getContentSize().width > self.m_maxWidth - self.m_pointLabel:getContentSize().width then
        if self.m_pointLabel then
            self.m_pointLabel:show()
            self.m_pointLabel:pos(self.m_maxWidth - self.m_pointLabel:getContentSize().width + 1, 0)
        end

    else
        if self.m_pointLabel then
            self.m_pointLabel:hide()
        end
    end
end

function NickLabel:setString(text)
    if self.m_label then
        self.m_label:setString(text)

        if self.m_label:getContentSize().width > self.m_maxWidth - self.m_pointLabel:getContentSize().width then
            if self.m_pointLabel then
                self.m_pointLabel:show()
                self.m_pointLabel:pos(self.m_maxWidth - self.m_pointLabel:getContentSize().width + 1, 0)
            end

        else
            if self.m_pointLabel then
                self.m_pointLabel:hide()
            end
        end
    end
end

function NickLabel:getContentSize()
    local size = {}

    if self.m_label then
        size.height = self.m_label:getContentSize().height
    end

    if self.m_label:getContentSize().width > self.m_maxWidth - self.m_pointLabel:getContentSize().width then
        size.width = self.m_maxWidth

    else
        size.width = self.m_label:getContentSize().width
    end

    return size
end

function NickLabel:opacity(opacity)
    if self.m_label then
        self.m_label:opacity(opacity)
    end
end

return NickLabel