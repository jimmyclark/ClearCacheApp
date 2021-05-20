local TouchHelper = class("TouchHelper");

function TouchHelper:ctor(target,needContinuous,ignoreColorAndScale,onlyIgnoreScale,scale)
    self.m_target = target;

    self.m_needContinuous = needContinuous or false;
    self.m_ignoreColorAndScale = ignoreColorAndScale or false;
    self.m_onlyIgnoreScale = onlyIgnoreScale or false;
    self.m_scale = scale or nil;

    self.m_isTouchNeedJudgeRectFlag = false;

    self.m_target:setTouchEnabled(true);
    self.m_touchListener = self.m_target:addNodeEventListener(cc.NODE_TOUCH_EVENT, handler(self, self.onTouch));
end

function TouchHelper:getNodeListener()
    return self.m_touchListener;
end

function TouchHelper:removeNodeEventListener(listener)
    if tolua.isnull(self.m_target) then
        return;
    end

    self.m_target:removeNodeEventListener(listener)
end

function TouchHelper:setTouchEnabled(enabled)
    if tolua.isnull(self.m_target) then
        return;
    end
    self.m_target:setTouchEnabled(enabled);
end

function TouchHelper:setTouchSwallowEnabled(enabled)
    if tolua.isnull(self.m_target) then
        return;
    end

    self.m_target:setTouchSwallowEnabled(enabled);
end

function TouchHelper:setTouchNeedJudgeRect(isTouchNeedJudgeRectFlag)
    self.m_isTouchNeedJudgeRectFlag = isTouchNeedJudgeRectFlag;
end

function TouchHelper:onTouch(event)
    if event.name == "began" then
        self.m_touchBeganX = event.x;
        self.m_touchBeganY = event.y;

        if self.m_beginFunc then
            self.m_beginFunc(self.m_beginObj,self.m_target,event.x,event.y);

        else
            if not self.m_ignoreColorAndScale then
                if not self.m_onlyIgnoreScale then
                    self.m_target:setScale(0.98);
                end

                if self.m_scale then
                    self.m_target:setScale(self.m_scale - 0.02)
                end

                self.m_target:setColor(cc.c3b(220,220,220));
            end
        end

        return true;
    end

    local touchInTarget = self:checkTouchInSprite_(self.m_touchBeganX, self.m_touchBeganY)
                        and self:checkTouchInSprite_(event.x, event.y)

    if event.name == "ended" then
        if self.m_isTouchNeedJudgeRectFlag then
            if not touchInTarget then
                return true;
            end
        end

        if not self.m_ignoreColorAndScale then
            if not self.m_onlyIgnoreScale then
                self.m_target:setScale(1.0);
            end

            if self.m_scale then
                self.m_target:setScale(self.m_scale)
            end

            self.m_target:setColor(cc.c3b(255,255,255));
        end

        if self.m_needContinuous then
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

        if self.m_endFunc then
            local ret = self.m_endFunc(self.m_endObj,self.m_target,event.x,event.y);

            if ret == -1 then
                return true;
            end
        end

        if not self.m_ownAudio then
            nk.SoundManager:playSound(nk.Audio.Effects.CLICK_BUTTON);

        elseif self.m_ownAudio ~= "" then
            nk.SoundManager:playSound(self.m_ownAudio);
        end


        return true;

    elseif event.name == "moved" then
        if self.m_moveFunc then
            self.m_moveFunc(self.m_moveObj,self.m_target,event.x,event.y, touchInTarget);
        end

        return true;
    end
end

function TouchHelper:setOnBeganClicked(obj,beginFunc)
    self.m_beginObj = obj;
    self.m_beginFunc = beginFunc;
end

function TouchHelper:setOnMovedClicked(obj,moveFunc)
    self.m_moveObj = obj;
    self.m_moveFunc = moveFunc;
end

function TouchHelper:setOnEndedClicked(obj,endFunc)
    self.m_endObj = obj;
    self.m_endFunc = endFunc;
end

function TouchHelper:setOwnAudio(ownAudio)
    self.m_ownAudio = ownAudio;
end

function TouchHelper:checkTouchInSprite_(x, y)
    if not self.m_target then
        return;
    end

    return self.m_target:getCascadeBoundingBox():containsPoint(cc.p(x, y))
end

return TouchHelper;

