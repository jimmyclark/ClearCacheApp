--[[
    Class Name          : Button
    description         : 游戏按钮基类.
    author              : ClarkWu
]]
local Button = class("Button", function(param,isNotNeedContinus,figureTables,btnReplaceFigure,options)
		return cc.ui.UIPushButton.new(param,options);
end);

--[[
    @Constructor
    @param Table - cc.ui.UIPushButton中的参数
]]
function Button:ctor(params,isNotNeedContinus,figureTables, btnReplaceFigure,options)
	if params and not params.noAnim then
		self:onButtonPressed(function(event)
	        event.target:setColor(cc.c3b(220,220,220));
	        local scale = event.target:getScaleX();
            local scaleY = event.target:getScaleY();
	        event.target:setScale(scale - 0.02, scaleY - 0.02);
	    end)
	    self:onButtonRelease(function(event)
	        event.target:setColor(cc.c3b(255,255,255));
	        local scale = event.target:getScaleX();
            local scaleY = event.target:getScaleY();
	        event.target:setScale(scale + 0.02, scaleY + 0.02);
	    end)
	end

	self.m_notNeedContinus = isNotNeedContinus or false;

	if figureTables then
		self.m_figures = figureTables;

		local figure = nil;

		if type(figureTables) == "table" then
			figure = figureTables.normal;

		else
			figure = figureTables;
		end

		if figure then
			self.m_buttonFigure = display.newSprite("#" .. figure);
			self.m_buttonFigure:pos(0,3);
			self.m_buttonFigure:addTo(self);
		end
	end

    if btnReplaceFigure then
        self.m_buttonReplaceFigrue =display.newScale9Sprite(btnReplaceFigure.res,0,0, cc.size(btnReplaceFigure.w,btnReplaceFigure.h) )
        self.m_buttonReplaceFigrue:addTo(self);
    end
end

function Button:setFigurePosition(x,y)
	if self.m_buttonFigure then
		self.m_buttonFigure:pos(x,y);
	end

	return self;
end

--[[
    按钮点击事件
    create-author       : ClarkWu
]]
function Button:onButtonClicked(btnClickedFunc)
	self:addButtonClickedEventListener(function()
		-- 处理连续点击
		if not self.m_notNeedContinus then
			local nowTime = os.time();

			if not self.m_onClickTime then
				self.m_onClickTime = nowTime;

			else
				if nowTime - self.m_onClickTime < 1 then
					return;
				end

				self.m_onClickTime = nowTime;
			end
		end

		-- 播放音效

        if not self.m_soundNotShowFlag then
		    nk.SoundManager:playSound(nk.Audio.Effects.CLICK_BUTTON);
        end

		btnClickedFunc();
	end)

	return self;
end

function Button:setButtonEnabled(enabled)
    self:setTouchEnabled(enabled)
    if enabled and self.fsm_:canDoEvent("enable") then
        self.fsm_:doEventForce("enable")
        self:dispatchEvent({name = Button.STATE_CHANGED_EVENT, state = self.fsm_:getState()})

        if self.m_figures and self.m_figures.normal then
        	if self.m_buttonFigure then
        		self.m_buttonFigure:setSpriteFrame(self.m_figures.normal);
        	end
        end

    elseif not enabled and self.fsm_:canDoEvent("disable") then
        self.fsm_:doEventForce("disable")
        self:dispatchEvent({name = Button.STATE_CHANGED_EVENT, state = self.fsm_:getState()})

        if self.m_figures and self.m_figures.disabled then
        	if self.m_buttonFigure then
        		self.m_buttonFigure:setSpriteFrame(self.m_figures.disabled);
        	end
        end
    end


    return self
end

function Button:setFlippedX(flipped)
    for i = 1, #self.sprite_ do
        self.sprite_[i]:setFlippedX(flipped)
    end
end

function Button:getImageContentSize()
    if self.sprite_[1] then
        return self.sprite_[1]:getContentSize();
    end
end

function Button:setSoundNotShow(soundNotShowFlag)
    self.m_soundNotShowFlag = soundNotShowFlag
end

return Button;