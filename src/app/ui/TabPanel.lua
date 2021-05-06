--[[
    Class Name          : TabPanel
    description         : 切换列表页面基类.
    author              : ClarkWu
]]
local Panel         = require("app.pokerUI.Panel")

local M = class("TabPanel", Panel)

-- 定义类型
M.STYLE_SMALL  = 1
M.STYLE_MID    = 2
M.STYLE_BIG    = 3
M.STYLE_CUSTOM = 4

--[[
    @Constructor
    @param style Number     - 界面类型
                 M.STYLE_BIG - 大界面     M.STYLE_MID - 中界面      M.STYLE_CUSTOM - 自定义
    @param titleParam Table - 标题数组
    @param customBg String  - 个性化背景
    @param titleBg  String  - 标题背景
    @param size Array - 尺寸
    @param notSpecialTab
    create-author       : ClarkWu
]]
function M:ctor(style, titleParam, customBg, titleBg, size, notSpecialTab)
    LogUtil.d(self.__cname, "ctor ")
    self.m_eventTag    = getGIndex()
    self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    local bgConfig     = self.m_popupConfig.POPUP_BG
    local bg           = bgConfig[style] or customBg
    local bgSize = size and cc.size(size[1], size[2]) or nil
    self.m_backGround = display.newImage({
        file     = bg or bgConfig[M.STYLE_BIG],
        isScale9 = bgSize and true or false,
        size     = bgSize,
        parent   = self,
    })
    self.m_backGround:setTouchEnabled(true)
    self.m_backGround:setTouchSwallowEnabled(true)

    self.m_width  = self.m_backGround:getContentSize().width
    self.m_height = self.m_backGround:getContentSize().height

    -- 加载自定义标题节点
    local titleConfig = self.m_popupConfig.TAB_PANEL_TITLE_CONFIG
    if (titleConfig and titleConfig.custom and titleConfig.path) then
        local CustomView = require(titleConfig.path)
        if (CustomView) then
            self.m_backGround:addChild(CustomView.new(self))
        end
    else
        self:initTitle(titleConfig, {titleBg = titleBg})
    end

    self.m_titleParam = titleParam
    self.m_style      = style

    -- 加载自定义标题节点
    local toolbarConfig = self.m_popupConfig.TAB_PANEL_TOOLBAR_CONFIG
    if not table.isEmpty(toolbarConfig) then
        if (toolbarConfig.custom and toolbarConfig.path) then
            local CustomView = require(toolbarConfig.path)
            if (CustomView) then
                self.m_backGround:addChild(CustomView.new(self))
            end
        else
            self:initToolbar(toolbarConfig, {notSpecialTab = notSpecialTab, titleParam = titleParam})
        end
    end

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

-- 初始化标题
function M:initTitle(config, param)
    if (table.isEmpty(config)) then return end
    local titleBg        = param and param.titleBg or nil
    local curPopupConfig = self.m_popupConfig[self.__cname] or {}
    -- 是否有菜单背景
    config = curPopupConfig.tBg and curPopupConfig or config
    -- config = curPopupConfig and curPopupConfig or config

    local tempConfig = config.tBg
    local pos
    if (not table.isEmpty(tempConfig)) then
        self:initTitleWithStar(config, titleBg)
    else
        if self.m_style == M.STYLE_CUSTOM then
            if titleBg then
                tempConfig = config.customTitleBg
                pos        = tempConfig.pos and tempConfig.pos
                    or cc.p(self.m_width / 2 + (tempConfig.offsetX or 0), self.m_height + (tempConfig.offsetY or 0))
                self.m_titleBg = display.newImage({
                    file   = titleBg,
                    pos    = pos,
                    parent = self.m_backGround
                })
                self.m_backGround:pos(0, -20)
            end
        else
            tempConfig = config.titleBg
            pos        = tempConfig.pos and tempConfig.pos
                or cc.p(self.m_width / 2 + (tempConfig.offsetX or 0), self.m_height + (tempConfig.offsetY or 0))
            self.m_titleBg = display.newImage({
                file   = tempConfig.file,
                pos    = pos,
                parent = self.m_backGround
            })
        end
    end
end

-- 初始化菜单栏
function M:initToolbar(config, param)
    local toolbarType = config.toolbarType
    if (toolbarType == 1) then
        self:initClickToolbar(config, param)
    elseif (toolbarType == 2) then
        self:initSlideToolbar(config, param)

    elseif toolbarType == 3 then
        self:initCustomToolBar(config, param)
    end
end

-- title with star begin
function M:initTitleWithStar(config, titleBg)
    if (not titleBg) then
        return
    end

    local tempConfig = config.tBg
    local pos     = tempConfig.pos and tempConfig.pos
        or cc.p(self.m_width / 2 + (tempConfig.offsetX or 0), self.m_height + (tempConfig.offsetY or 0))
    self.m_tBg = display.newImage({
        file   = titleBg,
        pos    = pos,
        parent = self.m_backGround
    })

    tempConfig = config.starLeft
    if tempConfig then
        pos = tempConfig.pos and tempConfig.pos or cc.p(self:getLeftStarPosition())
        self.m_titleLeftStar = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_tBg,
        })
    end

    tempConfig    = config.starRight
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getRightStarPosition())
        self.m_titleRightStar = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_tBg,
        })
    end

    tempConfig    = config.light1
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getLightStar1Position())
        self.m_lightStar1 = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_tBg,
        })
    end

    tempConfig    = config.light2
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getLightStar2Position())
        self.m_lightStar2 = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_tBg,
        })
    end
    self:playTitleStar1()
    self:playTitleStar2()
end

function M:getLeftStarPosition()
    return self.m_tBg:getContentSize().width / 2 - 40, self.m_tBg:getContentSize().height - 10
end

function M:getRightStarPosition()
    return self.m_tBg:getContentSize().width / 2 + 130, self.m_tBg:getContentSize().height - 10
end

function M:getLightStar1Position()
    return 33, 46
end

function M:getLightStar2Position()
    return 158, 20
end

function M:playTitleStar1()
    if self.m_lightStar1 then
        self.m_lightStar1:scale(0.4)
        local fadeInAction = cc.FadeIn:create(0.6)
        local rotateByAction = cc.RotateBy:create(0.6,30)
        local scaleToAction = cc.ScaleTo:create(0.6,1.1)
        self.m_lightStar1:runAction(cc.Sequence:create(fadeInAction, cc.CallFunc:create(function()
            if self.m_lightStar1 then
                local fadeOutAction = cc.FadeOut:create(0.6)
                local scaleToAction = cc.ScaleTo:create(0.6,0.4)
                self.m_lightStar1:runAction(cc.Sequence:create(fadeOutAction, cc.DelayTime:create(0.4),cc.CallFunc:create(function()
                    self:playTitleStar1()
                end)))
                self.m_lightStar1:runAction(scaleToAction)
            end
        end)))
        self.m_lightStar1:runAction(rotateByAction)
        self.m_lightStar1:runAction(scaleToAction)
    end
end

function M:playTitleStar2()
    if self.m_lightStar2 then
        self.m_lightStar2:scale(0.4)
        local fadeInAction = cc.FadeIn:create(0.7)
        local rotateByAction = cc.RotateBy:create(0.7,30)
        local scaleToAction = cc.ScaleTo:create(0.7,1.1)
        self.m_lightStar2:runAction(cc.Sequence:create(fadeInAction, cc.CallFunc:create(function()
            if self.m_lightStar2 then
                local fadeOutAction = cc.FadeOut:create(0.7)
                local scaleToAction = cc.ScaleTo:create(0.7,0.4)
                self.m_lightStar2:runAction(cc.Sequence:create(fadeOutAction, cc.DelayTime:create(0.7),cc.CallFunc:create(function()
                    self:playTitleStar2()
                end)))
                self.m_lightStar2:runAction(scaleToAction)
            end
        end)))
        self.m_lightStar2:runAction(rotateByAction)
        self.m_lightStar2:runAction(scaleToAction)
    end
end
-- title with star end

-- 初始化菜单栏
-- 目前代码实现的有两套，如果有其他的可以额外扩展

-- 初始化标题菜单栏
function M:initClickToolbar(config, param)
    self.m_tabTitlePanel = display.newNode()
        :addTo(self.m_backGround)
    if (table.isEmpty(self.m_titleParam)) then
        return
    end
    if (table.isEmpty(param)) then
        param = {}
    end
    local notSpecialTab  = param.notSpecialTab
    self.m_titleBtn      = {}
    local titleParam     = self.m_titleParam
    local style          = self.m_style
    local labelConfig    = config.label
    local titleCount     = #titleParam
    local btnConfig      = titleCount <= 3 and config.three or config.four

    for i = 1, titleCount do
        local res = btnConfig[2]
        if i == 1 then
            res = btnConfig[1]
        elseif i == titleCount then
            res = btnConfig[3]
        end
        local sprite = display.newSprite(res.normal)
        local spriteWidth = sprite:getContentSize().width
        res.noAnim = true
        self.m_titleBtn[i] = nk.ui.Button.new(res)
                        :onButtonClicked(function(event)
                            self:gotoTab(i)
                        end)
                        :setButtonLabelOffset(0,0)
                        :addTo(self.m_tabTitlePanel)
        local height = self.m_height * 0.87
        if style == M.STYLE_CUSTOM then
            height = notSpecialTab and self.m_height * 0.885 or self.m_height * 0.90
        end
        if titleCount == 3 then
            self.m_titleBtn[i]:pos(self.m_width/2 + (i - 2 ) * spriteWidth - (2.5 * (i - 1)), height)
        elseif titleCount == 2 then
            self.m_titleBtn[i]:pos(self.m_width/2 + (i - 1.5) * spriteWidth - (2.5 * (i - 1)), height)
        elseif titleCount == 4 then
            self.m_titleBtn[i]:pos(self.m_width/2 + (i - 2 ) * (spriteWidth - 2) - 80, self.m_height * 0.90)
        end
        local btnLabelName = "titleBtn" .. i
        local btnLabel     = self.m_tabTitlePanel:getChildByName(btnLabelName)
        if (btnLabel) then
            btnLabel:setString(self.m_titleParam[i])
        else
            btnLabel = cc.Label:createWithSystemFont(self.m_titleParam[i] or "", display.DEFAULT_TTF_FONT, labelConfig.fontSize)
            btnLabel:addTo(self.m_tabTitlePanel, 2)
            btnLabel:setName(btnLabelName)
        end
        btnLabel:pos(self.m_titleBtn[i]:getPosition())
    end
end

-- 点击滑动的菜单栏
function M:initSlideToolbar(config, param)
    if (table.isEmpty(self.m_titleParam)) then
        return
    end
    local titleParam = self.m_titleParam
    local nodeConfig = config.titleBg or {}
    local pos        = nodeConfig.pos and nodeConfig.pos
        or cc.p(self.m_width / 2 + (nodeConfig.offsetX or 0), self.m_height + (nodeConfig.offsetY or 0))
    local titleFile  = nodeConfig.file
    if (nodeConfig.t_file and #titleParam == 3) then
        titleFile = nodeConfig.t_file
    end

    if (not self.m_titleBg) then
        local titleSize = cc.size(nodeConfig.oneWidth * #titleParam, nodeConfig.height);
        if config.selectBtnFour and #titleParam == 4 then
            titleSize = cc.size(config.selectBtnFour.oneWidth * #titleParam, config.selectBtnFour.height);
        end

        self.m_titleBg = display.newImage({
            file     = titleFile,
            isScale9 = nodeConfig.isScale9,
            size     = titleSize,
            pos      = pos,
            parent   = self.m_backGround
        })
        self.m_tabTitlePanel = display.newNode()
            :addTo(self.m_titleBg)
    end
    self.m_titleBtn                 = {}
    self.m_titleContent             = {}
    self.m_titleContentShadow       = {}
    self.m_titleSelect              = {}
    self.m_curSelectePosition       = {}
    local style                     = self.m_style
    local spriteWidth, spriteHeight = 0, 0
    nodeConfig                      = (#titleParam == 3 and config.selectBtnThree) and config.selectBtnThree or config.selectBtn
    local offsetY                   = nodeConfig.offsetY or 0
    if config.selectBtnFour and #titleParam == 4 then
        nodeConfig = config.selectBtnFour
        offsetY = nodeConfig.offsetY or 0;
    end
    local startX                    = nodeConfig.startX or 0
    local offsetW                   = nodeConfig.offsetW or 0
    self.m_tabTitleBg               = display.newSprite(nodeConfig.file)
    spriteWidth                     = self.m_tabTitleBg:getContentSize().width + offsetW
    spriteHeight                    = self.m_tabTitleBg:getContentSize().height
    self.m_tabTitleBg:pos(startX + (1 - 0.5) * spriteWidth, spriteHeight / 2 + 3 + offsetY)
                    :addTo(self.m_tabTitlePanel)
    nodeConfig = config.label
    for i = 1, #titleParam do
        self.m_titleContentShadow[i] = cc.ui.UILabel.new({ UILabelType = 2, text = titleParam[i] , size = nodeConfig.fontSize, color = nodeConfig.shadowColor})
            :addTo(self.m_tabTitlePanel)
        self.m_titleContent[i] = cc.ui.UILabel.new({ UILabelType = 2, text = titleParam[i] , size = nodeConfig.fontSize, color = nodeConfig.selectColor})
            :addTo(self.m_tabTitlePanel)
        if nodeConfig.initColor then
            self.m_titleContent[i]:setColor(nodeConfig.initColor)
        else
            self.m_titleContent[i]:setColor(nodeConfig.normalColor)
        end
        self.m_titleContent[i]:pos(startX + (i - 0.5)* spriteWidth - self.m_titleContent[i]:getContentSize().width/2, spriteHeight/ 2 + offsetY + 4)
        self.m_titleContentShadow[i]:pos(startX + (i - 0.5) * spriteWidth - self.m_titleContent[i]:getContentSize().width/2, spriteHeight/2 - 1 + offsetY + 4)
        self.m_titleSelect[i] = display.newNode()
                                :align(display.LEFT_CENTER, startX + (i - 1) * spriteWidth - 10, spriteHeight / 2 + 10 + offsetY)
                                :addTo(self.m_tabTitlePanel)
        self.m_titleSelect[i]:setContentSize(spriteWidth + 18, 20 + spriteHeight)
        setButtonEvent(self.m_titleSelect[i], function()
            self:changeTab(i)
        end)
        local curItemPosition = cc.p(startX + (i - 0.5) * spriteWidth, spriteHeight / 2 + 3 + offsetY)
        self.m_curSelectePosition[#self.m_curSelectePosition + 1] = curItemPosition
    end
end

-- 自定义菜单项
function M:initCustomToolBar(config, param)
    self.m_titleSelect    = {};
    self.m_tabTransBg     = {};
    self.m_tabTouchHelper = {};
    self.m_titleContent   = {};

    if (table.isEmpty(self.m_titleParam)) then
        return
    end

    local titleParam = self.m_titleParam
    local tabBgConfig = config.tab_bg or {};
    local labelConfig = config.label or {};

    if not self.m_tabTitleBg then
        if tabBgConfig.file then
            self.m_tabTitleBg = display.newImage({
                file = tabBgConfig.file,
                isScale9 = true,
                size = cc.size(tabBgConfig.oneWidth * #titleParam, tabBgConfig.height),
                pos = cc.p(self.m_width/2 + tabBgConfig.offsetX, self.m_height + tabBgConfig.offsetY),
                parent = self.m_backGround
            })
        end
    end

    if #titleParam <= 3 then
        if config.three then
            for i = 1, #titleParam do
                local file,pos,selectFile,selectPos;
                if i == 1 then
                    file = config.three.left.transBg;
                    selectFile = config.three.left.pressed;
                    pos = cc.p(config.three.x + config.three.distant3 * (i - 1), config.three.y)
                    selectPos = cc.p(config.three.selectX + config.three.selectDistant3 * (i - 1), config.three.selectY)
                elseif i == 2 then
                    if #titleParam == 2 then
                        file = config.three.right.transBg;
                        selectFile = config.three.right.pressed;
                        pos = cc.p(config.three.x + config.three.distant2 * (i - 1), config.three.y)
                        selectPos = cc.p(config.three.selectX + config.three.selectDistant2 * (i - 1), config.three.selectY)
                    else
                        file = config.three.mid.transBg;
                        selectFile = config.three.mid.pressed;
                        pos = cc.p(config.three.x + config.three.distant3 * (i - 1), config.three.y)
                        selectPos = cc.p(config.three.selectX + config.three.selectDistant3 * (i - 1), config.three.selectY)
                    end

                elseif i == 3 then
                    file = config.three.right.transBg;
                    selectFile = config.three.right.pressed;
                    pos = cc.p(config.three.x + config.three.distant3 * (i - 1), config.three.y)
                    selectPos = cc.p(config.three.selectX + config.three.selectDistant3 * (i - 1), config.three.selectY)
                end

                self.m_tabTransBg[i] = display.newImage({
                    file = file,
                    isScale9 = false,
                    pos = pos,
                    parent = self.m_tabTitleBg,
                })

                self.m_titleSelect[i] = display.newImage({
                    file = selectFile,
                    isScale9 = false,
                    pos = selectPos,
                    parent = self.m_tabTitleBg,
                })

                self.m_titleSelect[i]:hide();

                self.m_titleContent[i] = cc.ui.UILabel.new({
                                            UILabelType = 2,
                                            text = titleParam[i],
                                            size = labelConfig.fontSize,
                                            color = labelConfig.selectColor
                                        })
                                        :addTo(self.m_tabTitleBg)

            self.m_titleContent[i]:setColor(labelConfig.normalColor)
            self.m_titleContent[i]:pos(pos.x - self.m_titleContent[i]:getContentSize().width/2, pos.y)

                self.m_tabTouchHelper[i] = poker.TouchHelper.new(self.m_tabTransBg[i], true, true)
                self.m_tabTouchHelper[i]:setOnEndedClicked(nil, function()
                    self:gotoTab(i)
                end)
            end
        end

    elseif #titleParam == 4 then
        if config.four then
            if self.m_tabTitleBg then
                self.m_tabTitleBg:setContentSize(tabBgConfig.oneWidth * #titleParam, tabBgConfig.height - 6);
            end

            for i = 1, #titleParam do
                local transFile, selectFile,transPos,selectPos;
                if i == 1 then
                    selectFile = config.four.left.pressed;
                    transFile = config.four.left.transBg;
                    selectPos = cc.p(config.four.selectX + config.four.selectDistant * (i - 1), config.four.selectY)
                    transPos = cc.p(config.four.x + config.four.transDistant * (i - 1), config.four.y)

                elseif i <= 3 then
                    selectFile = config.four.mid.pressed;
                    transFile = config.four.mid.transBg;
                    selectPos = cc.p(config.four.selectX + config.four.selectDistant * (i - 1), config.four.selectY)
                    transPos = cc.p(config.four.x + config.four.transDistant * (i - 1), config.four.y)

                    if i == 3 then
                        selectPos = cc.p(config.four.selectX + config.four.selectDistant * (i - 1), config.four.selectY)
                        transPos = cc.p(config.four.x + config.four.transDistant * (i - 1) - 2, config.four.y)
                    end


                elseif i == 4 then
                    selectFile = config.four.right.pressed;
                    transFile = config.four.right.transBg;
                    selectPos = cc.p(config.four.selectX + config.four.selectDistant * (i - 1), config.four.selectY)
                    transPos = cc.p(config.four.x + config.four.transDistant * (i - 1) - 2, config.four.y)
                end

                self.m_tabTransBg[i] = display.newImage({
                    file = transFile,
                    isScale9 = false,
                    pos = transPos,
                    parent = self.m_tabTitleBg,
                })

                self.m_titleSelect[i] = display.newImage({
                    file = selectFile,
                    isScale9 = false,
                    pos = selectPos,
                    parent = self.m_tabTitleBg,
                })

                self.m_titleSelect[i]:hide();

                self.m_titleContent[i] = cc.ui.UILabel.new({
                                            UILabelType = 2,
                                            text = titleParam[i],
                                            size = labelConfig.fontSize,
                                            color = labelConfig.selectColor
                                        })
                                        :addTo(self.m_tabTitleBg)

                self.m_titleContent[i]:setColor(labelConfig.normalColor)
                self.m_titleContent[i]:pos(transPos.x - self.m_titleContent[i]:getContentSize().width/2, transPos.y)

                self.m_tabTouchHelper[i] = poker.TouchHelper.new(self.m_tabTransBg[i], true, true)
                self.m_tabTouchHelper[i]:setOnEndedClicked(nil, function()
                    self:gotoTab(i)
                end)
            end

        end
    end
end

-- 滑块式菜单栏会调用
function M:changeTab(tab, otherParam)
    if tab == self.m_currentTab then
        return
    end
    local labelConfig = self.m_popupConfig.TAB_PANEL_TOOLBAR_CONFIG.label
    self.m_currentTab = tab
    if self.m_tabTitleBg then
        local position = self.m_curSelectePosition[tab]
        self.m_tabTitleBg:stopAllActions()
        self.m_tabTitleBg:runAction(
            transition.sequence({
                cc.MoveTo:create(0.2, cc.p(position.x, position.y)),
                cc.CallFunc:create(function()
                    if self.m_titleContent then
                        for i = 1, #self.m_titleContent do
                            self.m_titleContent[i]:setColor(self.m_currentTab ~= i and labelConfig.normalColor or labelConfig.selectColor)
                        end
                    end
                end)
            })
        )
        if self.m_callBack and self.m_obj then
            self.m_callBack(self.m_obj, tab, otherParam)
        end
    end
    return self
end

--- Theme Slide end --

--[[
    设置某个选项卡被点中之后的响应方法
    @param obj  object      - 那个对象
    @param objFunc function - 那个对象的方法
    create-author       : ClarkWu
]]
function M:onTabChange(obj,objFunc)
    self.m_callBack = objFunc
    self.m_obj = obj
    return self
end

--[[
    跳转到第几个tab页方法
    @param tab  Number - 第几个Tab标签
    create-author       : ClarkWu
    last-modified-author: ClarkWu
    create-date         : 2016/09/01
    last-modified-date  : 2016/10/09
    点击菜单栏会调用
]]
function M:gotoTab(tab, otherParam)
    local labelConfig = self.m_popupConfig.TAB_PANEL_TOOLBAR_CONFIG.label
    if self.m_titleContent then
        for i = 1, #self.m_titleSelect do
            if self.m_titleSelect[i] then
                self.m_titleSelect[i]:hide();
            end

            self.m_tabTouchHelper[i]:setTouchEnabled(true)
        end

        if self.m_titleSelect[tab] then
            self.m_titleSelect[tab]:show();
            self.m_tabTouchHelper[tab]:setTouchEnabled(false)
        end

        for i = 1, #self.m_titleContent do
            if self.m_titleContent[i] then
                if i == tab then
                    self.m_titleContent[i]:setColor(labelConfig.selectColor)

                else
                    self.m_titleContent[i]:setColor(labelConfig.normalColor)
                end
            end
        end

    elseif self.m_titleBtn then
        if #self.m_titleBtn <= 4 then
            for i = 1, #self.m_titleBtn do
                local btnLabelName = "titleBtn" .. i
                local btnLabel     = self.m_tabTitlePanel:getChildByName(btnLabelName)
                if (btnLabel) then
                    btnLabel:setString(self.m_titleParam[i])
                else
                    btnLabel = cc.Label:createWithSystemFont(self.m_titleParam[i] or "", display.DEFAULT_TTF_FONT, labelConfig.fontSize)
                    btnLabel:addTo(self.m_tabTitlePanel, 2)
                    btnLabel:setName(btnLabelName)
                end
                btnLabel:pos(self.m_titleBtn[i]:getPosition())
                if (self.m_titleBtn[i]) then
                    self.m_titleBtn[i]:setButtonEnabled(i ~= tab and true or false)
                end
                if (btnLabel) then
                    btnLabel:setColor(i ~= tab and labelConfig.normalColor or labelConfig.selectColor)
                end
            end
        end
    end

    if self.m_callBack and self.m_obj then
        self.m_callBack(self.m_obj, tab)
    end
    return self
end

--[[
    添加关闭按钮方法
    create-author       : ClarkWu
]]
function M:addCloseBtn(param)
    if (self.m_closeBtn) then
        return
    end
    if (table.isEmpty(param)) then param = {} end
    local customPos   = param.pos
    local file        = nk.Res.Common_closeBtn
    local pos         = customPos or cc.p(self.m_width / 2 - 32, self.m_height / 2 - 77)
    local closeConfig = self.m_popupConfig and self.m_popupConfig.TAB_PANEL_CLOSE_CONFIG or {}
    if (not table.isEmpty(closeConfig)) then
        file = closeConfig.file or file
        pos  = customPos and customPos or (closeConfig.pos or cc.p(self.m_width / 2 + (closeConfig.offsetX or 0), self.m_height / 2 + (closeConfig.offsetY or 0)))
    end
    self.m_closeBtn = display.newButton({
        file     = file,
        parent   = self,
        order    = 99,
        pos      = pos,
    },function ( ... )
        self:hidePanel_()
    end)
end

function M:getConfig()
    return self.m_config;
end

return M
