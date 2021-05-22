local CustomProgress = class("CustomProgress", function()
    return display.newNode()
end)

function CustomProgress:ctor(params)
	self.m_params = params 

	self.m_bgName 	  = self.m_params.bg 
	self.m_foreBgName = self.m_params.foreBg
	self.m_bgWidth 	  = self.m_params.width
	self.m_bgHeight   = self.m_params.height
	self.m_textParams = self.m_params.text
	self.m_minWidth   = self.m_params.minWidth

	self._bg 	= display.newScale9Sprite(self.m_bgName, 0, 0 , cc.size(self.m_bgWidth, self.m_bgHeight))
	self._bg:addTo(self)

	if self.m_textParams then 
		self._text = cc.ui.UILabel.new({
                        UILabelType = 2,
                        text = "0%",
                        size = self.m_textParams.fontSize,
                        color = self.m_textParams.fontColor,
                        align = cc.ui.TEXT_ALIGN_CENTER,
                    })
		self._text:pos(self.m_textParams.pos.x, self.m_textParams.pos.y)
		self._text:addTo(self, 2)
	end

	self._fillBg = display.newScale9Sprite(self.m_foreBgName, -self.m_bgWidth/2, 0 , cc.size(self.m_bgWidth, self.m_bgHeight))
	self._fillBg:setAnchorPoint(0, 0.5)
	self._fillBg:addTo(self)

	self._value = 0

	self:setProgressValue(self._value)
end

function CustomProgress:setProgressValue(value)
	if value <= 0 then 
		value = 0
	end

	if value >= 100 then 
		value = 100
	end

	if value <= 0 then 
		self._fillBg:hide()

	else
		self._fillBg:show()

		self._fillWidth  = self.m_bgWidth
		self._fillHeight = self._fillBg:getContentSize().height

		local width = self._fillWidth * (value / 100) 

		if width <= self.m_minWidth then 
			width = self.m_minWidth
		end

		self._fillBg:setContentSize(width, self._fillHeight)
	end

	if self._text then 
		self._text:setString(value .. "%")
	end
end

return CustomProgress