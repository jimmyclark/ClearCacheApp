--[[
    Class Name          : LongLoading
    description         : LongLoading界面.
    author              : ClarkWu
]]
local LongLoading = class("LongLoading");

function LongLoading:ctor()
	self.m_loadingContentEnterRoomStr = poker.LangUtil:getText("LOADING", "IS_ENTER_ROOM");               -- 正在进入游戏...
end

--[[
    LongLoading条隐藏方法
    create-author       : ClarkWu
]]
function LongLoading:hide()
	if not isCObjEmpty(self.m_background) then
		self.m_background:setVisible(false);
	end

	if not isCObjEmpty(self.m_loadingBg) then
		self.m_loadingBg:setVisible(false);
	end

	if not isCObjEmpty(self.m_loading) then
		self.m_loading:setVisible(false);
	end

	if not isCObjEmpty(self.m_loadingContent) then
		self.m_loadingContent:setVisible(false);
		self.m_loadingContent:stopAllActions();
	end

	if not isCObjEmpty(self.m_loadingTxt) then
		self.m_loadingTxt:setVisible(false);
	end

end

--[[
    LongLoading条显示方法
    @param fileName  String 		- LongLoading的文件名称
    @param isSwallowTouches Boolean - 是否允许下方事件被捕捉
    @param x,y Number 				- x,y坐标
    @param isDelayToShowCloseBtn Boolean -- 是否延迟显示 close btn
    @param callback                 - 回调函数
    create-author       : ClarkWu
]]
function LongLoading:show(x,y,showLongLongLoadingTxt,isSwallowTouches,isDelayToShowCloseBtn,callback)
	if not self.m_background then
		self.m_background = display.newScale9Sprite(nk.Res.Common_Blank,display.cx,display.cy,cc.size(display.width, display.height))
									:addTo(display:getRunningScene(),10001);
		self.m_background:setTouchEnabled(true);

	else
		self.m_background:setVisible(true);
	end

	self.m_background:setTouchSwallowEnabled(isSwallowTouches or true);

	if not self.m_loadingBg then
		self.m_loadingBg = display.newSprite(nk.Res.Common_loadingBg)
	    						:addTo(self.m_background);
	else
		self.m_loadingBg:setVisible(true);
	end

	self.m_loadingBg:pos(x or display.cx,y or display.cy);

	if not self.m_loading then
		self.m_loading = display.newSprite(nk.Res.Login_loadingCircle)
	    						:addTo(self.m_background);
	else
		self.m_loading:setVisible(true);
	end

	self.m_loading:pos(x or display.cx,y or display.cy + 20);

	if not self.m_loadingContent then
		self.m_loadingContent = display.newSprite(nk.Res.Login_loadingContent)
	    							:addTo(self.m_background);

	else
		self.m_loadingContent:setVisible(true);
	end

	self.m_loadingContent:pos(x or display.cx,y or display.cy + 20)

	local loadingContent = showLongLongLoadingTxt;

	if loadingContent == nil then
		loadingContent = self.m_loadingContentEnterRoomStr;
	end

	if not self.m_loadingTxt then
		self.m_loadingTxt = cc.ui.UILabel.new({
	                                UILabelType = 2,
	                                text = loadingContent,
	                                size = 28,
	                                color = cc.c3b(255, 255, 255) ,
	                                align = cc.ui.TEXT_ALIGN_CENTER
	                            })
	    						:addTo(self.m_background);
	else
		self.m_loadingTxt:setString(loadingContent);
		self.m_loadingTxt:setVisible(true);
	end

	self.m_loadingTxt:pos(display.cx - self.m_loadingTxt:getContentSize().width/2 + 10,display.cy - 40);

    -- 加入延时关闭按钮
    if (isDelayToShowCloseBtn) then
        if (not self.m_closeBtn) then
            self.m_closeBtn = nk.ui.Button.new(nk.Res.Common_btn_cancel)
                            :onButtonClicked(function(event)
                                if self and self.hide then
                                    self:hide()
                                end
                                if callback then
                                    callback()
                                end
                            end)
                        :pos(display.cx, display.cy - 65)
                        :addTo(self.m_background)
        end
        self.m_closeBtn:hide()
        self.m_closeBtn:performWithDelay(function ( ... )
            if (self.m_loadingTxt) then
                self.m_loadingTxt:runAction(cc.MoveTo:create(0.5, cc.p(display.cx - self.m_loadingTxt:getContentSize().width/2 + 10,display.cy - 10)))
            end
            if (self.m_loading) then
                self.m_loading:runAction(cc.MoveTo:create(0.5, cc.p(display.cx, display.cy + 50)))
            end
            if (self.m_loadingContent) then
                self.m_loadingContent:runAction(cc.MoveTo:create(0.5, cc.p(display.cx, display.cy + 50)))
            end
            if (self.m_closeBtn) then
                self.m_closeBtn:show()
            end
        end, 15)
    else
        if (self.m_closeBtn) then
            self.m_closeBtn:hide()
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

-- 此方法用于添加至节点上的Loading
function LongLoading:showByNode(params)
    if not params then
        return
    end

    local x                         = params.x
    local y                         = params.y
    local root                      = params.root
    local showLongLongLoadingTxt    = params.showLongLongLoadingTxt
    local isSwallowTouches          = params.isSwallowTouches
    local isDelayToShowCloseBtn     = params.isDelayToShowCloseBtn
    local callback                  = params.callback

    if isCObjEmpty(self.m_background) then
        self.m_background = display.newScale9Sprite(nk.Res.Common_Blank,display.cx,display.cy,cc.size(display.width, display.height))
                                    :addTo(root)
        self.m_background:setTouchEnabled(true)
    else
        self.m_background:setVisible(true)
    end

    self:show(x,y,showLongLongLoadingTxt,isSwallowTouches,isDelayToShowCloseBtn,callback)
end

return LongLoading;