--[[
    Class Name          : NormalPanel
    description         : 普通界面.
    author              : ClarkWu
]]
local TAG   = "NormalPanel"
local Panel = require("app.pokerUI.Panel")
local M     = class(TAG, Panel)

-- 定义类型
M.STYLE_SMALL        = 1    -- 小界面
M.STYLE_MID          = 2    -- 中界面
M.STYLE_BIG          = 3    -- 大界面
M.STYLE_CUSTOM       = 4    -- 自定义

M.STYLE_NO_TAB_BIG   = 3    -- 无切换大界面
M.STYLE_NO_TAB_MID   = 2    -- 无切换中界面
M.STYLE_NO_TAB_SMALL = 1    -- 无切换小界面

function M:ctor(style, title, bgName, titleFile, size)
    LogUtil.d(self.__cname, "ctor ")
    self.m_eventTag    = getGIndex()
    self.m_style       = style
    self.m_popupConfig = nk.PlatformFactory:getCurPlatform():getPopupConfig()
    local bgConfig     = self.m_popupConfig.POPUP_BG
    local bg           = bgConfig[style] or bgName
    bg = bg or bgConfig[M.STYLE_BIG]

    -- todo remove the code begin
    if (titleFile and type(titleFile) == "table") then
        titleFile = titleFile.titleRes
    end
    -- todo remove the code end
    local bgSize = size and cc.size(size[1], size[2]) or nil
    self.m_backGround = display.newImage({
        file     = bg,
        isScale9 = bgSize and true or false,
        size     = bgSize,
        parent   = self,
    })
    self.m_backGround:setTouchEnabled(true)
    self.m_backGround:setTouchSwallowEnabled(true)
    self.m_width  = self.m_backGround:getContentSize().width
    self.m_height = self.m_backGround:getContentSize().height

    -- 加载自定义标题节点
    local titleConfig = self.m_popupConfig.NORMAL_PANEL_TITLE_CONFIG
    -- LogUtil.d(TAG, "titleConfig = ", titleConfig)
    if (titleConfig and titleConfig.custom and titleConfig.path) then
        local CustomView = require(titleConfig.path)
        if (CustomView) then
            self.m_backGround:addChild(CustomView.new(self))
        end
    else
        self:initTitle(titleConfig, {titleFile = titleFile, title = title})
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

function M:initTitle(config, param)
    if (table.isEmpty(config)) then
        return
    end
    local curPopupConfig = self.m_popupConfig[self.__cname] or {}
    local title     = param.title
    local titleFile = param.titleFile
    local titleBgConfig = curPopupConfig.titleBg and curPopupConfig.titleBg or config.titleBg
    if (not table.isEmpty(titleBgConfig)) then
        local titlePos      = titleBgConfig.pos
            or cc.p(self.m_width / 2 + (titleBgConfig.offsetX or 0), self.m_height + (titleBgConfig.offsetY or 0))
        self.m_titleBg = display.newImage({
            file   = titleBgConfig.file,
            pos    = titlePos,
            parent = self.m_backGround,
        })
    end
    if (title and string.len(title) > 0) then
        local titleLabelConfig = curPopupConfig.titleLabel and curPopupConfig.titleLabel or config.titleLabel
        local titlePos = titleLabelConfig.pos
            or cc.p(self.m_width / 2 + (titleLabelConfig.offsetX or 0), self.m_height + (titleLabelConfig.offsetY or 0))
        display.newLabel({
            str      = title,
            fontSize = titleLabelConfig.fontSize or 35,
            parent   = self.m_backGround,
            pos      = titlePos,
            color    = titleLabelConfig.color,
        })
    elseif (titleFile) then
        local titleImageConfig   = curPopupConfig.titleImage and curPopupConfig.titleImage or config.titleImage
        local titleImagePos      = titleImageConfig.pos
            or cc.p(self.m_width / 2 + (titleImageConfig.offsetX or 0), self.m_height + (titleImageConfig.offsetY or 0))
        local titleImage = display.newImage({
            file = titleFile,
            pos  = titleImagePos,
        })
        if (self.m_titleBg) then
            self.m_title = titleImage
            self.m_title:pos(self.m_titleBg:getContentSize().width / 2 + (titleImageConfig.offsetX or 0), self.m_titleBg:getContentSize().height / 2 - self.m_title:getContentSize().height / 2 + (titleImageConfig.offsetY or 0))
            self.m_title:addTo(self.m_titleBg)
        else
            self.m_titleBg = titleImage
            self.m_titleBg:addTo(self.m_backGround)
        end
    end

    -- 因为是配套的，所以就不一一判断了

    -- 这里需要就加，不需要就不加，使用注释掉的代码，如果不想要还取消不了
    -- config = config.starLeft and curPopupConfig or config
    config = curPopupConfig and curPopupConfig or config
    local tempConfig = config.starLeft
    local pos
    if tempConfig then
        pos            = tempConfig.pos and tempConfig.pos or cc.p(self:getLeftStarPosition())
        self.m_titleLeftStar = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_titleBg,
        })
    end

    tempConfig    = config.starRight
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getRightStarPosition())
        self.m_titleRightStar = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_titleBg,
        })
    end

    tempConfig    = config.light1
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getLightStar1Position())
        self.m_lightStar1 = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_titleBg,
        })
        self:playTitleStar1()
    end

    tempConfig    = config.light2
    if tempConfig then
        pos           = tempConfig.pos and tempConfig.pos or cc.p(self:getLightStar2Position())
        self.m_lightStar2 = display.newImage({
            file   = tempConfig.file,
            pos    = pos,
            parent = self.m_titleBg,
        })
        self:playTitleStar2()
    end
end

-- add this code for style 2 begin

function M:addOtherBgPanel()

end

function M:getLeftStarPosition()
    return 75, self.m_titleBg:getContentSize().height - 15
end

function M:getRightStarPosition()
    return self.m_titleBg:getContentSize().width, self.m_titleBg:getContentSize().height - 15
end

function M:getLightStar1Position()
    return 50, 65
end

function M:getLightStar2Position()
    return 141, 31
end

function M:setDecorate()
    local decorateConfig = self.m_popupConfig.NORMAL_PANEL_DECORATE_CONFIG
    if (decorateConfig and decorateConfig.callSuper) then
        M.super.setDecorate(self)
        return
    end
    if self.m_lightStar1 then
        self.m_lightStar1:stopAllActions()
        self.m_lightStar1:hide()
    end

    if self.m_lightStar2 then
        self.m_lightStar2:stopAllActions()
        self.m_lightStar2:hide()
    end

    if self.m_titleLeftStar then
        self.m_titleLeftStar:hide()
    end

    if self.m_titleRightStar then
        self.m_titleRightStar:hide()
    end

    local config = self.m_popupConfig[self.__cname] and self.m_popupConfig[self.__cname]
            or self.m_popupConfig.NORMAL_PANEL_TITLE_CONFIG
    local nodeConfig

    if self.m_titleBg  then
        nodeConfig = config.titleImage
        if (nodeConfig) then
            local titlePos = nodeConfig.pos
                or cc.p(self.m_width / 2 + (nodeConfig.offsetX or 0), self.m_height + (nodeConfig.offsetY or 0) - 8)
            self.m_titleBg:pos(titlePos.x, titlePos.y)
        end
    end

    if (not self.m_titleLeftDecorate) then
        nodeConfig = config.decorateLeft
        if (nodeConfig) then
            self.m_titleLeftDecorate = display.newImage({
                file   = nodeConfig.file,
                pos    = nodeConfig.pos or cc.p(0, 0),
                parent = self.m_titleBg,
            })
            self.m_titleLeftDecorate:setFlippedX(nodeConfig.isFlippedX and true or false)
        end
    end

    if (not self.m_titleRightDecorate) then
        nodeConfig = config.decorateRight
        if (nodeConfig) then
            local pos  = nodeConfig.pos and nodeConfig.pos
                or cc.p(self.m_titleBg:getContentSize().width + (nodeConfig.offsetX or 0), nodeConfig.offsetY or 0)
            self.m_titleRightDecorate = display.newImage({
                file   = nodeConfig.file,
                pos    = pos,
                parent = self.m_titleBg,
            })
            self.m_titleRightDecorate:setFlippedX(nodeConfig.isFlippedX and true or false)
        end
    end
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

--
--[[
    添加关闭按钮方法
    create-author       : ClarkWu
]]
function M:addCloseBtn()
    if not self.m_closeBtn then
        local file        = nk.Res.Common_closeBtn
        local pos         = cc.p(self.m_width / 2 - 32, self.m_height / 2 - 57)
        local closeConfig = self.m_popupConfig and self.m_popupConfig.NORMAL_PANEL_CLOSE_CONFIG or {}
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
            self:hidePanel_()
        end)
    end
end

function M:showCloseBtn(param)
    if (isCObjEmpty(self.m_closeBtn)) then
        self:addCloseBtn()
    end
    local pos = param.pos
    if (pos) then
        self.m_closeBtn:pos(pos.x, pos.y)
    end
end

return M
