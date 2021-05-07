local PopupManager = class("PopupManager");

local POPUP_ORDER = 1000;

function PopupManager:ctor()
    -- 数据容器
    self.m_popupStack = {};

    -- 视图容器
    self.m_container = display.newNode();
    self.m_container:retain();
    self.m_container:setNodeEventEnabled(true);


    self.m_container.onCleanup = handler(self, function(obj)
        -- 移除模态
        poker.safeRemoveNode(obj.model);

        -- 移除所有弹框
        for k, popupData in pairs(obj.m_popupStack) do
            poker.safeRemoveNode(popupData.popup);
            obj.m_popupStack[k] = nil;
            self.z_order = 2;
        end
    end)

    self.z_order = 2;
end

function PopupManager:containsPopupName(className)
    for i = 1, #self.m_popupStack do
        local item = self.m_popupStack[i];

        if item.className == className then
            return true;
        end
    end

    return false;
end

-- 添加一个弹框
function PopupManager:addPopup(param)
    local popup = param.popup;
    local customModel = param.customModel
    local isModal = param.isModal;
    local isCentered = param.isCentered;
    local closeWhenTouchModel = param.closeWhenTouchModel;
    local useShowAnimation = param.useShowAnimation;
    local touchEnabled = param.touchEnabled;
    local isShowTransBg = param.isShowTransBg;
    local isNotBackCancel = param.isNotBackCancel;
    local isNotShowZheZhao = param.isNotShowZheZhao;
    local customZheZhao = param.customZheZhao;
    local className     = param.className;
    local createTime    = param.createTime;

    if isModal == nil then isModal = true end
    if isCentered == nil then isCentered = true end

    if self:containsPopupName(className) then
        return;
    end

    if not isModal then
        closeWhenTouchModel = false;

    elseif closeWhenTouchModel == nil then
        closeWhenTouchModel = true;
    end

    local zhezhao = nil;

    -- 添加模态
    if isModal then
        poker.safeRemoveNode(self.m_modal)

        if customZheZhao then
            zhezhao = customZheZhao;
            self.m_modal = display.newScale9Sprite(customZheZhao, 0, 0, cc.size(display.width, display.height))
        else
            if not isShowTransBg then
                zhezhao = nk.Res.Common_half_tran;
                self.m_modal = display.newScale9Sprite(nk.Res.Common_half_tran, 0, 0, cc.size(display.width, display.height))
            else
                if isNotShowZheZhao then
                    zhezhao = nk.Res.Common_Blank;
                    self.m_modal = display.newScale9Sprite(nk.Res.Common_Blank, 0, 0, cc.size(display.width, display.height))
                else
                    zhezhao = nk.Res.Common_Blank_zhezhao;
                    self.m_modal = display.newScale9Sprite(nk.Res.Common_Blank_zhezhao, 0, 0, cc.size(display.width, display.height))
                end
            end
        end

        self.m_modal:pos(display.cx, display.cy);
        self.m_modal:addTo(self.m_container);

        self.m_popupTouch = poker.TouchHelper.new(self.m_modal,true,true);
        self.m_popupTouch:setOwnAudio("");
        self.m_popupTouch:setOnBeganClicked(self,self.onModalTouch);
        -- self.m_popupTouch:setTouchEnabled(false);
        popup.isPlaying = false;

        -- if isShowZheZhao then
        --     self.m_zheZhao = display.newRect(cc.rect(0, 0, display.width, display.height),{fillColor = cc.c4f(0,0,0,0.5)})
        --     self.m_modal:addChild(self.m_zheZhao);
        -- end
    end

    popup.isNotBackCancel = isNotBackCancel;

    if touchEnabled and isModal then
        -- self.m_popupTouch:setTouchEnabled(true);
    end

    -- 居中弹框
    if isCentered then
        popup:pos(display.cx, display.cy);
    end

    -- 如果有这个弹窗，先移除了
    if self:hasPopup(popup) then
        self:removePopup(popup);
    end

    table.insert(self.m_popupStack, {popup = popup, closeWhenTouchModel = closeWhenTouchModel, isModal = isModal,
                        forceUpdate = param.isForceUpdate,needRemove = param.needRemove,notShowZheZhao = isNotShowZheZhao,
                        zhezhao = zhezhao,className = className, createTime = createTime, customModel = customModel,
                        });

    self.z_order = self.z_order + 2;
    popup:setVisible(false);

    if customModel then
        customModel:addTo(self.m_container)
    end

    if param.zOrder then
        popup:addTo(self.m_container,param.zOrder);
    else
        popup:addTo(self.m_container,self.z_order);
    end


    local popupName = popup and popup.__cname or ""

    if not self.m_container:getParent() then
        if param.zOrder then
            self.m_container:addTo(display:getRunningScene(),param.zOrder);

        else
            self.m_container:addTo(display:getRunningScene(),POPUP_ORDER);

        end

    end

    if popup.onShowPopUp then
        popup:onShowPopUp();
    end
    if (not string.isEmpty(popupName)) then
        poker.EventCenter:dispatchEvent({
            name = nk.eventNames.EVT_SHOW_POPUP,
            data = {name = popupName}
        })
    end
    --TEST
    -- useShowAnimation = false;

    if useShowAnimation ~= false then
        popup:scale(0.8);

        local easeAction = cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1));
        local callFunc = cc.CallFunc:create(function()
            popup:stopAllActions();
            popup.m_isOnShowed = true;

            if self.m_modal and closeWhenTouchModel then
                self.m_popupTouch:setTouchEnabled(true);
            end

            popup.m_canRemove = true;

            popup.isPlaying = true;

            if popup.onShowEndedUp then
                popup:onShowEndedUp();
            end

            if popup.onShowed then
                popup:onShowed();
            end

        end)

        popup:setVisible(true);
        popup:runAction(cc.Sequence:create(easeAction,callFunc));


    else
        popup.isPlaying = true;
        popup:setVisible(true);
    end

    -- 更改模态的zOrder
    if isModal then
        self.m_modal:setLocalZOrder(popup:getLocalZOrder() - 1)
    end
end

function PopupManager:isNotBackCancel()
    -- 获取最上层的弹框
    local popupData = self.m_popupStack[#self.m_popupStack];

    if popupData and popupData.popup and popupData.popup.isNotBackCancel then
        return popupData.popup.isNotBackCancel;
    end

    return false;
end

function PopupManager:onModalTouch()
    if device.platform == "ios" then
        nk.ui.Loading:hide();
    end
    -- 这一块考虑到老虎机功能的特殊性，所以要单独处理，
    -- 如果可以，将老虎机用 popup 重写一下会更合理一点。
    -- 默认可以直接调用 removePopup
    local function removePopup()
        -- 获取最上层的弹框
        local popupData = self.m_popupStack[#self.m_popupStack];

        if popupData and popupData.popup and popupData.closeWhenTouchModel and
            popupData.popup.isPlaying then
            self:removePopup(popupData.popup);
        end
    end

    local banditRulePop = self.m_container:getChildByName("banditRulePop")
    if (banditRulePop and banditRulePop.isPlaying) then
        removePopup()
        return true
    else
        -- 检测老虎机界面
        local banditView = self.m_container:getChildByName("banditView")
        if (banditView) then
            return
        else
            removePopup()
        end
    end
end

-- 移除指定弹框
function PopupManager:removePopup(popup)
    if not tolua.isnull(nk.ui.Loading) and nk.ui.Loading:isVisible() then
        nk.ui.Loading:hide();
    end
    if not popup then return end

    -- 从场景移除，删除数据
    local removePopupFunc = function()
        if not popup then
            return;
        end

        if tolua.isnull(popup) then
            return;
        end

        popup:setVisible(false);
        if (popup and popup.removeAllEvent) then
            popup:removeAllEvent()
        end
        local popupName = popup and popup.__cname or ""
        self.z_order = self.z_order - 2

        poker.safeRemoveNode(popup);

        local bool, index = self:hasPopup(popup);

        local popupStack = table.remove(self.m_popupStack, index);

        if popupStack and popupStack.customModel then
            poker.safeRemoveNode(popupStack.customModel)
        end

        if (not string.isEmpty(popupName)) then
            poker.EventCenter:dispatchEvent({
                name = nk.eventNames.EVT_HIDE_POPUP,
                data = {name = popupName}
            })
        end

        if #self.m_popupStack == 0 then
            poker.safeRemoveNode(self.m_container)
        else
            -- 更改模态的zOrder
            local needModal = false
            local needZheZhao = false;

            for i = 1, #self.m_popupStack do
                if self.m_popupStack[i].isModal then
                    needModal = true;
                    break;
                end
            end

            if self.m_popupStack[#self.m_popupStack] and self.m_popupStack[#self.m_popupStack].zhezhao then
                if self.m_modal then
                    poker.safeRemoveNode(self.m_modal);
                end

                self.m_modal = display.newScale9Sprite(self.m_popupStack[#self.m_popupStack].zhezhao, 0, 0, cc.size(display.width, display.height))
                self.m_modal:pos(display.cx, display.cy);
                self.m_modal:addTo(self.m_container)
                self.m_popupTouch = poker.TouchHelper.new(self.m_modal,true,true);
                self.m_popupTouch:setOwnAudio("");
                self.m_popupTouch:setOnBeganClicked(self,self.onModalTouch);

            end

            if self.m_popupStack[#self.m_popupStack] and self.m_popupStack[#self.m_popupStack].popup and self.m_popupStack[#self.m_popupStack].popup.getLocalZOrder then
                if not tolua.isnull(self.m_modal) then
                    self.m_modal:setLocalZOrder(self.m_popupStack[#self.m_popupStack].popup:getLocalZOrder() - 1)
                end
            end

            if not needModal then
                poker.safeRemoveNode(self.m_modal)
            end
        end

    end

    if popup.removePreviousFunc then
        local flag = popup:removePreviousFunc();

        if flag then
            return;
        end
    end

    if not popup.otherRemovePopup then

        if popup.onRemovePopup then
            if nk.Native then
                if device.platform == "android" then
                    nk.Native:closeEditBox();
                end
            end

            popup:onRemovePopup();

        else
            if nk.Native then
                if device.platform == "android" then
                    nk.Native:closeEditBox();
                end
            end
        end

        removePopupFunc();

    else
        if nk.Native then
            if device.platform == "android" then
                nk.Native:closeEditBox();
            end
        end

        popup:otherRemovePopup(removePopupFunc);
    end
end

-- Determines if a popup is contained in popup stack
function PopupManager:hasPopup(popup)
    for i, popupData in ipairs(self.m_popupStack) do
        if popupData.popup == popup then
            return true, i;
        end
    end

    return false, 0;
end

--[[
    添加一个弹框(自定义位置)
]]
function PopupManager:addPopupAtPos(param)
    local popup = param.popup;
    local customModel = param.customModel
    local isModal = param.isModal;
    local isCentered = param.isCentered;
    local closeWhenTouchModel = param.closeWhenTouchModel;
    local useShowAnimation = param.useShowAnimation;
    local isShowTransBg = param.isShowTransBg;
    local isNotShowZheZhao = param.isNotShowZheZhao;
    local x = param.x;
    local y = param.y;
    local touchEnabled = param.touchEnabled;
    local className     = param.className;
    local createTime    = param.createTime;

    if self:containsPopupName(className) then
        return;
    end

    if isModal == nil then
        isModal = true;
    end

    if isCentered == nil then
        isCentered = true;
    end

    if not isModal then
        closeWhenTouchModel = false;

    elseif closeWhenTouchModel == nil then
        closeWhenTouchModel = true;
    end

    local zhezhao = nil;

    -- 添加模态
    if isModal then
        poker.safeRemoveNode(self.m_modal);


        if not isShowTransBg then
            zhezhao = nk.Res.Common_half_tran;
            self.m_modal = display.newScale9Sprite(nk.Res.Common_half_tran, 0, 0, cc.size(display.width, display.height))
        else
            if isNotShowZheZhao then
                zhezhao = nk.Res.Common_Blank;
                self.m_modal = display.newScale9Sprite(nk.Res.Common_Blank, 0, 0, cc.size(display.width, display.height))
            else
                zhezhao = nk.Res.Common_Blank_zhezhao;
                self.m_modal = display.newScale9Sprite(nk.Res.Common_Blank_zhezhao, 0, 0, cc.size(display.width, display.height))
            end
        end

        self.m_modal:pos(display.cx, display.cy);
        self.m_modal:addTo(self.m_container);

        self.m_popupTouch = poker.TouchHelper.new(self.m_modal,true,true);
        self.m_popupTouch:setOwnAudio("");
        self.m_popupTouch:setOnBeganClicked(self,self.onModalTouch);
        self.m_popupTouch:setTouchEnabled(false);

        if isShowZheZhao then
            self.m_zheZhao = display.newRect(cc.rect(0, 0, display.width, display.height),{fillColor = cc.c4f(0,0,0,0.5)})
            self.m_modal:addChild(self.m_zheZhao);
        end
    end


    popup.isPlaying = false;

    if touchEnabled and isModal then
        self.m_modal:setTouchEnabled(true);
    end

    -- print(#self.m_popupStack)
    if self.m_popupStack and #self.m_popupStack <= 0 then
        if self.m_modal and isNotShowZheZhao and not isModal then
            poker.safeRemoveNode(self.m_modal);
            self.m_modal = nil;
        end
    end

    -- 居中弹框
    if isCentered then
        popup:pos(display.cx, display.cy);

    else
        popup:pos(x, y);
    end

    -- 如果有这个弹窗，先移除了
    if self:hasPopup(popup) then
        self:removePopup(popup);
    end

    if customModel then
        customModel:addTo(self.m_container)
    end

    if param.order then
        popup:addTo(self.m_container,param.order);

    else
        popup:addTo(self.m_container,self.z_order);
    end

    local popupName = popup and popup.__cname or ""
    self.z_order = self.z_order + 2;
    popup:setVisible(false);

    if not self.m_container:getParent() then
        self.m_container:addTo(display:getRunningScene(),POPUP_ORDER);
    end

    if popup.onShowPopUp then
        popup:onShowPopUp();
    end

    if (not string.isEmpty(popupName)) then
        poker.EventCenter:dispatchEvent({
            name = nk.eventNames.EVT_SHOW_POPUP,
            data = {name = popupName}
        })
    end

    table.insert(self.m_popupStack, {popup = popup, closeWhenTouchModel = closeWhenTouchModel,
        isModal = isModal,needRemove = param.needRemove,zhezhao = zhezhao,
        className = className, createTime = createTime,customModel = customModel,
        });

    --TEST
    -- useShowAnimation = false;

    if useShowAnimation ~= false then
        popup:scale(0.8);

        local easeAction = cc.EaseBackOut:create(cc.ScaleTo:create(0.3,1));
        local callFunc = cc.CallFunc:create(function()
            popup:stopAllActions();

            if self.m_modal and closeWhenTouchModel then
                self.m_popupTouch:setTouchEnabled(true);
            end

            popup.m_canRemove = true;

            if popup.onShowed then
                popup:onShowed();
            end

            popup.isPlaying = true;
        end)

        popup:setVisible(true);
        popup:runAction(cc.Sequence:create(easeAction,callFunc));

    else
        popup:setVisible(true);
        popup.isPlaying = true;
    end
end

-- 移除所有弹框
function PopupManager:removeAllPopup(isNotNeedExecuteHallPopupFlag)
    if not tolua.isnull(nk.ui.Loading) and nk.ui.Loading:isVisible() then
        nk.ui.Loading:hide();
    end

    if #self.m_popupStack > 0 then
        for i = #self.m_popupStack,1,-1 do
            if self.m_popupStack[i] then
                local popup = self.m_popupStack[i].popup;

                 -- 从场景移除，删除数据
                local removePopupFunc = function()
                    if tolua.isnull(popup) then
                        return;
                    end
                    popup:setVisible(false);
                    if (popup and popup.removeAllEvent) then
                        popup:removeAllEvent()
                    end
                    local popupName = popup and popup.__cname or ""

                    self.z_order = self.z_order - 2
                    poker.safeRemoveNode(popup);

                    local bool, index = self:hasPopup(popup);

                    local popupStack = table.remove(self.m_popupStack, index);

                    if popupStack and popupStack.customModel then
                        poker.safeRemoveNode(popupStack.customModel)
                    end

                    if (not string.isEmpty(popupName)) then
                        poker.EventCenter:dispatchEvent({
                            name = nk.eventNames.EVT_HIDE_POPUP,
                            data = {name = popupName}
                        })
                    end
                    if #self.m_popupStack == 0 then
                        poker.safeRemoveNode(self.m_container)
                    else
                        -- 更改模态的zOrder
                        local needModal = false
                        for _,popupData in pairs(self.m_popupStack) do
                            if popupData.isModal then
                                needModal = true
                                self.m_modal:setLocalZOrder(popupData.popup:getLocalZOrder() - 1)
                                break
                            end
                        end

                        if not needModal then
                            poker.safeRemoveNode(self.m_modal)
                        end
                    end
                end

                if popup.onRemovePopup then
                    popup:onRemovePopup(isNotNeedExecuteHallPopupFlag);
                end

                if popup then
                    removePopupFunc();
                end
            end
        end
    end
end

-- Determines if a popup is the top-most pop-up.
function PopupManager:isTopLevelPopUp(popup)
    if self.m_popupStack[#self.m_popupStack].popup == popup then
        return true;
    else
        return false;
    end
end

function PopupManager:isTopLevelPop()
    if self.m_popupStack[#self.m_popupStack] then
        return true;

    else
        return false;
    end
end

function PopupManager:getTopPopup()
    if self.m_popupStack and self.m_popupStack[#self.m_popupStack] then
        return self.m_popupStack[#self.m_popupStack].popup;
    end
end

function PopupManager:isForceUpdatePopup(popup)
    if self.m_popupStack[#self.m_popupStack] and self.m_popupStack[#self.m_popupStack].forceUpdate then
        return true;
    end

    return false;
end

function PopupManager:isBackCanClosePopu(popup)
    if self.m_popupStack[#self.m_popupStack] and self.m_popupStack[#self.m_popupStack].popup.isbackCanClosePopu then
        return true;
    end
    return false;
end

function PopupManager:removeTopPopupIf()
    if #self.m_popupStack > 0 then
        local p = self.m_popupStack[#self.m_popupStack]
        -- if p.closeWhenTouchModel then
            self:removePopup(p.popup);
            return true;
        -- end
    end
    return false;
end

function PopupManager:closeAllNeedRemovePopup()
    for i = 1,#self.m_popupStack do
        if self.m_popupStack[i].needRemove then
            local popup = self.m_popupStack[i].popup;
            self:removePopup(popup,true);
        end
    end
end

function PopupManager:addBackCanClosePopu(popup,isBackCanClosePopu)
    popup.isbackCanClosePopu = isBackCanClosePopu;
end

-- 获取所有弹框的父节点
function PopupManager:getContainer()
    return self.m_container
end

-- 通过弹框名字获取弹框
-- 名字定义在 PopupConfig 里
function PopupManager:getPopup(popupName, isShow, ...)
    if (not self.m_popupConfig) then
        self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    if (table.isEmpty(self.m_popupConfig)) then return end
    if (not popupName) then return end
    local curPopupConfig = self.m_popupConfig[popupName]
    if (table.isEmpty(curPopupConfig)) then return end
    local popup
    local path  = curPopupConfig.path
    local param = pack2(...)
    local result, msg = pcall(function ()
        popup = require(path).new(unpack2(param))
        if (isShow) then
            popup:show()
        end
    end)
    if (not result) then
    end
    return popup
end

-- 通过弹框名字获取弹框类
-- 名字定义在 PopupConfig 里
function PopupManager:getPopupClass(popupName)
    if (not self.m_popupConfig) then
        self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    if (table.isEmpty(self.m_popupConfig)) then return end
    if (not popupName) then return end
    local curPopupConfig = self.m_popupConfig[popupName]
    if (table.isEmpty(curPopupConfig)) then return end
    local popupClass
    local path  = curPopupConfig.path
    local result, msg = pcall(function ()
        popupClass = require(path)
    end)
    if (not result) then
    end
    return popupClass
end

return PopupManager
