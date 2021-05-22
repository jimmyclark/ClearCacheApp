local ColorfulProgress = class("ColorfulProgress", function()
    return display.newNode()
end)

function ColorfulProgress:ctor(params)
	self.m_params = params

	self.m_bgs 		= self.m_params.bgs 
	self.m_bgWidth 	= self.m_params.width
	self.m_bgHeight = self.m_params.height
	self.m_minWidth = self.m_params.minWidth

	self.m_bg = display.newScale9Sprite(self.m_bgs[1], 0, 0, cc.size(self.m_bgWidth , self.m_bgHeight))
	self.m_bg:addTo(self)

	self.m_values 			= {}
	self.m_forebgs			= {}
	self.m_foreClippingNode = {}
	self.m_clippingRect 	= {}

	for i = 2, #self.m_bgs do 
		self:createColorBg(i - 1, self.m_bgs[i])
	end

	-- 初始化每个进度的值
	for i = 1, #self.m_bgs do 
		self.m_values[i] = 0
	end
end

function ColorfulProgress:createColorBg(index, bgName)
	self.m_foreClippingNode[index] = cc.ClippingNode:create():addTo(self)
	self.m_clippingRect[index] = display.newScale9Sprite(nk.Res.main_bg_progressStencil, -self.m_bgWidth/2, 0, cc.size(self.m_bgWidth , self.m_bgHeight + 2))
	self.m_clippingRect[index]:setAnchorPoint(0,0.5)
	self.m_foreClippingNode[index]:setStencil(self.m_clippingRect[index])

	self.m_forebgs[index] = display.newScale9Sprite(bgName, 0, 0, cc.size(self.m_bgWidth , self.m_bgHeight))
	self.m_forebgs[index]:addTo(self.m_foreClippingNode[index])

	-- 刚开始宽度都设置为0
	self.m_clippingRect[index]:setContentSize(0, self.m_bgHeight)
	-- self.m_clippingRect[index]:pos(-100, 0)
end

function ColorfulProgress:setProgressValue(valueArray)
	if type(valueArray) ~= "table" then 
		return 
	end

	local curStartX = -self.m_bgWidth/2 

	-- 无论如何，我这边都需要算出4个值
	local totalValue = 100

	for i = 1, #valueArray do 
		if valueArray[i] then 
			self.m_values[i] = valueArray[i]
			totalValue = totalValue - valueArray[i]
		end
	end

	if totalValue <= 0 then 
		totalValue = 0
	end

	self.m_values[#self.m_values] = totalValue

	-- 根据计算出来的宽度，进行每个宽度的占比处理(只需要处理前length - 1个)
	for i = 1, #self.m_values - 1 do 
		if self.m_values[i] then 
			local value = self.m_values[i]

			local width = (value / 100) * self.m_bgWidth

			if self.m_clippingRect[i] then 
				self.m_clippingRect[i]:setContentSize(width, self.m_bgHeight)
				self.m_clippingRect[i]:pos(curStartX, 0)
			end

			curStartX = curStartX + width
		end
	end
end

return ColorfulProgress