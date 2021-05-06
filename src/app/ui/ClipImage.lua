---
-- 裁剪图片类，用于创建裁剪的图片，支持远程下载、本地图片裁剪
-- ClipImage.lua
-- Author: Amnon
-- Date: 2020-03-17 11:43:45
-- Desc:
-- Usage:
--

local Downloader = require("app.util.Downloader")
local TAG        = "ClipImage"
local M = class(TAG, function ( ... )
    return display.newNode()
end)

-- 调整坐标类型
M.ADJUST_POST_YPE = {
    LEFT   = 0,
    CENTER = 1,
    RIGHT  = 2,
}

function M:ctor(param)
    -- LogUtil.d(TAG, "ctor param = ", param, " anchor = ", self:getAnchorPoint())
    self.m_param = param
    if (string.isUrl(param.url)) then
        param.dst = self:isImageExist(param.url)
        -- LogUtil.d(TAG, "isImageExist param.dst = ", param.dst)
        if (not param.dst) then
            self:setUrl(param.url)
        end
    end
    local file = param.dst or param.default
    if (param.stencil) then
        local content
        self.m_clippingNode, content = self:createClipImage(file, param.stencil)
        self.m_album = content
        self.m_contentSize = content:getContentSize()
        self.m_clippingNode:addTo(self)
    else
        local tempSprite = display.newSprite(file)
        if (tempSprite) then
            tempSprite:addTo(self)
            self.m_album     = tempSprite
            self.m_albumSize = tempSprite:getContentSize()
        end
    end

    if (param.height and not table.isEmpty(self.m_albumSize)) then
        self:scale(param.height / self.m_albumSize.height)
    end
    self:setAnchorPoint(cc.p(1, 1))
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
    self.m_adjustPosType = param.adjustType or M.ADJUST_POST_YPE.CENTER

end

---
-- 是否在图片下载完成后调整坐标
function M:setAdjustPosType (adjustType)
    self.m_adjustPosType = adjustType or M.ADJUST_POST_YPE.CENTER
end

---
-- 获取蒙版的尺寸大小
function M:getImageSize ()
    return self.m_albumSize
end

---
-- 获取缩放后内容的尺寸
function M:getScaleContentSize ()
    local scale = self.m_album:getScale()
    LogUtil.d(TAG, "getScaleContentSize scale = ", scale)
    return cc.size(self.m_contentSize.width * scale, self.m_contentSize.height * scale)
end

function M:getClippingNode()
    return self.m_clippingNode
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
    -- LogUtil.d(TAG, "createClipImage stencilSize = ", stencilSize, " contentSize = ", contentSize)
    content:scale(stencilSize.height / contentSize.height)
    self.m_albumSize  = stencilSize
    -- LogUtil.d(TAG, "createClipImage self.m_albumSize = ", self.m_albumSize)
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
function M:setUrl(url, isReset)
    -- LogUtil.d(TAG, "setUrl url = ", url, " sex = ", sex)
    -- if (not self.m_smallLoading) then
    --     self.m_smallLoading = nk.ui.SmallLoading.new()
    --     self.m_smallLoading:createLoading(nil,0,0)
    --     self.m_smallLoading:addTo(self, 99)
    --     self.m_smallLoading:hide()
    -- end
    self.m_url = url or ""
    self.m_param.url = self.m_url or ""
    if (isReset) then
        if (self.m_downloader) then
            self.m_downloader:reset()
        end
        if (string.isUrl(self.m_url)) then
            self:setFile(self.m_param.default)
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
        self:setFile(self.m_param.default)
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
            self:onDownloadCallback(tex, true)
        else
            LogUtil.d(TAG, " texture not found invalid fileName = ", fileName)
        end
    else
        LogUtil.d(TAG, "file is not found")
    end
end

-- 下载回调
function M:onDownloadCallback(texture, isSkipAdjust)
    -- LogUtil.d(TAG, "onDownloadCallback self.m_url = ", self.m_url)
    -- if (self.m_smallLoading and not tolua.isnull(self.m_smallLoading)) then
    --     self.m_smallLoading:hide()
    -- end

    if (self.m_album and not tolua.isnull(self.m_album) and texture) then
        local newContentSize = texture:getContentSize()
        -- self.m_album:setScale(1)
        self.m_album:setTexture(texture)
        self.m_album:setTextureRect(cc.rect(0, 0, newContentSize.width, newContentSize.height))
        self.m_album:setScale(self.m_albumSize.height / newContentSize.height)
        self.m_contentSize = self.m_album:getContentSize()
        if ((self.m_adjustPosType == M.ADJUST_POST_YPE.CENTER) or isSkipAdjust) then
            return
        end
        -- 这是一个特殊的需求，如果没必要还是不要这么处理，或者说这个控件需要优化，可以根据显示内容自适应他的图片位置
        -- 而且还影响了在它后面的节点
        local posX, posY = self:getPosition()
        local scaleSize = self:getScaleContentSize()
        -- LogUtil.d(TAG, "onDownloadCallback scaleSize = ", scaleSize,
        --     " self.m_albumSize = ", self.m_albumSize, " posX = ", posX)
        if (self.m_albumSize.width > scaleSize.width) then
            local offsetX = (self.m_albumSize.width - scaleSize.width) / 2
            local isLeft = self.m_adjustPosType == M.ADJUST_POST_YPE.LEFT
            posX = isLeft and (posX - offsetX) or (posX + offsetX)
            -- LogUtil.d(TAG, "onDownloadCallback offsetX = ", offsetX, " posX = ", posX)
            self:pos(posX, posY)
            if (self.m_groupNode) then
                local nodePosX, nodePosY = self.m_groupNode:getPosition()
                nodePosX = nodePosX + offsetX * 2
                self.m_groupNode:pos(nodePosX, nodePosY)
            end
        end
    end
end

---
-- 设置同组的节点
function M:setGroupNode(node)
    self.m_groupNode = node
end

function M:dispose()
    if (self.m_downloader and self.m_url and self.m_downloaderCallback) then
        self.m_downloader:cancelByUrl(self.m_url, self.m_downloaderCallback)
    end
end

return M
