-- CustomAlbum.lua
-- Author: Amnon
-- Date: 2018-07-31 17:14:47
-- Desc:
-- Usage:
--

local Downloader = require("app.util.Downloader")
local TAG        = "CustomAlbum"

local M = class(TAG, function ( ... )
    return display.newNode()
end)

function M:ctor(param)
    -- LogUtil.d(TAG, "ctor param = ", param)
    self.m_param = param
    if (string.isUrl(param.url)) then
        param.dst = self:isImageExist(param.url)
        if (not param.dst) then
            self:setUrl(param.url)
        end
        if param.sex then
            param.default = (tonumber(param.sex) == 1) and nk.Res.Common_default_man or nk.Res.Common_default_woman
        end
    elseif param.sex then
        param.dst = (tonumber(param.sex) == 1) and nk.Res.Common_default_man or nk.Res.Common_default_woman
    end
    local file = param.dst or param.default
    if (param.stencil) then
        local content
        self.m_clippingNode, content = self:createClipImage(file, param.stencil)
        self.m_album = content
        self.m_clippingNode:addTo(self)
    else
        local tempSprite = display.newSprite(file)
        if (tempSprite) then
            tempSprite:addTo(self)
            self.m_album     = tempSprite
            self.m_albumSize = tempSprite:getContentSize()
        end
    end
    if (param.side) then
        local sideSprite = display.newSprite(param.side)
            :addTo(self)
        local sideSize = sideSprite:getContentSize()
        if (not table.isEmpty(sideSize) and not table.isEmpty(self.m_albumSize)) then
            -- LogUtil.d(TAG, " sideSize = ", sideSize, " self.m_albumSize = ", self.m_albumSize)
            local offsetScale = param.offsetScale or 0.04
            sideSprite:scale(self.m_albumSize.height / sideSize.height + offsetScale)
        end
        self.m_albumSide = sideSprite;
    end
    if (param.height and not table.isEmpty(self.m_albumSize)) then
        self:scale(param.height / self.m_albumSize.height)
    end
    if (param.onClick) then
        if (param.isSwallowTouches) then
            setButtonEventEx(self, function ( ... )
                self.m_param.onClick(param.mid, param.sex)
            end)
        else
            setButtonEvent(self, function ( ... )
                self.m_param.onClick(param.mid, param.sex)
            end)
        end
    end
end

function M:getClippingNode()
    return self.m_clippingNode;
end

function M:createClipImage(default, stencil)
    local stencil = display.newSprite(stencil)
    local clipper = cc.ClippingNode:create()
    clipper:setStencil(stencil)  -- 设置裁剪模板
    clipper:setAlphaThreshold(0) -- 设置绘制底板的Alpha值为0
    local content = display.newSprite(default) -- 被裁剪的内容
    content:setCascadeOpacityEnabled(true)
    clipper:addChild(content)
    clipper:setCascadeOpacityEnabled(true)
    local stencilSize = stencil:getContentSize()
    local contentSize = content:getContentSize()
    content:scale(stencilSize.height / contentSize.height)
    self.m_albumSize  = stencilSize
    return clipper, content
end

function M:isImageExist(url)
    local filePath = Downloader.DEFAULT_TMP_DIR .. crypto.md5(url)
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local tex
        local ret, msg = pcall(function ( ... )
            tex = cc.Director:getInstance():getTextureCache():addImage(filePath)
        end)
        if (not tex) then
            cc.FileUtils:getInstance():removeFile(filePath)
            return false
        end
        return filePath
    end
end

-- 设置地址
function M:setUrl(url, sex, isReset)
    -- LogUtil.d(TAG, "setUrl url = ", url, " sex = ", sex)
    -- if (not self.m_smallLoading) then
    --     self.m_smallLoading = nk.ui.SmallLoading.new()
    --     self.m_smallLoading:createLoading(nil,0,0)
    --     self.m_smallLoading:addTo(self, 99)
    --     self.m_smallLoading:hide()
    -- end
    self.m_url = url or ""
    self.m_param.url = self.m_url or ""
    if (sex) then
        self.m_param.sex = tonumber(sex)
    end
    if (isReset) then
        if (self.m_downloader) then
            self.m_downloader:reset()
        end
        if (string.isUrl(self.m_url)) then
            self:setFile((self.m_param.sex == 1) and nk.Res.Common_default_man or nk.Res.Common_default_woman)
        end
    end
    if (string.isUrl(self.m_url)) then
        local filePath = self:isImageExist(self.m_url)
        if filePath then
            self:setFile(filePath)
            return
        end
        -- self.m_smallLoading:show()
        if (not self.m_downloaderCallback) then
            self.m_downloaderCallback = handlerEx(self, self.onDownloadCallback)
        end
        if (not self.m_downloader) then
            self.m_downloader = Downloader.new(self.m_url, self.m_downloaderCallback)
        else
            self.m_downloader:startByNewUrl(self.m_url, self.m_downloaderCallback)
        end
    else
        self:setFile((self.m_param.sex == 1) and nk.Res.Common_default_man or nk.Res.Common_default_woman)
    end
end

function M:setFile(fileName)
    -- LogUtil.d(TAG, "setFile fileName = ", fileName)
    if (not string.len(fileName)) then
        return
    end
    local isSpriteFrame = false
    if string.byte(fileName) == 35 then -- first char is #
        isSpriteFrame = true
    end
    if (isSpriteFrame) then
        if (self.m_album and not tolua.isnull(self.m_album)) then
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.sub(fileName, 2))
            if (frame) then
                self.m_album:setSpriteFrame(frame)
            else
                LogUtil.d(TAG, " invalid fileName = ", fileName)
            end
        end
        return
    end
    local tex
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        pcall(function ( ... )
            tex = cc.Director:getInstance():getTextureCache():addImage(fileName)
        end)
        if (tex) then
            self:onDownloadCallback(tex)
        else
            LogUtil.d(TAG, " texture not found invalid fileName = ", fileName)
        end
    else
        LogUtil.d(TAG, "file is not found")
    end
end

function M:setSideFile(fileName, scale)
    -- LogUtil.d(TAG, "setSideFile fileName = ", fileName, scale)
    if not fileName or (not string.len(fileName)) then
        return
    end
    local isSpriteFrame = false
    if string.byte(fileName) == 35 then -- first char is #
        isSpriteFrame = true
    end
    if (isSpriteFrame) then
        if (self.m_albumSide and not tolua.isnull(self.m_albumSide)) then
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(string.sub(fileName, 2))
            if (frame) then
                self.m_albumSide:setSpriteFrame(string.sub(fileName, 2))
            else
                LogUtil.d(TAG, " invalid fileName = ", fileName)
            end

            if scale then
                 self.m_albumSide:scale(self.m_albumSide:getContentSize().height / self.m_albumSide:getContentSize().height + scale)
            end
        end
        return
    end
    local tex
    if cc.FileUtils:getInstance():isFileExist(fileName) then
        tex = cc.Director:getInstance():getTextureCache():addImage(fileName)
        if (tex) then
            self.m_albumSide:setTexture(fileName)
        else
            LogUtil.d(TAG, " texture not found invalid fileName = ", fileName)
        end

        if scale then
            self.m_albumSide:scale(self.m_albumSide:getContentSize().height / self.m_albumSide:getContentSize().height + scale)
        end
    else
        LogUtil.d(TAG, "file is not found")
    end
end

-- 下载回调
function M:onDownloadCallback(texture)
    -- LogUtil.d(TAG, "onDownloadCallback self.m_url = ", self.m_url)
    -- if (self.m_smallLoading and not tolua.isnull(self.m_smallLoading)) then
    --     self.m_smallLoading:hide()
    -- end
    if (self.m_album and not tolua.isnull(self.m_album) and texture) then
        self.m_album:setTexture(texture)
    end
end

function M:dispose()
    if (self.m_downloader and self.m_url and self.m_downloaderCallback) then
        self.m_downloader:cancelByUrl(self.m_url, self.m_downloaderCallback)
    end
end

function M:setClickedTouchEnabled(enabledFlag)
    if enabledFlag then
        if (self.m_param.onClick) then
            if (self.m_param.isSwallowTouches) then
                setButtonEventEx(self, function ( ... )
                    self.m_param.onClick(self.m_param.mid, self.m_param.sex)
                end)
            else
                setButtonEvent(self, function ( ... )
                    self.m_param.onClick(self.m_param.mid, self.m_param.sex)
                end)
            end

            self:setTouchEnabled(true)
        end

    else
        self:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
        self:setTouchEnabled(false)
    end
end

return M