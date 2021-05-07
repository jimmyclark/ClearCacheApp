--[[
    Class Name          : Loading
    description         : Loading界面.
    author              : ClarkWu
]]
local Loading = class("Loading");

function Loading:ctor()
	self.m_loadingContentStr = poker.LangUtil:getText("LOADING", "IS_ENTER_ROOM");               -- 正在进入游戏...
end

function Loading:hide()
	if self.m_background then
		self.m_background:setVisible(false);
	end

	if self.m_loading and not tolua.isnull(self.m_loading) then
		self.m_loading:setVisible(false);
		self.m_loading:stopAllActions();
	end
end

function Loading:show(isSwallowTouches,x,y,scene,isNotNeedBg,needReturn)
	if not scene then
		scene = display.getRunningScene();
	end

	if not self.m_background then
		if not isNotNeedBg then
			self.m_background = display.newScale9Sprite(nk.Res.Common_Blank,display.cx,display.cy,cc.size(display.width, display.height))
									:addTo(scene,9990);
			self.m_background:setTouchEnabled(true);
			self.m_background:setTouchSwallowEnabled(isSwallowTouches or true);

			self.m_backLoadingHelper = poker.TouchHelper.new(self.m_background,true);
		    self.m_backLoadingHelper:setOnEndedClicked(self,self.onLoadingTouch);
		    self.m_backLoadingHelper:setOwnAudio("");
		end

	else
		if not isNotNeedBg then
			self.m_background:setVisible(true);
			self.m_background:setTouchEnabled(true);
			self.m_background:setTouchSwallowEnabled(isSwallowTouches or true);
		end
	end

	if not self.m_loading then
		if isNotNeedBg then
			self.m_loading = display.newSprite("#" .. string.format(nk.Res.Common_loading,1))
		    					:addTo(scene,9990);
		else
			self.m_loading = display.newSprite("#" .. string.format(nk.Res.Common_loading,1))
		    					:addTo(self.m_background,9990);
		end

	else
		if tolua.isnull(self.m_loading) then
			return;
		end

		self.m_loading:setVisible(true);
	end

	self.m_loading:pos(x or display.cx,y or display.cy);
	self.m_loading:setTouchEnabled(true);
	self.m_loading:setTouchSwallowEnabled(isSwallowTouches or false);

	self.m_loading:stopAllActions();

	local frames = display.newFrames(nk.Res.Common_loading,1,8);
	local animation = display.newAnimation(frames,0.25);
	local animate = cc.Animate:create(animation);

	self.m_loading:runAction(cc.RepeatForever:create(animate));
end

function Loading:onLoadingTouch()
	if device.platform == "ios" then
		nk.ui.Loading:hide();
	end
end

function Loading:isVisible()
	if not self.m_loading then
		return false;
	end
	return self.m_loading:isVisible();
end

return Loading;