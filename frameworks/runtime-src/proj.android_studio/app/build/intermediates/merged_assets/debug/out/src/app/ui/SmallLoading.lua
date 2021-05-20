--[[
    Class Name          : SmallLoading
    description         : SmallLoading界面.
    author              : ClarkWu
]]
local SmallLoading = class("SmallLoading",function()
	return display.newNode();
end);

function SmallLoading:ctor()
	
end

function SmallLoading:hide()
	if self.m_loading then 
		self.m_loading:setVisible(false);
	end
end

function SmallLoading:show()
	if self.m_loading then 
		self.m_loading:setVisible(true);
	end
end

function SmallLoading:createLoading(isSwallowTouches,x,y)
	isNotNeedBg = true;

	self.m_loading = display.newSprite("#" .. string.format(nk.Res.Common_loading,1))
		    			:addTo(self,9990);

	self.m_loading:pos(x or display.cx,y or display.cy);
	self.m_loading:setTouchEnabled(true);
	self.m_loading:setTouchSwallowEnabled(isSwallowTouches or false);

	self.m_loading:stopAllActions();
	
	local frames = display.newFrames(nk.Res.Common_loading,1,8);
	local animation = display.newAnimation(frames,0.25);
	local animate = cc.Animate:create(animation);

	self.m_loading:runAction(cc.RepeatForever:create(animate));
end

function SmallLoading:pos(x,y)
	if self.m_loading then 
		self.m_loading:pos(x,y)
	end
end

return SmallLoading;