--[[
    Class Name          : Panel
    description         : 弹框基类.
    author              : ClarkWu
]]
local TAG   = "Panel"
local Panel = class("Panel", function()
    return display.newNode()
end)

--[[
    @Constructor
    @param size    Table  - 宽(size.w),高(size.h)
    @param popupbg String - 弹窗背景
    create-author       : ClarkWu
]]
function Panel:ctor(size, popupbg)
    LogUtil.d(self.__cname, "ctor ")
    self.m_eventTag    = getGIndex()
    self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    local bgSize       = size and cc.size(size[1], size[2]) or nil
    self.m_backGround = display.newImage({
        file     = popupbg or nk.Res.Common_Blank,
        isScale9 = bgSize and true or false,
        size     = bgSize,
        parent   = self,
    })

    self.m_backGround:setTouchEnabled(true)
    self.m_backGround:setTouchSwallowEnabled(true)

    local popBgSize = self.m_backGround:getContentSize()
    self.m_width, self.m_height = popBgSize.width, popBgSize.height

    -- self.m_backGround = display.newScale9Sprite(popupbg or nk.Res.Common_Blank, 0, 0, cc.size(self.m_width, self.m_height))
    --                         :addTo(self)
    self.m_isOnShowed = false
    -- 加载弹框内容节点
    local contentConfig = self.m_popupConfig[self.__cname]
    if (contentConfig and contentConfig.custom and contentConfig.path) then
        local CustomView = require(contentConfig.path)
        if (CustomView) then
            self.m_backGround:addChild(CustomView.new(self))
        end
    else
        self:initContent()
    end
end

---
-- 初始化内容 接口方法，当自定义内容的时候，由子类自己实现该方法
function Panel:initContent( ... )
    -- body
end

function Panel:showListViewBugRightRemove()
    self.m_blankRightNode = display.newScale9Sprite( nk.Res.Common_Blank, self.m_width/2 + 135, 0, cc.size(315, display.height))
                               :addTo(self)
    self.m_blankRightNode:setTouchEnabled(true)

    self.m_blankRightNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
        self:hide()
    end)
end

function Panel:showListViewBugUpRemove()
    self.m_blankUpNode = display.newScale9Sprite( nk.Res.Common_Blank, 0 , self.m_height/2 - 10, cc.size(display.width, self.m_height/2))
                            :addTo(self,1000)
    self.m_blankUpNode:setAnchorPoint(0.5,0)
    self.m_blankUpNode:setTouchEnabled(true)

    self.m_blankUpNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
        self:hide()
    end)
end

function Panel:showListViewBugDownRemove()
    self.m_blankDownNode = display.newScale9Sprite( nk.Res.Common_Blank, 0 ,-self.m_height/2+10, cc.size(display.width,display.height/2-self.m_height/2 + 80))
                                :addTo(self)
    self.m_blankDownNode:setAnchorPoint(0.5,1)
    self.m_blankDownNode:setTouchEnabled(true)

    self.m_blankDownNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
        self:hide()
    end)
end

--[[
    添加关闭按钮方法
    create-author       : ClarkWu
]]
function Panel:addCloseBtn()
    if not self.m_closeBtn then
        local file        = nk.Res.Common_closeBtn
        local pos         = cc.p(self.m_width / 2 - 37, self.m_height / 2 - 36)
        local closeConfig = self.m_popupConfig and self.m_popupConfig.PANEL_CLOSE_CONFIG or {}
        if (not table.isEmpty(closeConfig)) then
            file = closeConfig.file or file
            pos  = closeConfig.pos or cc.p(self.m_width / 2 + (closeConfig.offsetX or 0), self.m_height / 2 + (closeConfig.offsetY or 0))
        end
        self.m_closeBtn = display.newButton({
            file     = file,
            parent   = self,
            order    = 99,
            pos      = pos,
        },function ( ... )
            self:hide()
        end)
    end
end

--[[
    显示界面
    create-author       : ClarkWu
]]
function Panel:showPanel_(param)
    local className = nil

    if type(self) == "userdata" then
        local popup = tolua.getpeer(self)
        if popup then
            className = popup.__cname
        end
    end

    nk.PopupManager:addPopup{
        popup               = self,
        isModal             = param.isModal ~= false,
        isCentered          = param.isCentered ~= false,
        closeWhenTouchModel = param.closeWhenTouchModel ~= false,
        useShowAnimation    = param.useShowAnimation ~= false,
        isShowTransBg       = param.isShowTransBg ~= false,
        touchEnabled        = param.touchEnabled ~= false,
        isForceUpdate       = param.isForceUpdate,
        needRemove          = param.needRemove,
        isNotShowZheZhao    = param.isNotShowZheZhao,
        zOrder              = param.zOrder,
        isNotBackCancel     = param.isNotBackCancel,
        customZheZhao       = param.customZheZhao,
        className           = className,
        createTime          = cc.net.SocketTCP:getTime(),
        customModel         = param.customModel,
    }
    return self
end

--[[
    显示界面在具体某个位置
    create-author       : ClarkWu
]]
function Panel:showPanelAtPos_(param)
    local className = nil

    if type(self) == "userdata" then
        local popup = tolua.getpeer(self)
        if popup then
            className = popup.__cname
        end
    end

    nk.PopupManager:addPopupAtPos{
        popup               = self,
        isModal             = param.isModal ~= false,
        isCentered          = param.isCentered ~= false,
        closeWhenTouchModel = param.closeWhenTouchModel ~= false,
        useShowAnimation    = param.useShowAnimation ~= false,
        isShowTransBg       = param.isShowTransBg ~= false,
        touchEnabled        = param.touchEnabled ~= false,
        isForceUpdate       = param.isForceUpdate,
        isNotShowZheZhao    = param.isNotShowZheZhao,
        needRemove          = param.needRemove,
        x                   = param.x,
        y                   = param.y,
        customZheZhao       = param.customZheZhao,
        createTime          = cc.net.SocketTCP:getTime(),
        className           = className,
        customModel         = param.customModel,
        order               = param.tag,
    }
    return self
end

function Panel:showSpecialPanel(panelId)

end

--[[
    隐藏界面
    create-author       : ClarkWu
]]
function Panel:hidePanel_()
    nk.PopupManager:removePopup(self)
    return self
end

function Panel:onRemovePopup()
end

-- 只在有定义弹框的时候调用
-- 读取的默认路径为 XXXPopup.file
function Panel:addSpriteFrames(popupName)
    if (not self.m_popupConfig) then
        self.m_popupConfig      = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    local curPopupConfig  = self.m_popupConfig and self.m_popupConfig[popupName] or {}
    self.m_curPopupConfig = curPopupConfig
    if (not table.isEmpty(curPopupConfig)) then
        local fileList = curPopupConfig.file
        if (not table.isEmpty(fileList)) then
            for i = 1, #fileList do
                display.addSpriteFrames(unpack(fileList[i]))
            end
        end
    end
end

function Panel:addAllSpriteFrames(popupName)
    if not self.m_popupConfig then
        self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    local curPopupConfig = self.m_popupConfig and self.m_popupConfig[popupName] or {}
    self.m_curPopupConfig = curPopupConfig
    if not table.isEmpty(curPopupConfig) then
        local ret,msg = pcall(function()
            self.m_config = require(self.m_curPopupConfig.config)
        end)

        print(ret, msg)
        if not ret or not self.m_config then
            error("Please add the config for this popup")
            return
        end

        if self.m_config.normal then
            display.addSpriteFrames(unpack( self.m_config.normal))
        end

        if self.m_config.lang then
            display.addSpriteFrames(unpack(self.m_config.lang))
        end
    end
end

function Panel:removeSpriteFrames(popupName)
    if (not self.m_popupConfig) then
        self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    local curPopupConfig   = self.m_popupConfig and self.m_popupConfig[popupName] or {}
    if (not table.isEmpty(curPopupConfig)) then
        local fileList = curPopupConfig.file
        if (not table.isEmpty(fileList)) then
            for i = 1, #fileList do
                display.removeSpriteFramesWithFile(unpack(fileList[i]))
            end
        end
    end
end

function Panel:removeAllSpriteFrames(popupName)
    if not self.m_popupConfig then
        self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    end
    local curPopupConfig = self.m_popupConfig and self.m_popupConfig[popupName] or {}
    self.m_curPopupConfig = curPopupConfig
    if not table.isEmpty(curPopupConfig) then
        local ret,msg = pcall(function()
            self.m_config = require(self.m_curPopupConfig.config)
        end)

        if not ret or not self.m_config then
            error("Please add the config for this popup")
            return
        end

        if  self.m_config.normal then
            display.removeSpriteFramesWithFile(unpack(self.m_config.normal))
        end

        if self.m_config.lang then
            display.removeSpriteFramesWithFile(unpack(self.m_config.lang))
        end
    end
end

function Panel:setDecorate()
    local config     = self.m_popupConfig.PANEL_DECORATE_CONFIG
    if (table.isEmpty(config)) then
        return
    end
    local nodeConfig = config.upLeft

    if not self.m_decorateUpLeft then
        self.m_decorateUpLeft = display.newSprite(nodeConfig.file)
        self.m_decorateUpLeft:pos(nodeConfig.offsetX,self.m_height + nodeConfig.offsetY)
        self.m_decorateUpLeft:addTo(self.m_backGround, nodeConfig.order)
        self.m_decorateUpLeft:setFlippedX(nodeConfig.isFlippedX)
    end
    self.m_decorateUpLeft:show()

    nodeConfig = config.upRight
    if not self.m_decorateUpRight then
        self.m_decorateUpRight = display.newSprite(nodeConfig.file)
        self.m_decorateUpRight:pos(self.m_width + nodeConfig.offsetX,self.m_height + nodeConfig.offsetY)
        self.m_decorateUpRight:addTo(self.m_backGround, nodeConfig.order)
    end
    self.m_decorateUpRight:show()

    nodeConfig = config.downLeft
    if not self.m_decorateDownLeft then
        self.m_decorateDownLeft = display.newSprite(nodeConfig.file)
        self.m_decorateDownLeft:pos(-self.m_width/2 + nodeConfig.offsetX,-self.m_height/2 + nodeConfig.offsetY)
        self.m_decorateDownLeft:setFlippedX(nodeConfig.isFlippedX)
        self.m_decorateDownLeft:addTo(self, nodeConfig.order)
    end
    self.m_decorateDownLeft:show()

    nodeConfig = config.downRight
    if not self.m_decorateDownRight then
        self.m_decorateDownRight = display.newSprite(nodeConfig.file)
        self.m_decorateDownRight:pos(self.m_width/2 + nodeConfig.offsetX,-self.m_height/2 + nodeConfig.offsetY)
        self.m_decorateDownRight:addTo(self, nodeConfig.order)
    end

    self.m_decorateDownRight:show()
end

function Panel:hideDecorate()
    if self.m_decorateUpLeft then
        self.m_decorateUpLeft:hide()
    end

    if self.m_decorateUpRight then
        self.m_decorateUpRight:hide()
    end

    if self.m_decorateDownLeft then
        self.m_decorateDownLeft:hide()
    end

    if self.m_decorateDownRight then
        self.m_decorateDownRight:hide()
    end
end

function Panel:getConfig()
    return self.m_config
end

---
-- 添加事件响应
function Panel:addEvent (eventName, func)
    LogUtil.d(self.__cname, "addEvent eventName = ", eventName, " tag = ", self.m_eventTag)
    if ((not eventName) or (not func) or (not self.m_eventTag)) then return end
    poker.EventCenter:addEventListener(eventName, func, self.m_eventTag)
end

---
-- 移除所有事件，由 PopupManager 移除的时候一起移除
function Panel:removeAllEvent ()
    LogUtil.d(self.__cname, "removeAllEvent tag = ", self.m_eventTag)
    if (not self.m_eventTag) then
        return
    end
    poker.EventCenter:removeEventListenersByTag(self.m_eventTag)
end

---
-- 通过事件名字移除事件
function Panel:removeEventByName (eventName)
    LogUtil.d(self.__cname, "removeAllEvent eventName = ", eventName)
    if (string.isEmpty(eventName)) then return end
    poker.EventCenter:removeEventListenersByEvent(eventName)
end

return Panel
