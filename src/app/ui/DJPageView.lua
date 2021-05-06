local DJPageView = class("DJPageView", cc.ui.UIPageView);

function DJPageView:ctor(params)
	self.items_ = {}
	self.viewRect_ = params.viewRect or cc.rect(0, 0, display.width, display.height)
	self.column_ = params.column or 1
	self.row_ = params.row or 1
	self.columnSpace_ = params.columnSpace or 0
	self.rowSpace_ = params.rowSpace or 0
	self.padding_ = params.padding or {left = 0, right = 0, top = 0, bottom = 0}
	self.bCirc = params.bCirc or false

	self:setClippingRegion(self.viewRect_)

	if not params.isNotNeedAuto then
		self:setTouchEnabled(true)
		self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        	return self:onTouch_(event)
    	end)
	end

	self.args_ = {params}
end

function DJPageView:next(callFunc)
	if self.m_isPlaying then
		return;
	end
	if self.curPageIdx_ + 1 <= self:getPageCount() then
		-- self:disablePage()
		self:gotoPage(self.curPageIdx_ + 1,true,nil , callFunc)

	elseif self.bCirc then
		self:gotoPage(1, true , nil, callFunc)
	end
end

function DJPageView:previous(callFunc)
	if self.m_isPlaying then
		return;
	end
	if self.curPageIdx_ - 1 > 0 then
		-- self:disablePage()
		self:gotoPage(self.curPageIdx_ - 1,true,nil , callFunc)

	elseif self.bCirc then
		self:gotoPage(self:getPageCount(), true , nil, callFunc)
	end
end

function DJPageView:gotoPage(pageIdx, bSmooth, bLeftToRight, callBack)
	if self.m_isPlaying then
		sendClientLog("正在播放动画，禁止移动")
		return;
	end

	self.m_isPlaying = true;

	if pageIdx < 1 or pageIdx > self:getPageCount() then
		self.m_isPlaying = false;
		return self
	end
	if pageIdx == self.curPageIdx_ and bSmooth then
		self.m_isPlaying = false;
		return self
	end

	local callBackFunc = function()
		-- self.m_isPlaying = false;

		if callBack then
			callBack()
		end
	end

	if bSmooth then
		self:resetPagePos(pageIdx, bLeftToRight)
		self:scrollPagePos(pageIdx, bLeftToRight,callBackFunc)
	else
		self.pages_[self.curPageIdx_]:setVisible(false)
		self.pages_[pageIdx]:setVisible(true)
		self.pages_[pageIdx]:setPosition(
			self.viewRect_.x, self.viewRect_.y)
		self.curPageIdx_ = pageIdx

		-- self.notifyListener_{name = "clicked",
		-- 		item = self.items_[clickIdx],
		-- 		itemIdx = clickIdx,
		-- 		pageIdx = self.curPageIdx_}
		self:notifyListener_{name = "pageChange"}
		self.m_isPlaying = false;
	end

	return self
end

function DJPageView:scrollPagePos(pos, bLeftToRight,callBack)
	local pageIdx = self.curPageIdx_
	local page
	local pageWidth = self.viewRect_.width
	local dis
	local count = #self.pages_

	if self.pages_[self.curPageIdx_] then
		self.pages_[self.curPageIdx_]:stopAllActions()
	end

	dis = pos - pageIdx
	if self.bCirc then
		local disL,disR
		if dis > 0 then
			disR = dis
			disL = disR - count
		else
			disL = dis
			disR = disL + count
		end

		if nil == bLeftToRight then
			dis = ((math.abs(disL) > math.abs(disR)) and disR) or disL
		elseif bLeftToRight then
			dis = disR
		else
			dis = disL
		end
	end

	local disABS = math.abs(dis)
	local x = self.viewRect_.x
	local movedis = dis*pageWidth

	for i=1, disABS do
		if dis > 0 then
			pageIdx = pageIdx + 1
		else
			pageIdx = pageIdx + count
			pageIdx = pageIdx - 1
		end
		pageIdx = pageIdx % count
		if 0 == pageIdx then
			pageIdx = count
		end
		page = self.pages_[pageIdx]
		if page then
			page:setVisible(true)
			transition.moveBy(page,
					{x = -movedis, y = 0, time = 0.3})
		end
	end
	transition.moveBy(self.pages_[self.curPageIdx_],
					{x = -movedis, y = 0, time = 0.3,
					onComplete = function()
						self.m_isPlaying = false;
						local pageIdx = (self.curPageIdx_ + dis + count)%count
						if 0 == pageIdx then
							pageIdx = count
						end
						self.curPageIdx_ = pageIdx
						self:disablePage()
						self:notifyListener_{name = "pageChange"}
						if callBack then
							callBack(self.curPageIdx_);
						end
					end})
end

function DJPageView:onTouch_(event)
	if not self.pages_ or #self.pages_ <= 1 then
		return false;
	end

	if "began" == event.name
		and not self:isTouchInViewRect_(event) then
		printInfo("UIPageView - touch didn't in viewRect")
		return false
	end

	if self.m_isPlaying then
		return;
	end

	if "began" == event.name then
		self:stopAllTransition()
		self.bDrag_ = false
	elseif "moved" == event.name then
		if math.abs(event.x - event.prevX) > 20 or math.abs(event.y - event.prevY) > 20 then
			self.bDrag_ = true
			self.speed = event.x - event.prevX
			self:scroll(self.speed)
		end
	elseif "ended" == event.name then
		if self.bDrag_ then
			local ret,msg = pcall(function()
				self:scrollAuto()
			end)

			if not ret then
				self:stopAllTransition()
				-- self.m_isPlaying = false
				self:notifyListener_{name = "pageChange"}
				self:gotoPage(self.curPageIdx_)
			end
		else
			self:resetPages_()
			self:onClick_(event)
		end
	end

	return true
end

function DJPageView:getDrag()
	return self.bDrag_;
end

function DJPageView:getCurPage()
	return self.curPageIdx_;
end

function DJPageView:getTotalPage()
	return #self.pages_;
end

function DJPageView:notifyListener_(event)
	if not self.touchListener then
		return
	end

	event.pageView = self
	event.pageIdx = self.curPageIdx_
	self.touchListener(event)
	if (event and event.name == "pageChange") then
		-- self.m_isPlaying = false
	end
	self:stopAllTransition()
	self:resetPages_()
end



return DJPageView;