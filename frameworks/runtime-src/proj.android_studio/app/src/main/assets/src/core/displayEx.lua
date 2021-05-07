-- displayEx.lua
-- Author: Amnon
-- Date: 2018-10-12 11:07:33
-- Desc: 扩展 display.lua 用于生成常用的 UI 控件
-- Usage: display.newXxx()
--

local TAG = "displayEx"

local DEFAULT_FILE = "image/common/blank.png"

display = display or {}

-- 创建背景，自动缩放图片到全屏
function display.newBackgroud(param)
    local bg     = display.newImage(param)
    local bgSize = bg:getContentSize()
    if (table.isEmpty(bgSize)) then
        return bg
    end
    bg:scale(math.max(display.width / bgSize.width, display.height / bgSize.height))
    return bg
end

---
-- 创建自定义裁剪图片节点
-- @table param 自定义配置信息
--   @field table pos 坐标
--   @field table align 对齐方式（锚点）
--   @field userdata parent 父节点
--   @field number order Z 轴上索引
--   @field string name 节点名称
--   @field number tag 节点 tag
--   @field boolean isSwalloTouch 是否吞没事件（常跟 callback 一起使用）定义节点的触摸事件
--   @field string default 默认图片的路径
--   @field string stencil 遮罩图片的路径
--   @field string url 远程图片的地址
--   @field number height 图片要展示的高度（会等比例缩放到此高度）
--   @field number adjustType 调整坐标（左，中，右）(0,1,2)
-- @function callback 回调函数用于触发点击
function display.newClipImage(param, callback)
    local default  = param.default or DEFAULT_FILE
    local pos      = param.pos or cc.p(0, 0)
    local align    = param.align or display.CENTER
    callback = callback or param.callback
    local parent   = param.parent
    local order    = param.order or 0
    local name     = param.name
    local tag      = param.tag
    local isSwallowTouch = (param.isSwallowTouch == nil) and true or param.isSwallowTouch
    local album = nk.ui.ClipImage.new{
        default     = default,
        stencil     = param.stencil,
        url         = param.url,
        height      = param.height,
        adjustType  = param.adjustType,
    }
    album:align(align, pos.x, pos.y)
    if (callback) then
        if (isSwallowTouch) then
            setButtonEvent(album, callback, true)
        else
            setButtonEventEx(album, callback, true)
        end
    end
    if (not isCObjEmpty(parent)) then
        album:addTo(parent, order)
    else
        album:setLocalZOrder(order)
    end
    if (name) then
        album:setName(name)
    end
    if (tag) then
        album:setTag(tag)
    end
    return album
end

---
-- 创建自定义头像节点
-- @table param 自定义配置信息
--   @field table pos 坐标
--   @field table align 对齐方式（锚点）
--   @field userdata parent 父节点
--   @field number order Z 轴上索引
--   @field string name 节点名称
--   @field number tag 节点 tag
--   @field boolean isSwalloTouch 是否吞没事件（常跟 callback 一起使用）定义节点的触摸事件
--   @field string default 默认图片的路径
--   @field string stencil 遮罩图片的路径
--   @field string side 边框图片的路径
--   @field number offsetScale 边框的偏移缩放系数
--   @field number sex 性别属性(0 女 1 男 2 未知) 用于初始化使用那张默认图
--   @field string url 远程图片的地址
--   @field number height 图片要展示的高度（会等比例缩放到此高度）
-- @function callback 回调函数用于触发点击
function display.newAlbum(param, callback)
    local default  = param.default or DEFAULT_FILE
    local pos      = param.pos or cc.p(0, 0)
    local align    = param.align or display.CENTER
    callback = callback or param.callback
    local parent   = param.parent
    local order    = param.order or 0
    local name     = param.name
    local tag      = param.tag
    local isSwallowTouch = (param.isSwallowTouch == nil) and true or param.isSwallowTouch
    local album = nk.ui.CustomAlbum.new{
        default     = default,
        stencil     = param.stencil,
        side        = param.side,
        offsetScale = param.offsetScale,
        sex         = param.sex,
        url         = param.url,
        height      = param.height,
    }
    album:align(align, pos.x, pos.y)
    if (callback) then
        if (isSwallowTouch) then
            setButtonEvent(album, callback, true)
        else
            setButtonEventEx(album, callback, true)
        end
    end
    if (not isCObjEmpty(parent)) then
        album:addTo(parent, order)
    else
        album:setLocalZOrder(order)
    end
    if (name) then
        album:setName(name)
    end
    if (tag) then
        album:setTag(tag)
    end
    return album
end

-- @param
-- param = {
--     propId, 道具 ID
--     icon, 图片名字,如果有指定，则下载的地址为 url .. icon
--     default, 默认图片
--     url, 图片地址
--     height, 指定图片高度
--     callback, 点击事件
--     isSwallowTouches 是否透传点击事件
--     ... see display.newImage in displayEx.lua
-- }
function display.newPropImage(param)
    local propId   = param.propId
    local propFile = require("app.module.data.PropConfig")[tostring(propId)]
    if (propFile) then
        param.dst = "#" .. propFile
        param.url = nil
    elseif (param.icon) then
        param.url = param.url .. param.icon
    end
    return display.newUrlImage(param)
end

---
-- 更新道具图片
-- @userdata propImg 道具图片节点
-- @table param 参数同 display.newPropImage
function display.updatePropImage(propImg, param)
    -- LogUtil.d(TAG, " updatePropImage begin -------------------------- ")
    local propId   = param.propId
    local propFile = require("app.module.data.PropConfig")[tostring(propId)]
    if (propFile) then
        -- LogUtil.d(TAG, " updatePropImage propFile = ", propFile)
        propImg:setFile("#" .. propFile)
    elseif (param.icon) then
        local url = (param.url or "") .. param.icon
        -- LogUtil.d(TAG, " updatePropImage url = ", url)
        propImg:setUrl(url, true)
    end
    propImg:updateHeight(param.height)
    -- LogUtil.d(TAG, " updatePropImage end -------------------------- ")
end

-- @param param = {
--     default, 默认图片
--     url, 图片地址
--     height, 指定图片高度
--     callback, 点击事件
--     isSwallowTouches 是否透传点击事件
--     ... see display.newImage in displayEx.lua
-- }
function display.newUrlImage(param)
    return require("app.pokerUI.UrlImage").new(param)
end

function display.newImage(param)
    return display.newButton(param)
end

-- 创建 按钮也可为图片
function display.newButton(param, callback)
    if (table.isEmpty(param)) then
        param = {file = DEFAULT_FILE}
    end
    local isScale9       = param.isScale9 or false
    local file           = param.file or DEFAULT_FILE
    local pos            = param.pos or cc.p(0, 0)
    local align          = param.align or display.CENTER
    callback             = callback or param.callback
    local parent         = param.parent
    local order          = param.order or 0
    local name           = param.name
    local tag            = param.tag
    local scale          = param.scale or 1
    local isFlippedX     = param.isFlippedX or false
    local isFlippedY     = param.isFlippedY or false
    local isSwallowTouch = (param.isSwallowTouch == nil) and true or param.isSwallowTouch
    local button
    if (isScale9) then
        local rect = param.rect
        local size = param.size or cc.size(100, 100)
        button = display.newScale9Sprite(file, pos.x, pos.y, size, rect)
    else
        button = display.newSprite(file)
    end
    button:scale(scale)
    button:align(align, pos.x, pos.y)
    if (callback) then
        if (isSwallowTouch) then
            setButtonEvent(button, callback, true)
        else
            setButtonEventEx(button, callback, true)
        end
    end
    if (not isCObjEmpty(parent)) then
        button:addTo(parent, order)
    else
        button:setLocalZOrder(order)
    end
    button:setFlippedX(isFlippedX)
    button:setFlippedY(isFlippedY)
    if (name) then
        button:setName(name)
    end
    if (tag) then
        button:setTag(tag)
    end
    return button
end

-- 使用 systemFont 创建文本
function display.newLabel(param, callback)
    -- LogUtil.d(TAG, " newLabel  param = ", param)
    local str      = param.str or ""
    local font     = param.font or display.DEFAULT_TTF_FONT
    local fontSize = param.fontSize or display.DEFAULT_TTF_FONT_SIZE
    local size     = param.size or cc.size(0, 0)
    local color    = param.color or cc.c3b(255, 255, 255)
    local vAlign   = param.vAlign or cc.VERTICAL_TEXT_ALIGNMENT_CENTER
    local hAlign   = param.hAlign or cc.TEXT_ALIGNMENT_CENTER
    local align    = param.align or display.CENTER
    local isSwallowTouch = (param.isSwallowTouch == nil) and true or param.isSwallowTouch
    local pos      = param.pos or cc.p(0, 0)
    local parent   = param.parent
    local order    = param.order or 0
    local name     = param.name
    local tag      = param.tag
    callback       = callback or param.callback
    local label    = cc.Label:createWithSystemFont(str, font, fontSize, size, hAlign, vAlign)
    label:setTextColor(color)
    label:setPosition(pos.x, pos.y)
    label:setAnchorPoint(display.ANCHOR_POINTS[align])
    if (callback) then
        if (isSwallowTouch) then
            setButtonEvent(label, callback, true, false, true)
        else
            setButtonEventEx(label, callback, true, false, true)
        end
    end
    if (not isCObjEmpty(parent)) then
        label:addTo(parent, order)
    else
        label:setLocalZOrder(order)
    end
    if (name) then
        label:setName(name)
    end
    if (tag) then
        label:setTag(tag)
    end
    return label, label:getContentSize()
end

-- 创建 gaf 节点
function display.newGafNode(param, callback)
    local file        = param.file
    LogUtil.d(TAG, "newGafNode file = ", file)
    if ((not cc.FileUtils:getInstance():isFileExist(file)) or (not string.endsWith(file, ".gaf"))
        or (not gaf)) then
        LogUtil.d(TAG, "newGafNode file is not exist or not support gaf")
        return
    end
    local parent      = param.parent
    local order       = param.order or 0
    local isStart     = param.isStart or false
    local isLoop      = param.isLoop or false
    local recursive   = param.recursive or false
    local size        = param.size
    local pos         = param.pos or cc.p(0, 0)
    callback    = callback or param.callback
    local name        = param.name
    local tag         = param.tag
    local gafAssets   = gaf.GAFAsset:create(file)
    local gafObject   = gafAssets:createObject()
    gafObject:setLooped(isLoop,recursive)
    if (isStart) then
        gafObject:start()
    end
    if (callback) then
        local parentNode = display.newNode()
            :pos(pos.x, pos.y)
        local touchNode = display.newNode()
        if (parent) then
            parentNode:addTo(parent, order)
        else
            parentNode:setLocalZOrder(order)
        end
        if (not size) then
            local gafContentSize = gafObject:getContentSize()
            touchNode:setContentSize(size)
        else
            touchNode:setContentSize(size)
        end
        parentNode:setCascadeOpacityEnabled(true)
        gafObject:setCascadeOpacityEnabled(true)
        gafObject:addTo(parentNode)
        if (name) then
            gafObject:setName(name)
            parentNode:setName(name)
        end
        if (tag) then
            gafObject:setTag(tag)
            parentNode:setTag(tag)
        end
        local touchSize = touchNode:getContentSize()
        touchNode:pos(-touchSize.width / 2, -touchSize.height / 2)
        touchNode:addTo(parentNode)
        setButtonEvent(touchNode, callback, true, nil, nil, gafObject)
        return parentNode, gafObject
    else
        if (parent) then
            gafObject:addTo(parent, order)
        else
            gafObject:setLocalZOrder(order)
        end
        gafObject:setPosition(pos.x, pos.y)
        if (name) then
            gafObject:setName(name)
        end
        if (tag) then
            gafObject:setTag(tag)
        end
        return gafObject
    end
end

---
-- 显示小 loading 默认是可点击，居中的 loading
-- 全局不可点击（ loading 本身是有问题的存在，按理应该可以控制的）
function display.showLoading (param)
    if (not nk or not nk.ui or not nk.ui.Loading) then
        return
    end
    if table.isEmpty(param) then
        param = {}
    end
    local isSwallowTouch = param.isSwallowTouch and true or false
    local x              = param.x or  display.cx
    local y              = param.y or display.cy
    local parent         = param.scene
    local isNotNeedBg    = param.isNotNeedBg or false
    local needReturn     = param.needReturn or false
    nk.ui.Loading:show(isSwallowTouch, x, y, parent, isNotNeedBg, needReturn)
end

---
-- 隐藏小 loading
function display.hideLoading ()
    if (not nk or not nk.ui or not nk.ui.Loading) then
        return
    end
    nk.ui.Loading:hide()
end

---
-- 创建小 loading 默认是可点击，居中的 loading
function display.newSmallLoading (param)
    if (not nk or not nk.ui or not nk.ui.SmallLoading) then
        return
    end
    if table.isEmpty(param) then
        param = {}
    end
    -- LogUtil.d(TAG, "newSmallLoading param = ", param)
    local isSwallowTouch = param.isSwallowTouch and true or false
    local x              = param.x or display.cx
    local y              = param.y or display.cy
    local parent         = param.parent or display.getRunningScene()
    local zOrder         = param.zOrder or 1001
    local isShow         = param.isShow and true or false
    local node = nk.ui.SmallLoading.new()
    node:createLoading(isSwallowTouch, x, y)
    node:addTo(parent, zOrder)
    if (isShow) then
        node:show()
    end
    return node
end

-- 从设计上，应该把这个放到 app 下，而不是放在 core 里，目前暂时放在这里，以后再移植到其他地方去
---
-- 创建网络超时布局
function display.newTimeOutView (param, callback)
    local parent = param.parent
    local node = display.newNode()
    if (not isCObjEmpty(parent)) then
        node:addTo(parent)
    end
    local msg = param.msg or {}
    if (not table.isEmpty(msg)) then
        local msgLab = display.newLabel({
            str      = poker.LangUtil:getText("HTTP", "REQUEST_ERROR"),
            pos      = msg.pos or cc.p(0, 50),
            color    = msg.color or cc.c3b(255, 255, 255),
            fontSize = msg.fontSize,
            parent   = node
        })
    end
    local retry = param.retry or {}
    if (not table.isEmpty(retry)) then
        local retryBtn = display.newButton({
            file   = retry.file or nk.Res.Common_btn_2_big,
            pos    = retry.pos or cc.p(0, -20),
            parent = node
        }, callback)
        local retryLabConf = retry.lab or {}
        local retryLab = display.newLabel({
            str      = poker.LangUtil:getText("HTTP", "RETRY"),
            pos      = retryLabConf.pos or cc.p(0, -20),
            color    = retryLabConf.color or cc.c3b(255, 255, 255),
            fontSize = msg.fontSize,
            parent   = node
        })
    end
    return node
end

function display.drawSelector(radius, params)
    params = checktable(params)

    local function makeVertexs(radius)
        local segments = params.segments or 32
        local startRadian = 0
        local endRadian = math.pi * 2
        local posX = params.x or 0
        local posY = params.y or 0
        if params.startAngle then
            startRadian = math.angle2radian(params.startAngle)
        end
        if params.endAngle then
            endRadian = startRadian + math.angle2radian(params.endAngle)
        end
        local radianPerSegm = 2 * math.pi / segments
        local points = {}
        for i = 1, segments do
            local radii = startRadian + i * radianPerSegm
            if radii > endRadian then break end
            points[#points + 1] = {posX + radius * math.cos(radii), posY + radius * math.sin(radii)}
        end
        return points
    end

    local points = makeVertexs(radius)
    local circle = display.newPolygon(points, params)
    if circle then
        circle.radius = radius
        circle.params = params

        function circle:setRadius(radius)
            self:clear()
            local points = makeVertexs(radius)
            display.newPolygon(points, params, self)
        end

        function circle:setLineColor(color)
            self:clear()
            local points = makeVertexs(radius)
            params.borderColor = color
            display.newPolygon(points, params, self)
        end
    end
    return circle
end 

---
-- 创建数字图片
-- @param table 创建数字图片的参数
-- @callback function 回调方法
function display.newNumberImage(param, callback)
    local file           = param.file
    assert(file, "display.newNumberImage error file is empty")
    local pos            = param.pos or cc.p(0, 0)
    local align          = param.align or display.CENTER
    callback             = callback or param.callback
    local parent         = param.parent
    local order          = param.order or 0
    local name           = param.name
    local scale          = param.scale
    local tag            = param.tag
    local anchorPoint    = param.anchorPoint
    -- 是否吞没事件（透传）
    local isSwallowTouch = (param.isSwallowTouch == nil) and true or param.isSwallowTouch
    local node
    node = nk.ui.NumberImage.new(file)
    node:align(align, pos.x, pos.y)
    if (callback) then
        if (isSwallowTouch) then
            setButtonEvent(node, callback, true)
        else
            setButtonEventEx(node, callback, true)
        end
    end
    if (not isCObjEmpty(parent)) then
        node:addTo(parent, order)
    else
        node:setLocalZOrder(order)
    end
    if (scale) then
        node:scale(scale)
    end
    if (name) then
        node:setName(name)
    end
    if (tag) then
        node:setTag(tag)
    end
    return node
end