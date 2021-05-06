--[[
    Class Name          : DJListView
    description         : 自定义ListView基类.
    author              : ClarkWu
]]
local DJListView = class("DJListView", cc.ui.UIListView)

function DJListView:ctor(params)
    DJListView.super.ctor(self, params)

    self.m_isNeedAutoHeight = params.needAutoHeight;
    -- 只在异步加载中使用
    -- 已经加载过节点集合（记录坐标和大小）
    self.m_loadedItemsConf = {}
end

function DJListView:setNeedAutoHeight(autoHeight)
    self.m_isNeedAutoHeight = autoHeight or 0;
end

--[[
    @Override
    @param event userData - 事件
    create-author       : ClarkWu
]]
function DJListView:onTouch_(event)
    if #self.items_ <= 0 then
        return false;
    end

    if not self.m_canMoveFlag then
        local w = 0;
        local h = 0;

        for k,v in pairs(self.items_) do
            local tempW,tempH = v:getItemSize();
            w = w + tempW;
            h = h + tempH;
        end

        -- 没有填满显示区域不允许滑动
        if "moved" == event.name then
            if DJListView.super.DIRECTION_VERTICAL == self.direction then
                if self.viewRect_.height >= h then
                    return false
                end
            else
                if self.viewRect_.width >= w then
                    return false
                end
            end
        end
    end

    if "began" == event.name and not self:isTouchInViewRect(event) then
        return false;
    end

    if "began" == event.name and self.touchOnContent then
        local cascadeBound = self.scrollNode:getCascadeBoundingBox();

        if not cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y)) then
            return false;
        end
    end

    if "began" == event.name then
        self.m_elasticFlag = false;
        self.m_refreshViewNum = nil;

        self.m_touchListFlag = true;
        self.prevX_ = event.x;
        self.prevY_ = event.y;
        self.bDrag_ = false;
        local x,y = self.scrollNode:getPosition();
        self.position_ = {x = x, y = y};

        transition.stopTarget(self.scrollNode);
        self:callListener_{name = "began", x = event.x, y = event.y}

        self:enableScrollBar();

        self.scaleToWorldSpace_ = self:scaleToParent_();
        return true;

    elseif "moved" == event.name then
        if self:isShake(event) then
            return;
        end

        self.bDrag_ = true;
        self.speed.x = event.x - event.prevX;
        self.speed.y = event.y - event.prevY;

        if self.direction == DJListView.super.DIRECTION_VERTICAL then
            self.speed.x = 0;

        elseif self.direction == DJListView.super.DIRECTION_HORIZONTAL then
            self.speed.y = 0;
        end

        self:scrollBy(self.speed.x, self.speed.y);

        self:callListener_{name = "moved", x = event.x, y = event.y}

        self:isShowTop();
        self:isShowBottom();

    elseif "ended" == event.name then
        self.m_touchListFlag = false;
        if self.bDrag_ then
            self.bDrag_ = false;
            self:scrollAuto();
            self:callListener_{name = "ended", x = event.x, y = event.y}
            self:disableScrollBar();
        else
            self:callListener_{name = "clicked", x = event.x, y = event.y}
        end
-- local bound = self.scrollNode:getCascadeBoundingBox()
-- dump(bound)

--  local itemSize = {};
--      for i,v in ipairs(self.items_) do
--          local posX, posY = v:getPosition()
--           itemSize.w,itemSize.h = v:getItemSize()
--      end
-- dump(itemSize)
    end
end

function DJListView:isShowBottom()
    local x , y = self.container:getPosition();

    if self.delegate_[DJListView.DELEGATE] then
        local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)
        local item = self.items_[1];
        local itemSizeW,itemSizeH = item:getItemSize();
        local totalHeight = itemSizeH * count;
        if y > totalHeight + 50 then
            if self.m_scrollToEndFunc then
                self.m_scrollToEndFunc(self.m_scrollToEndObj);
            end
        end
    end
end

function DJListView:setScrollToEndFunc(callObj, callFunc)
    self.m_scrollToEndFunc = callFunc;
    self.m_scrollToEndObj = callObj;
end

function DJListView:isShowTop()
    local containerX, containerY = self.container:getPosition()
    local localPos = self:convertToNodeSpace(cc.p(containerX, containerY))
    -- LogUtil.d(TAG, "containerX, containerY = ", containerX, containerY)
    -- LogUtil.d(TAG, " localPos =  ", localPos)
    -- 目前只判断是纵向布局的
    if (localPos and localPos.y < -10 and self:isSideShow()) then
        LogUtil.d(TAG, "isShowTop 达到顶部")
        if self.m_scrollToBeginFunc then
            self.m_scrollToBeginFunc(self.m_scrollToBeginObj);
        end
    end
end

function DJListView:setScrollToBeginFunc(callObj, callFunc)
    self.m_scrollToBeginFunc = callFunc
    self.m_scrollToBeginObj = callObj
end

function DJListView:scrollToBottom()
    self:removeAllItems()
    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)
    self.items_ = {}
    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local posX, posY = 0, 0
    for i = 1, count do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)
        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH
            containerH = containerH + itemH
        else
            posX = posX + itemW
            containerW = containerW + itemW
        end
    end
    if DJListView.DIRECTION_VERTICAL == self.direction then
        if self.viewRect_.y + self.viewRect_.height >= containerH then
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + self.viewRect_.height)
        else
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + containerH)
        end
    else
        self.container:setPosition(self.viewRect_.x, self.viewRect_.y)
    end
end

---
-- 刷新当前布局 目前还有问题，需要再调整
function DJListView:refreshView2 (idx)
    local curX, curY = self.scrollNode:getPosition()
    -- local curX, curY = self.container:getPosition()
    -- LogUtil.d(TAG, "refreshView2 curX, curY = ", curX, curY)
    -- LogUtil.d(self.__cname, " refreshView2 curContainer pos = ", self.container:getPosition())
    -- LogUtil.d(self.__cname, " refreshView2 self.m_loadedItemsConf = ", self.m_loadedItemsConf)
    -- LogUtil.d(self.__cname, " refreshView2 self.viewRect_ = ", self.viewRect_)
    local lastItemConf = self.m_loadedItemsConf[#self.m_loadedItemsConf]
    local totalH = lastItemConf.size.height - lastItemConf.pos.y
    local offsetY = totalH - curY
    -- 把当前界面上的节点移除重新添加
    -- 移除当前的所有节点
    local idxList = {}
    local startIdx, endIdx = 0, 0
    local curItemConf
    for i = 1, #self.items_ do
        local item = self.items_[i]
        LogUtil.d(TAG, "refreshView2 idx = ", item.idx_)
        idxList[i] = item.idx_
        if (i == 1) then
            startIdx = item.idx_
            curItemConf = self.m_loadedItemsConf[i]
        elseif (i == #self.items_) then
            endIdx = item.idx_
        end
    end
    self:removeAllItems()
    self.items_ = {}
    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local startItemConf = self.m_loadedItemsConf[startIdx]
    local posX, posY = 0, 0
    local offsetH = 0
    if (not table.isEmpty(startItemConf)) then
        posX = startItemConf.pos.x
        posY = startItemConf.pos.y
    end
    for i = 1, startIdx - 1 do
        local itemConf = self.m_loadedItemsConf[i]
        itemW, itemH = itemConf.size.width, itemConf.size.height
        if DJListView.DIRECTION_VERTICAL == self.direction then
            containerH = containerH + itemH
        else
            containerW = containerW + itemW
        end
        -- if (curItemConf) then
        --     offsetH = itemH - curItemConf.size.height
        -- end
    end
    for i = startIdx, endIdx do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)
        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH
            containerH = containerH + itemH
        else
            posX = posX + itemW
            containerW = containerW + itemW
        end
    end
    -- self.container:setPosition(curX, curY)
    if DJListView.DIRECTION_VERTICAL == self.direction then
        if self.viewRect_.y + self.viewRect_.height >= containerH then
    -- LogUtil.d(TAG, "refreshView2 ---- 22222 ", containerH, self.viewRect_.y + self.viewRect_.height)
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + self.viewRect_.height)
        else
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + containerH)
    -- LogUtil.d(TAG, "refreshView2 ---- 33333 ", containerH, self.viewRect_.y + containerH)
        end
    else
        self.container:setPosition(self.viewRect_.x, self.viewRect_.y)
    end
    -- LogUtil.d(self.__cname, " refreshView2 curScrollNode pos = ", self.scrollNode:getPosition())
    -- LogUtil.d(self.__cname, " refreshView2 curContainer pos = ", self.container:getPosition())
    -- LogUtil.d(self.__cname, " refreshView2 end self.viewRect_ = ", self.viewRect_)
end

---
-- 滚动到底部
function DJListView:scrollToBottom2 ()
    -- 读取已经加载过节点的坐标和大小
    -- 根据展示的高度，计算第一个的坐标
    -- 移除所有项
    -- 从上面找到的第一个开始重新加载到末尾项
    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)
    local loadedCount = #self.m_loadedItemsConf -- 已经加载过的节点个数
    local totalHeight = 0
    local isInit = false
    if (loadedCount == 0) then
       isInit = true
       -- return
    end
    -- LogUtil.d(TAG, " scrollToBottom2 begin to load other items ")
    local lastLoadedItem = self.m_loadedItemsConf[loadedCount]
    local orgPos = cc.p(0, 0)
    if (not table.isEmpty(lastLoadedItem)) then
        orgPos = cc.p(lastLoadedItem.pos.x, lastLoadedItem.pos.y - lastLoadedItem.size.height)
    end
    if (count ~= loadedCount) then
        for i = loadedCount + 1, count do
            local itemSize = self:getItemSizeByIndex(i, true, orgPos)
            orgPos = cc.p(orgPos.x, orgPos.y - itemSize.height)
            if (not self.m_loadedItemsConf[i]) then
                self.m_loadedItemsConf[i] = {
                    pos = orgPos,
                    size = itemSize
                }
            end
        end
    end
    -- LogUtil.d(TAG, " scrollToBottom2 end to load other items ")
    local findIdx = -1
    local isBreak = false
    local remainH = self.viewRect_.height
    local totalH  = -1
    local findItemConf
    loadedCount = #self.m_loadedItemsConf
    for i = loadedCount, 1, -1 do
        local itemConf = self.m_loadedItemsConf[i]
        remainH = remainH - itemConf.size.height
        if (i == loadedCount) then
            totalH  = 0 - (itemConf.pos.y - itemConf.size.height)
        end
        findIdx = i
        findItemConf = itemConf
        if (remainH <= 0) then
            break
        end
    end
    -- LogUtil.d(TAG, "scrollToBottom2 ---- ", totalH, self.m_loadedItemsConf, findIdx)
    self:removeAllItems()
    self.items_ = {}
    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local findItem = findItemConf
    local posX, posY = 0, 0
    if (not table.isEmpty(findItemConf)) then
        posX = findItemConf.pos.x
        posY = findItemConf.pos.y
    end
    local startIdx = 1
    for i = findIdx, count do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)
        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH
            containerH = containerH + itemH
        else
            posX = posX + itemW
            containerW = containerW + itemW
        end
    end
    if DJListView.DIRECTION_VERTICAL == self.direction then
        if self.viewRect_.height >= containerH then
    LogUtil.d(TAG, "scrollToBottom2 ---- 22222 ", containerH)
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + self.viewRect_.height)
        else
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + totalH)
    LogUtil.d(TAG, "scrollToBottom2 ---- 33333 ", totalH)
        end
    else
        self.container:setPosition(self.viewRect_.x, self.viewRect_.y)
    end
end

function DJListView:elasticScroll()
    local cascadeBound = self:getScrollNodeRect()
    local disX, disY = 0, 0
    local viewRect = self:getViewRect() -- InWorldSpace()
    local t = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))

    cascadeBound.x = t.x
    cascadeBound.y = t.y
    self.scaleToWorldSpace_ = self.scaleToWorldSpace_ or {x=1,y=1}
    cascadeBound.width = cascadeBound.width / self.scaleToWorldSpace_.x
    cascadeBound.height = cascadeBound.height / self.scaleToWorldSpace_.y

    -- dump(self.scaleToWorldSpace_, "DJListView - scaleToWorldSpace_:")
    -- dump(cascadeBound, "DJListView - cascBoundingBox:")
    -- dump(viewRect, "DJListView - viewRect:")

    if cascadeBound.width < viewRect.width then
        disX = viewRect.x - cascadeBound.x
    else
        if cascadeBound.x > viewRect.x then
            disX = viewRect.x - cascadeBound.x
        elseif cascadeBound.x + cascadeBound.width < viewRect.x + viewRect.width then
            disX = viewRect.x + viewRect.width - cascadeBound.x - cascadeBound.width
        end
    end

    if cascadeBound.height < viewRect.height then
        disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
    else
        if cascadeBound.y > viewRect.y then
            disY = viewRect.y - cascadeBound.y
        elseif cascadeBound.y + cascadeBound.height < viewRect.y + viewRect.height then
            disY = viewRect.y + viewRect.height - cascadeBound.y - cascadeBound.height
        end
    end

    if 0 == disX and 0 == disY then
        return
    end

    if self.m_isNeedAutoHeight then
        if DJListView.DIRECTION_VERTICAL == self.direction then
            disY = disY + self.m_isNeedAutoHeight;

        else
            disX = disX + self.m_isNeedAutoHeight;
        end
    end

    self.m_elasticFlag = true;

    transition.moveBy(self.scrollNode,
        {x = disX, y = disY, time = 0.3,
        easing = "backout",
        onComplete = function()
            self.m_elasticFlag = false;
            self:callListener_{name = "scrollEnd"}

            if self.m_refreshViewNum then
                self:refreshView(self.m_refreshViewNum);
                self.m_refreshViewNum = nil;
            end
        end})
end

-- 只刷新数据，刷新当前
function DJListView:refreshView(firstNum)
    if self.m_elasticFlag then
        self.m_refreshViewNum = firstNum;
        return;
    end

    local x, y = self.container:getPosition();
    local viewRect = self:getViewRect()

    local maxY = -self.m_loadedMaxY + self.m_loadedMaxItemHeight;
    local minY = maxY - viewRect.height;

    -- 找到当前的x和y是第几项【items，pos】
    local index = -1;
    y = y - viewRect.height;

    -- if y < minY then
    --     LogUtil.d("DJListView", y .. "不在范围内，不需要刷新界面", "minY = " .. minY, "maxY = " .. maxY)
    --     return;
    -- end

    LogUtil.d("DJListView", y .. "在范围内，需要刷新界面", "minY = " .. minY , "maxY = " .. maxY)

    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local posX, posY = 0, 0

    for k ,v in pairs(self.m_loaded) do
        if v.pos and -v.pos.y <= y and v.items and v.items.h - v.pos.y >= y then
            index = tonumber(k);
            posX = v.pos.x;
            posY = v.pos.y;
            break;
        end
    end

    LogUtil.d("DJListView", string.format("当前的x = %s, y = %s, 算最上面的位置是在 %s", x,y , index))

    self:removeAllItems();
    self.m_loaded = nil;
    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)

    if index == -1 then
        index = 1;
        posX = 0;
        posY = 0;
    end

    firstNum = firstNum or count;

    for i=index , firstNum do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)

        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH

            containerH = containerH + itemH
        else
            posX = posX + itemW

            containerW = containerW + itemW
        end

        -- 初始布局,最多保证可隐藏的区域大于显示区域就可以了
        if containerW > self.viewRect_.width + self.redundancyViewVal
            or containerH > self.viewRect_.height + self.redundancyViewVal then
            break
        end
    end
end

function DJListView:increaseOrReduceItem_()
    if 0 == #self.items_ then
        print("ERROR items count is 0")
        return
    end

    local getContainerCascadeBoundingBox = function ()
        local boundingBox
        for i, item in ipairs(self.items_) do
            local w,h = item:getItemSize()
            local x,y = item:getPosition()
            local anchor = item:getAnchorPoint()
            x = x - anchor.x * w
            y = y - anchor.y * h

            if boundingBox then
                boundingBox = cc.rectUnion(boundingBox, cc.rect(x, y, w, h))
            else
                boundingBox = cc.rect(x, y, w, h)
            end
        end

        local point = self.container:convertToWorldSpace(cc.p(boundingBox.x, boundingBox.y))
        boundingBox.x = point.x
        boundingBox.y = point.y
        return boundingBox
    end

    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)
    local nNeedAdjust = 2 --作为是否还需要再增加或减少item的标志,2表示上下两个方向或左右都需要调整
    local cascadeBound = getContainerCascadeBoundingBox()
    local localPos = self:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
    local item
    local itemW, itemH

    -- print("child count:" .. self.container:getChildrenCount())
    -- dump(cascadeBound, "increaseOrReduceItem_ cascadeBound:")
    -- dump(self.viewRect_, "increaseOrReduceItem_ viewRect:")

    if DJListView.DIRECTION_VERTICAL == self.direction then

        --ahead part of view
        local disH = localPos.y + cascadeBound.height - self.viewRect_.y - self.viewRect_.height
        local tempIdx
        item = self.items_[1]
        if not item then
            print("increaseOrReduceItem_ item is nil, all item count:" .. #self.items_)
            return
        end
        tempIdx = item.idx_
        -- print(string.format("befor disH:%d, view val:%d", disH, self.redundancyViewVal))
        if disH > self.redundancyViewVal then
            itemW, itemH = item:getItemSize()
            if cascadeBound.height - itemH > self.viewRect_.height
                and disH - itemH > self.redundancyViewVal then
                self:unloadOneItem_(tempIdx)
            else
                nNeedAdjust = nNeedAdjust - 1
            end
        else
            item = nil
            tempIdx = tempIdx - 1
            if tempIdx > 0 then
                local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y + cascadeBound.height))
                item = self:loadOneItem_(localPoint, tempIdx, true)
            end
            if nil == item then
                nNeedAdjust = nNeedAdjust - 1

            else
                nNeedAdjust = 0;
            end
        end

        --part after view
        disH = self.viewRect_.y - localPos.y
        item = self.items_[#self.items_]
        if not item then
            return
        end
        tempIdx = item.idx_
        -- print(string.format("after disH:%d, view val:%d", disH, self.redundancyViewVal))
        if disH > self.redundancyViewVal then
            itemW, itemH = item:getItemSize()
            if cascadeBound.height - itemH > self.viewRect_.height
                and disH - itemH > self.redundancyViewVal then
                self:unloadOneItem_(tempIdx)
            else
                nNeedAdjust = nNeedAdjust - 1
            end
        else
            item = nil
            tempIdx = tempIdx + 1
            if tempIdx and count and tempIdx <= count then
                local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
                item = self:loadOneItem_(localPoint, tempIdx)
            end
            if nil == item then
                nNeedAdjust = nNeedAdjust - 1

            else
                nNeedAdjust = 0;
            end
        end
    else
        --left part of view
        local disW = self.viewRect_.x - localPos.x
        item = self.items_[1]
        local tempIdx = item.idx_
        if disW > self.redundancyViewVal then
            itemW, itemH = item:getItemSize()
            if cascadeBound.width - itemW > self.viewRect_.width
                and disW - itemW > self.redundancyViewVal then
                self:unloadOneItem_(tempIdx)
            else
                nNeedAdjust = nNeedAdjust - 1
            end
        else
            item = nil
            tempIdx = tempIdx - 1
            if tempIdx > 0 then
                local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x, cascadeBound.y))
                item = self:loadOneItem_(localPoint, tempIdx, true)
            end
            if nil == item then
                nNeedAdjust = nNeedAdjust - 1

            else
                nNeedAdjust = 0;
            end
        end

        --right part of view
        disW = localPos.x + cascadeBound.width - self.viewRect_.x - self.viewRect_.width
        item = self.items_[#self.items_]
        tempIdx = item.idx_
        if disW > self.redundancyViewVal then
            itemW, itemH = item:getItemSize()
            if cascadeBound.width - itemW > self.viewRect_.width
                and disW - itemW > self.redundancyViewVal then
                self:unloadOneItem_(tempIdx)
                nNeedAdjust = 0;
            else
                nNeedAdjust = nNeedAdjust - 1
            end
        else
            item = nil
            tempIdx = tempIdx + 1
            if tempIdx <= count then
                local localPoint = self.container:convertToNodeSpace(cc.p(cascadeBound.x + cascadeBound.width, cascadeBound.y))
                item = self:loadOneItem_(localPoint, tempIdx)
            end
            if nil == item then
                nNeedAdjust = nNeedAdjust - 1

            else
                nNeedAdjust = 0;
            end
        end
    end

    -- print("increaseOrReduceItem_() adjust:" .. nNeedAdjust)
    -- print("increaseOrReduceItem_() item count:" .. #self.items_)
    if nNeedAdjust > 0 then
        return self:increaseOrReduceItem_()
    end
end

function DJListView:loadOneItem_(originPoint, idx, bBefore)
    -- dump(debug.traceback())
    if not self.m_loaded then
        self.m_loaded = {};
    end

    self.m_loaded[tostring(idx)] = {};
    self.m_loaded[tostring(idx)].pos = originPoint;

    local item,itemW,itemH = DJListView.super.loadOneItem_(self, originPoint, idx, bBefore)

    self.m_loaded[tostring(idx)].items = {w = itemW, h = itemH};
    self.m_loadedItemsConf[idx] = {
        pos  = originPoint,
        size = {width = itemW, height = itemH}
    }
    if not self.m_loadedMaxY then
        self.m_loadedMaxY = 0;
        self.m_loadedMaxItemHeight = 0;
    end

    if -originPoint.y > -self.m_loadedMaxY then
        self.m_loadedMaxY = originPoint.y;
        self.m_loadedMaxItemHeight = itemH;
    end
    -- LogUtil.d(self.__cname, "loadOneItem_ loadedItemConfig = ", self.m_loadedItemsConf[idx])
    return item, itemW, itemH;
end

-- 获取所有 item 的高度
-- 目前计算有异常只在 同步加载所有 item 以及 item 总高度小于 listview 高度
function DJListView:getAllItemHeight()
    local height = 0
    local items = self.container:getChildren()
    for i = 1, #items do
        local tempItem = items[i]
        if (tempItem) then
            local itemSize = tempItem:getContentSize()
            if (itemSize) then
                height = height + itemSize.height
            end
        end
    end
    return height
end

-- 通过索引值计算 item 的总高度
function DJListView:getItemsHeightByIndex (index)
    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local posX, posY = 0, 0
    for i = 1, index do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)
        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH
            containerH = containerH + itemH
        else
            posX = posX + itemW
            containerW = containerW + itemW
        end
    end
    if DJListView.DIRECTION_VERTICAL == self.direction then
        if self.viewRect_.y + self.viewRect_.height >= containerH then
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + self.viewRect_.height)
        else
            self.container:setPosition(self.viewRect_.x,
                self.viewRect_.y + containerH)
        end
        return containerH
    else
        self.container:setPosition(self.viewRect_.x, self.viewRect_.y)
        return containerW
    end
end

-- 通过 index 获取 item 的高度
-- !此方法会导致节点有异常，需要在调用过之后刷新列表
-- @field index number 索引值
-- @field isRefresh 是否强制刷新
-- @field orgPos 原始坐标
function DJListView:getItemSizeByIndex (index, isRefresh, orgPos)
    if not index then
        return cc.size(0, 0)
    end
    local itemSize
    local itemW, itemH = 0, 0
    local item = self.items_[index]
    if (item and (not isRefresh)) then
        itemSize = item:getItemSize()
    else
        item, itemW, itemH = self:loadOneItem_(orgPos or cc.p(0, 0), index)
        itemSize = cc.size(itemW, itemH)
        self:unloadOneItem_(index)
    end
    return itemSize
end

-- 通过指定区间索引计算总大小
-- @field beginInd number 开始索引值
-- @field endIdx number 结束索引值
-- @field isRefresh boolean 是否强制刷新
-- return table {width,height}
function DJListView:getItemsHeightFromIndex (beginIdx, endIdx, isRefresh)
    beginIdx = (not beginIdx) or 1
    endIdx = beginIdx > endIdx and beginIdx or endIdx
    local itemW, itemH = 0, 0
    local containerW, containerH = 0, 0
    local itemSize
    for i = beginIdx, endIdx do
        itemSize = self:getItemSizeByIndex(i, isRefresh)
        if DJListView.DIRECTION_VERTICAL == self.direction then
            containerW = itemSize.width
            containerH = containerH + itemSize.height
        else
            containerW = containerW + itemSize.width
            containerH = itemSize.height
        end
    end
    return cc.size(containerW, containerH)
end

---
-- 根据 idx 获取 item 配置 {pos, size}
function DJListView:getItemConf (idx)
    return self.m_loadedItemsConf[idx] or {}
end

function DJListView:loadToItem(index, ajustPos)
    -- 如果本身的高度就没有总高度+那么高，就压根不需要处理
    if not self:isCanDragFlag() then
        return
    end

    self:removeAllItems()
    self.container:setPosition(0, 0)
    self.container:setContentSize(cc.size(0, 0))

    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)

    self.items_ = {}
    local itemW, itemH = 0, 0
    local item
    local containerW, containerH = 0, 0
    local posX, posY = 0, 0
    for i = 1, count do
        item, itemW, itemH = self:loadOneItem_(cc.p(posX, posY), i)

        if DJListView.DIRECTION_VERTICAL == self.direction then
            posY = posY - itemH

            containerH = containerH + itemH
        else
            posX = posX + itemW

            containerW = containerW + itemW
        end

        -- 初始布局,最多保证可隐藏的区域大于显示区域就可以了
        if containerW > self.viewRect_.width + self.redundancyViewVal
            or containerH > self.viewRect_.height + self.redundancyViewVal then
            break
        end
    end

    local needScrollHeight = 0

    -- 计算到这一项有多少距离
    for i = 1, index do
        local item = self.delegate_[DJListView.super.DELEGATE](self, DJListView.super.CELL_TAG, i)
        local itemW, itemH = item:getItemSize()
        needScrollHeight = needScrollHeight + itemH
    end

    needScrollHeight = needScrollHeight - (self.viewRect_.height + self.redundancyViewVal)

    if needScrollHeight and needScrollHeight > 0 then
        self.container:stopAllActions()
        local moveToAction = cc.MoveTo:create(0.2, cc.p(self.viewRect_.x, self.viewRect_.y + self.viewRect_.height
                                + needScrollHeight + (ajustPos.y or 0)))
        self.container:runAction(moveToAction)
    end
end

function DJListView:isCanDragFlag()
    local count = self.delegate_[DJListView.DELEGATE](self, DJListView.COUNT_TAG)

    -- 需要判断下高度，如果高度没有显示高度高，则不需要滑动
    local containW = 0
    local containH = 0
    local bottomDistantHeight = 0
    local hasFillFlag = false -- 是否充满整个界面

    for i = 1, count do
        local item = self.delegate_[DJListView.DELEGATE](self, DJListView.CELL_TAG, i)
        local itemW, itemH = item:getItemSize()

        containH = containH + itemH

        if containH > self.viewRect_.height + self.redundancyViewVal then
            hasFillFlag = true

            if i == count then
                bottomDistantHeight = containH - (self.viewRect_.height + self.redundancyViewVal)
            end
            break
        end
    end

    if not hasFillFlag then
        return false
    end

    return hasFillFlag, bottomDistantHeight
end

function DJListView:getAllItems()
    return self.items_
end

return DJListView
