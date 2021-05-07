--[[
    Class Name          : SmallLongLoading
    description         : SmallLongLoading界面.
    author              : ClarkWu
]]
local SmallLongLoading = class("SmallLongLoading",function()
    return display.newNode();
end);

function SmallLongLoading:ctor()

end

function SmallLongLoading:createLoading(isSwallowTouches,params)
    if not params then
        return;
    end

    if not self.m_loadingBg then
        if params.needAllBg then
            local tab = params.needAllBg;
            self.m_loadingNeedAllBg = display.newScale9Sprite(tab.file, tab.x, tab.y,
                cc.size(tab.w, tab.h)
                )
            self.m_loadingNeedAllBg:setTouchEnabled(true)
            self.m_loadingNeedAllBg:setTouchSwallowEnabled(true)
            :addTo(self)
        end

        if params.needScale then
            self.m_loadingBg = display.newScale9Sprite(nk.Res.Common_loadingBg,params.x,params.y,
                                    cc.size(1280,params.h))
                                    :addTo(self);

            self.m_loadingBg:setScale(params.w/1280,1)

        else
            self.m_loadingBg = display.newScale9Sprite(nk.Res.Common_loadingBg,params.x,params.y,
                                    cc.size(params.w,params.h))
                                    :addTo(self);
        end


    else
        self.m_loadingBg:show();
    end

    if not self.m_loading then
        if params.needScale then
            self.m_loading = display.newSprite(nk.Res.Login_loadingCircle)
                                :addTo(self);

        else
            self.m_loading = display.newSprite(nk.Res.Login_loadingCircle)
                                :addTo(self.m_loadingBg);
        end

    else
        self.m_loading:show();
    end

    if params.needScale then
        self.m_loading:pos(params.x,params.y + 20);

    else
        self.m_loading:pos(self.m_loadingBg:getContentSize().width/2, self.m_loadingBg:getContentSize().height/2 + 20);
    end

    if not self.m_loadingContent then
        if params.needScale then
            self.m_loadingContent = display.newSprite(nk.Res.Login_loadingContent)
                                    :addTo(self);

        else
            self.m_loadingContent = display.newSprite(nk.Res.Login_loadingContent)
                                    :addTo(self.m_loadingBg);
        end

    else
        self.m_loadingContent:show();
    end

    if params.needScale then
        self.m_loadingContent:pos(params.x,params.y + 20);

    else
        self.m_loadingContent:pos(self.m_loadingBg:getContentSize().width/2, self.m_loadingBg:getContentSize().height/2 + 20)
    end

    -- local loadingContent = showLongLongLoadingTxt;

    -- if loadingContent == nil then
    --     loadingContent = self.m_loadingContentEnterRoomStr;
    -- end

    if not params.str then
        self.m_loading:pos(self.m_loadingBg:getContentSize().width/2, self.m_loadingBg:getContentSize().height/2);

    else
        if not self.m_loadingTxt then
            self.m_loadingTxt = cc.ui.UILabel.new({
                                        UILabelType = 2,
                                        text = params.str,
                                        size = 28,
                                        color = cc.c3b(255, 255, 255) ,
                                        align = cc.ui.TEXT_ALIGN_CENTER
                                    })

            if params.needScale then
                self.m_loadingTxt:addTo(self);

            else
                self.m_loadingTxt:addTo(self.m_loadingBg);
            end
        else
            self.m_loadingTxt:setString(params.str);
            self.m_loadingTxt:show();
        end

        if params.needScale then
            self.m_loadingTxt:pos(params.x - self.m_loadingTxt:getContentSize().width/2,
                params.y - 35);

        else
            self.m_loadingTxt:pos(self.m_loadingBg:getContentSize().width/2 - self.m_loadingTxt:getContentSize().width/2,
                self.m_loadingBg:getContentSize().height/2 - 40);
        end

    end

    self.m_loadingContent:stopAllActions()

    local rotateAction = cc.RotateBy:create(2,360);

    self.m_loading:scale(0.7)
    self.m_loadingContent:scale(0.7)

    self.m_loading:runAction(cc.RepeatForever:create(rotateAction));

    local rotateZAction = cc.OrbitCamera:create(2, 1, 0, 0, 360, 0, 0)
    self.m_loadingContent:runAction(cc.RepeatForever:create(rotateZAction));
end

-- function SmallLongLoading:pos(x,y)
--     if self.m_loading then
--         self.m_loading:pos(x,y)
--     end
-- end

return SmallLongLoading;