--[[
    Class Name          : DJExtendListView
    description         : 自定义ListView扩展类.
    author              : ClarkWu
]]
local DJExtendListView = class("DJExtendListView", cc.ui.UIListView);

--[[
    @Override
    @param event userData - 事件
    create-author       : ClarkWu
]]
function DJExtendListView:onTouch_(event)
	if #self.items_ <= 0 then 
		return false;
	end

	local w = 0;
	local h = 0;

	for k,v in pairs(self.items_) do 
		local tempW,tempH = v:getItemSize();
		w = w + tempW;
		h = h + tempH;

	end

	if DJExtendListView.super.DIRECTION_VERTICAL == self.direction then
		if self.viewRect_.height >= h then 
			return false;
		end

	else
		if self.viewRect_.width  >= w then 
			return false;
		end
	end

	if "began" == event.name and not self:isTouchInViewRect(event) then
		return false;
	end

	if "began" == event.name and self.touchOnContent then
		local cascadeBound = self.scrollNode:getCascadeBoundingBox();

		if not cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y)) then
			return false;
		end
	end

	if "began" == event.name then
		self.m_touchListFlag = true;
		self.prevX_ = event.x;
		self.prevY_ = event.y;
		self.bDrag_ = false;
		local x,y = self.scrollNode:getPosition();
		self.position_ = {x = x, y = y};

		transition.stopTarget(self.scrollNode);
		self:callListener_{name = "began", x = event.x, y = event.y};

		self:enableScrollBar();

		self.scaleToWorldSpace_ = self:scaleToParent_();
		return true;

	elseif "moved" == event.name then
		if self:isShake(event) then
			return;
		end

		self.bDrag_ = true;
		self.speed.x = event.x - event.prevX;
		self.speed.y = event.y - event.prevY;

		if self.direction == DJExtendListView.super.DIRECTION_VERTICAL then
			self.speed.x = 0;

		elseif self.direction == DJExtendListView.super.DIRECTION_HORIZONTAL then
			self.speed.y = 0;
		end

		self:scrollBy(self.speed.x, self.speed.y);
		self:callListener_{name = "moved", x = event.x, y = event.y};

	elseif "ended" == event.name then
		self.m_touchListFlag = false;

		if self.bDrag_ then
			self.bDrag_ = false;
			self:scrollAuto();

			self:callListener_{name = "ended", x = event.x, y = event.y};

			self:disableScrollBar();

		else
			self:callListener_{name = "clicked", x = event.x, y = event.y};
		end
	end
end

function DJExtendListView:elasticScroll()
	local cascadeBound = self:getScrollNodeRect()
	local disX, disY = 0, 0
	local viewRect = self:getViewRect() -- InWorldSpace()
	local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))

	cascadeBound.x = t.x
	cascadeBound.y = t.y
	self.scaleToWorldSpace_ = self.scaleToWorldSpace_ or {x=1,y=1}
	cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
	cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y

	-- dump(self.scaleToWorldSpace_, "UIScrollView - scaleToWorldSpace_:")
	-- dump(cascadeBound, "UIScrollView - cascBoundingBox:")
	-- dump(viewRect, "UIScrollView - viewRect:")

	if cascadeBound.width < viewRect.width then
		disX = viewRect.x - cascadeBound.x
	else
		if cascadeBound.x > viewRect.x then
			disX = viewRect.x - cascadeBound.x
		elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
			disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
		end
	end

	if cascadeBound.height < viewRect.height then
		disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
	else
		if cascadeBound.y > viewRect.y then
			disY = viewRect.y - cascadeBound.y
		elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
			disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
		end
	end

	if 0 == disX and 0 == disY then
		return
	end

	transition.moveBy(self.scrollNode,
		{x = disX, y = disY, time = 0.3,
		easing = "backout",
		onComplete = function()
			self:callListener_{name = "scrollEnd"}
		end})
end

return DJExtendListView;