local GlobalFunction = class("GlobalFunction")

function GlobalFunction:ctor()
end

function GlobalFunction:gcm()
end

function GlobalFunction:requestGooglePushCallBack(data)
end

function GlobalFunction:dtor()
end

function releaseAllThings()
end

function sendClientLog(tb_data)
    if not tb_data then
        return
    end
end

function getSitemid()
    if device.platform == "android" then
        return nk.Native:getImei()

    else
        return device.getOpenUDID()
    end
end


-- 保留几位小数点
function getPreciseDecimal(nNum, n)
    if type(nNum) ~= "number" then
        return nNum
    end
    n = n or 0
    n = math.floor(n)
    if n < 0 then
        n = 0
    end
    local nDecimal = 10 ^ n
    local nTemp = math.floor(nNum * nDecimal)
    local nRet = nTemp / nDecimal
    return nRet
end

-- 分割游戏币
function splitCoinNormalFormat(curMoney,isShowPoint,pointNum)
    local coins = splitCoinFormat(curMoney,isShowPoint,pointNum,true);
    if not coins then
        return "";
    end
    local len = string.len(coins);

    local ret,msg = pcall(function()
        if pointNum == 1 then
            local strEnd = string.sub(coins,len - 1,len-1);

            local str = string.sub(coins,len - pointNum - 1,len-pointNum - 1);
            local strId = string.sub(coins,len);
            local otherStr = string.sub(coins,1,len - pointNum - 2);

            if str == "." and strEnd == "0" then
                coins = otherStr .. strId;
            end


        elseif pointNum == 2 then
            local strEnd = string.sub(coins,len - 1,len-1);
            local strEnd2 = string.sub(coins,len - 2,len-2);

            local str = string.sub(coins,len - pointNum - 1,len-pointNum - 1);
            local strId = string.sub(coins,len);
            local otherStr = string.sub(coins,1,len - pointNum - 2);

            if strEnd == "0" and strEnd2 == "0" and str == "." then
                coins = otherStr .. strId;

            elseif strEnd == "0" and strEnd2 ~= "0" and str == "." then
                coins = otherStr .. str .. strEnd2 .. strId;
            end
        end

    end)

    return coins;

end

--[[
    分割字符串money(多余的用...替代)
    @param curMoney  String - 原来的money
    @return String - 分割完成之后的money
    create-author       : ClarkWu
]]
function splitCoinFormat(curMoney, isShowPoint, pointNum, notFloor)
    -- 不显示小数点
    if (not isShowPoint) then
        return require("app.util.NumUtil").toStr(curMoney, 99, {
            pointNum  = pointNum or 2,
        })
    -- 显示小数点
    else
        return require("app.util.NumUtil").toStr(curMoney, 99, {
            pointNum  = 0,
        })
    end
    curMoney = tonumber(curMoney or 0)
    pointNum = pointNum or 2;
    local strFormat = string.format(".%sf", pointNum)
    if not curMoney then
        return
    end
    if curMoney < 1000 then
        return curMoney
    end

    curMoney = curMoney / 1000 * 100/100

    if curMoney < 1000 then

        if curMoney < 1000 then
            if not isShowPoint then
                if not notFloor then
                    curMoney = math.floor(curMoney*100)

                else
                    curMoney = curMoney * 100;
                end

                -- 防止四舍五入
                if pointNum == 2 then
                    -- curMoney = math.floor(curMoney /100 * 100);
                    return string.format("%" .. strFormat,curMoney/100) .. "K";

                else
                    curMoney = math.floor(curMoney /100 * 10);
                    return string.format("%" .. strFormat,curMoney/10) .. "K";
                end

            else
                if not notFloor then
                    return curMoney .. "K";

                else
                    return math.floor(curMoney * 100)/100 .. "K";
                end
            end
        end
    end

    if curMoney < 1000 * 1000 then
        if curMoney < 1000 * 1000 then
            if not isShowPoint then
                if not notFloor then
                    curMoney = math.floor(curMoney / 1000 * 100)

                else
                    curMoney = curMoney / 1000 * 100;
                end

                -- 防止四舍五入
                if pointNum == 2 then
                    -- curMoney = math.floor(curMoney /100 * 100);
                    return string.format("%" .. strFormat,curMoney/100) .. "M";

                else
                    curMoney = math.floor(curMoney /100 * 10);
                    return string.format("%" .. strFormat,curMoney/10) .. "M";
                end

            else
                curMoney = curMoney / 1000;

                if not notFloor then
                    return curMoney .. "M";

                else
                    return math.floor(curMoney * 100)/100 .. "M";
                end
            end
        end
    end

    if curMoney < 1000 * 1000 * 1000 then
        if curMoney < 1000 * 1000 * 1000 then
            if not isShowPoint then
                if not notFloor then
                    curMoney = math.floor(curMoney / 1000000 * 100)

                else
                    curMoney = curMoney / 1000000 * 100;
                end

                -- 防止四舍五入
                if pointNum == 2 then
                    -- curMoney = math.floor(curMoney /100 * 100);
                    return string.format("%" .. strFormat,curMoney/100) .. "B";

                else
                    curMoney = math.floor(curMoney /100 * 10);
                    return string.format("%" .. strFormat,curMoney/10) .. "B";
                end

            else
                curMoney = curMoney / 1000000;

                if not notFloor then
                    return curMoney .. "B";

                else
                    return math.floor(curMoney * 100)/100 .. "B";
                end
            end
        end
    end

    if curMoney < 1000 * 1000 * 1000 * 1000 then
        if curMoney < 1000 * 1000 * 1000 * 1000 then
            if not isShowPoint then
                if not notFloor then
                    curMoney = math.floor(curMoney / 1000000000 * 100)

                else
                    curMoney = curMoney / 1000000000 * 100

                end

                -- 防止四舍五入
                if pointNum == 2 then
                    -- curMoney = math.floor(curMoney /100 * 100);
                    return string.format("%" .. strFormat,curMoney/100) .. "T";

                else
                    curMoney = math.floor(curMoney /100 * 10);
                    return string.format("%" .. strFormat,curMoney/10) .. "T";
                end
            else
                curMoney = curMoney / 1000000000;

                if not notFloor then
                    return curMoney .. "T";

                else
                    return math.floor(curMoney * 100)/100 .. "T";
                end
            end

        end
    end

    return splitMoneyForThree(curMoney / 1000000000) .. "T";
end

function splitMoneyForStr(curMoney,strMoney)
    curMoney = tonumber(curMoney or 0)

    if strMoney == "K" then
        return (curMoney / 1000) .. "K";
    end

    if strMoney == "M" then
        return (curMoney / 1000 / 1000) .. "M";
    end

    if strMoney == "B" then
        return (curMoney / 1000 / 1000 / 1000) .. "B";
    end

    if strMoney == "T" then
        return (curMoney / 1000 / 1000 / 1000 / 1000) .. "T";
    end
end

--[[
    每隔三位添加","方法
    @param money  String     - 需要添加的字符串
    @return retString String - 添加,后的字符串
    create-author       : ClarkWu
]]
function splitMoneyForThree(money)
    if tonumber(money or 0) and tonumber(money or 0) >= 0 then
        money = string.format("%d",money);
        local retString = "";

        for i = 1 , string.len(money) do
            retString = string.format(retString..string.sub(money,i,i));
            index = string.len(money) - i;

            if index > 0 and 0 == (index % 3) then
                retString = string.format(retString..",");
            end
        end

        return retString;

    elseif tonumber(money or 0) then
        return "-" .. splitMoneyForThree(tonumber(-money));

    else
        return "";
    end
end

function splitMoneyForThreeIgnoreZero(money)
    local retString = "";

    for i = 1, string.len(money) do
        retString = string.format(retString..string.sub(money,i,i));
        index = string.len(money) - i;

        if index > 0 and 0 == (index % 3) then
            retString = string.format(retString..",");
        end
    end

    return retString;
end

--[[
    格式化（含小数）数字方法
    @param number
    @param decimal 小数位数
    @param isNotNeedThree 是否不需要逢3位+，
]]
function splitForPoint(number, decimal, isNotNeedThree, isNeedPoint)
    if not number then
        return "";
    end

    if not decimal then
        decimal = 2;
    end

    if number == 0 then
        return "0";
    end

    if isNotNeedThree then
        return string.format("%." .. decimal .. "f", number)

    else
        -- 取出整数部分和小数部分
        local a,b = math.modf(number)

        local a2 = splitMoneyForThree(a)

        if b == 0 then
            if not isNeedPoint then
                return a2;
            end
        end

        if decimal == 2 then
            if not isNeedPoint then
                local result = string.format("%." .. decimal .. "f", b);

                local b2 = string.sub(result, 4)

                if tonumber(b2) == 0 then
                    decimal = 1;
                end
            end
        end

        return a2 .. string.sub(string.format("%." .. decimal .. "f", b),2)
    end
end


--[[
    截取字符串方法(多余的用...替代)
    @param sName     String - 原来需要截取的字符串
    @param nMaxCount Number - 限制字符串最大长度
    @param size      Number - 字符串大小
    @return String - 截取后的字符串
    create-author       : ClarkWu
]]
function getNewSplitName(sName,nMaxCount,size)
    if device.platform == "android" then
        return nk.Native:getFixedWidthText("", size, sName, nMaxCount * 15);

    else
        return getShortName(sName, nMaxCount,nMaxCount);
    end
end

--[[
    截取字符串方法(多余的用...替代)
    @param sName     String - 原来需要截取的字符串
    @param nMaxCount Number - 限制字符串最大长度
    @param size      Number - 字符串大小
    @return sName String - 截取后的字符串
    create-author       : ClarkWu
]]
function getShortName(sName,nMaxCount,nShowCount)
    if not sName or not nMaxCount then
        return;
    end

    local sStr = sName;
    local tCode = {};
    local tName = {};
    local nLenInByte = #sStr;
    local nWidth = 0;

    if not nShowCount then
       nShowCount = nMaxCount - 3;
    end

    for i=1,nLenInByte do
        local curByte = string.byte(sStr, i);
        local byteCount = 0;

        if curByte > 0 and curByte <= 127 then
            byteCount = 1;

        elseif curByte >= 192 and curByte < 223 then
            byteCount = 2;

        elseif curByte >= 224 and curByte < 239 then
            byteCount = 3;

        elseif curByte >= 240 and curByte <= 247 then
            byteCount = 4;
        end

        local char = nil;

        if byteCount > 0 then
            char = string.sub(sStr, i, i+byteCount-1);
            i = i + byteCount -1;
        end

        if byteCount == 1 then
            nWidth = nWidth + 1;
            table.insert(tName,char);
            table.insert(tCode,1);

        elseif byteCount > 1 then
            nWidth = nWidth + 2;
            table.insert(tName,char);
            table.insert(tCode,2);
        end
    end

    if nWidth > nMaxCount then
        local _sN = "";
        local _len = 0;

        for i=1,#tName do
            _sN = _sN .. tName[i];
            _len = _len + tCode[i];

            if _len >= nShowCount then
                break;
            end
        end

        sName = _sN .. "...";
    end

    return sName;
end

-- 计算两个时间差值的方法
-- 返回 相差的天数， 相差的小时数
function minusDistantDayTime(originDayTime,nowDayTime)
    if not originDayTime or not nowDayTime then
        return;
    end

    -- 取到当前时间的00:00:00分
    local nowDayStr = os.date("%Y%m%d",nowDayTime)
    local nowYear = string.sub(nowDayStr,1,4);
    local nowMonth = string.sub(nowDayStr,5,6)
    local nowDays = string.sub(nowDayStr,7,8);

    local originDayStr = os.date("%Y%m%d",originDayTime)
    local originYear  = string.sub(originDayStr,1,4);
    local originMonth = string.sub(originDayStr,5,6)
    local originDays  = string.sub(originDayStr,7,8);

    local nowZeroTime = os.time({year = nowYear, month = nowMonth, day =nowDays, hour =0, min =0, sec = 0});
    local originZeroTime = os.time({year = originYear, month = originMonth, day = originDays, hour =0 , min =0, sec = 0});

    local surplusDays = math.ceil((nowZeroTime - originZeroTime) / (24 * 60 * 60));
    return surplusDays,math.floor((nowDayTime - originDayTime)/3600);
end

function calculateMonthDaysByNowYear(month,year)
    local days = {31,28,31,30,31,30,31,31,30,31,30,31};

    local mon = tonumber(month or 0);
    local yea = tonumber(year or 0);

    -- 如果是2月
    if mon == 2 then
        if isRunYear(yea) then
            return 29;
        end
    end

    return days[mon];
end

function isRunYear(year)
    local yea = tonumber(year or 0)
    if (yea % 4 == 0 and yea % 100 ~= 0) or (yea % 100 == 0 and yea % 400 == 0) then
        return true;
    end

    return false;
end

function getTwoPointAngle(point1,point2)
    local x1 = point1.x;
    local y1 = point1.y;
    local x2 = point2.x;
    local y2 = point2.y;

    return math.atan2(y2 - y1, x2 - x1) / math.pi * 180;
end

function getTwoPointDistant(point1,point2)
    local x1 = point1.x;
    local y1 = point1.y;
    local x2 = point2.x;
    local y2 = point2.y;

    return math.sqrt(math.pow((y2-y1),2) + math.pow((x2-x1),2));
end

local table = table or {}
function table.isEmpty(tb)
    if (tb and next(tb) ~= nil) then
        return false
    end
    return true
end

local tableindexof = table.indexof
function table.indexof(array, value, begin)
    if (table.isEmpty and table.isEmpty(array)) then
        return false
    end
    if (tableindexof) then
        return tableindexof(array, value, begin)
    end
    return false
end

---
-- 比较两个数组(目前只支持)
-- @return result boolean 是否相等（跟顺序有关）
function table.compare(a1, a2)
    if (table.isEmpty(a1) or table.isEmpty(a2)) then
        return false
    end
    if (#a1 ~= #a2) then
        return false
    end
    for i = 1, #a1 do
        if (a1[i] ~= a2[i]) then
            return false
        end
    end
    return true
end

-- 检查事件坐标是否在目标范围内
-- return boolean true 在 false 不在
function checkXY(target, event)
    local b = target:getCascadeBoundingBox()
    if event.x > b.x and event.x < b.x + b.width
        and event.y > b.y and event.y < b.y + b.height then
        return true
    else
        return false
    end
end

-- 新按钮，会传递事件的按钮
function setButtonEventEx(target, fun, skipCheckErupt, isNotNeedSound, isNotEffect)
    local orgScaleX, orgScaleY = 1, 1
    target:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    target:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
        if event.name == "began" then
            orgScaleX, orgScaleY = target:getScaleX(), target:getScaleY()
            -- 避免两次点击过快 1s 一次
            local nowTime = os.time()
            if (not target.m_onClickTime) then
                target.m_onClickTime = nowTime
            else
                if (skipCheckErupt and nowTime - target.m_onClickTime < 1) then
                    return true
                end
                target.m_onClickTime = nowTime
            end
            if (not isNotEffect) then
                target:setColor(cc.c3b(220, 220, 220))
            end
            transition.scaleTo(target, { scaleX = 0.98 * orgScaleX, scaleY = 0.98 * orgScaleY, time = 0.075 })
            target.flag = true
            target.begX = event.x
            target.begY = event.y
            return true
        elseif event.name == "moved" then
            if not target.flag then return end
            if (not isNotEffect) then
                target:setColor(cc.c3b(255, 255, 255))
            end
            if checkXY(target, event) then
                transition.scaleTo(target, {scaleX = 0.98 * orgScaleX, scaleY = 0.98 * orgScaleY, time = 0.075})
            else
                transition.scaleTo(target, {scaleX = orgScaleX, scaleY = orgScaleY, time = 0.075})
                target.flag = false
            end
        elseif event.name == "ended" then
            if not target.flag then return end
            if target:getScaleX() <= 1 * orgScaleX then
                if (not isNotEffect) then
                    target:setColor(cc.c3b(255, 255, 255))
                end
                transition.scaleTo(target, { scaleX = orgScaleX, scaleY = orgScaleY, time = 0.075 })
                -- 播放按钮声音
                if not isNotNeedSound then
                    nk.SoundManager:playSound(nk.Audio.Effects.CLICK_BUTTON)
                end
                fun(target)
            end
            target.flag = false
        end
    end)
    target:setTouchSwallowEnabled(false)
    target:setTouchEnabled(true)
end

-- 设置按钮事件，不会透传事件，
-- @param target 目标节点
-- @param fun 回调方法
-- @param skipCheckErupt 跳过检测并发
-- @param isNotNeedSound 是否不需要声音
-- @param isNotEffect    是否不需要效果
function setButtonEvent(target, fun, skipCheckErupt, isNotNeedSound, isNotEffect, effectNode)
    local orgScaleX, orgScaleY = 1, 1
    target:removeNodeEventListenersByEvent(cc.NODE_TOUCH_EVENT)
    target:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event, x, y)
        if event.name == "began" then
            orgScaleX, orgScaleY = target:getScaleX() , target:getScaleY()
            -- 避免两次点击过快 1s 一次
            local nowTime = os.time()
            if (not target.m_onClickTime) then
                target.m_onClickTime = nowTime
            else
                if (skipCheckErupt and (nowTime - target.m_onClickTime) < 1) then
                    return true
                end
                target.m_onClickTime = nowTime
            end
            if (not isNotEffect) then
                target:setColor(cc.c3b(220, 220, 220))
                if (effectNode) then
                    effectNode:setColor(cc.c3b(220, 220, 220))
                end
            end
            transition.scaleTo(target, {scaleX = 0.98 * orgScaleX, scaleY = 0.98 * orgScaleY, time = 0.075})
            if (effectNode) then
                transition.scaleTo(effectNode, {scaleX = 0.98 * orgScaleX, scaleY = 0.98 * orgScaleY, time = 0.075})
            end
            target.flag = true
        elseif event.name == "moved"  then
            if target.flag then
                if (not isNotEffect) then
                    target:setColor(cc.c3b(255, 255, 255))
                    if (effectNode) then
                        effectNode:setColor(cc.c3b(255, 255, 255))
                    end
                end
                local actionData
                if checkXY(target, event) then
                    actionData = {scaleX = 0.98 * orgScaleX, scaleY = 0.98 * orgScaleY, time = 0.075}
                else
                    actionData = {scaleX = orgScaleX, scaleY = orgScaleY, time = 0.075}
                    target.flag = false
                end
                if (actionData) then
                    transition.scaleTo(target, actionData)
                    if (effectNode) then
                        transition.scaleTo(effectNode, actionData)
                    end
                end
            end
        elseif event.name == "ended" then
            if not target.flag then return end
            if target:getScaleX() <= 1 * orgScaleX then
                if (not isNotEffect) then
                    target:setColor(cc.c3b(255, 255, 255))
                    if (effectNode) then
                        effectNode:setColor(cc.c3b(255, 255, 255))
                    end
                end
                transition.scaleTo(target, {scaleX = orgScaleX, scaleY = orgScaleY, time = 0.075})
                if (effectNode) then
                    transition.scaleTo(effectNode, {scaleX = orgScaleX, scaleY = orgScaleY, time = 0.075})
                end
                -- 播放按钮声音
                if not isNotNeedSound then
                    nk.SoundManager:playSound(nk.Audio.Effects.CLICK_BUTTON)
                end
                fun(target)
            end
            target.flag = false
        end
        return true
    end)
    target:setTouchEnabled(true)
end

-- 比较两个版本
-- ver1 大于 正数 小于 负数 等于 0
function compareVersion(ver1, ver2)
    local i = 1
    local j = 1
    local x = 0
    local y = 0
    local v1Len = string.len(ver1)
    local v2Len = string.len(ver2)
    local curChar
    local zero  = tonumber(string.byte('0'))
    local nine  = tonumber(string.byte('9'))
    local point = tonumber(string.byte('.'))
    while ((i <= v1Len) or (j <= v2Len))
    do
        -- 计算出 V1 中的点之前的数字
        while (i <= v1Len)
        do
            -- 转换为 ASCLL
            curChar = tonumber(string.byte(string.sub(ver1, i, i)))
            i = i + 1
            if (curChar >= zero and curChar <= nine) then
                x = x * 10 + (curChar - zero)
            elseif (curChar == point) then
                break
            else
                -- 无效的字符
            end
        end
        -- 计算出 V2 中的点之前的数字
        while (j <= v2Len)
        do
            curChar = tonumber(string.byte(string.sub(ver2, j, j)))
            j = j + 1
            if (curChar >= zero and curChar <= nine) then
                y = y * 10 + (curChar - zero)
            elseif (curChar == point) then
                break
            else
                -- 无效的字符
            end
        end
        if (x < y) then
            return -1
        elseif (x > y) then
            return 1
        else
            x = 0
            y = 0
        end
    end
    return 0
end

function getSuitScaleByHeight(standard, sprite)
    if standard and sprite then
        local height = sprite:getContentSize().height;
        local h_scale = standard / height;

        local width = sprite:getContentSize().width;
        local w_scale = standard / width;

        return math.min(w_scale, h_scale);
    end
    return 0;
end

-- 全局空方法
function nullFunc ()
    -- nothing to do
end

function nativeCallBackLua(backJsons)
    LogUtil.d("nativeCallBackLua backJsons = ", backJsons)
    local jsonTab = json.decode(backJsons);

    local luaFunction = jsonTab.luaFunction;

    if luaFunction then
        jsonTab.luaFunction = nil;
        require(luaFunction).executeBackToLua(jsonTab);
    end
end

function fixPopupCallBack()
    nk.Const.isErrorInStart = true;

    if nk.PlayerManager then
        nk.PlayerManager:clearAccount();
    end

    if nk.socket and nk.socket.GameSocket then
        nk.socket.GameSocket.disconnect();
    end
end

-- example:
-- [if both createGetter and createSetter are true]
-- addProperty(Account,"id",0,true,true)
-- call this function equels:
-- Account.getId = function (self)
--   return self.m_id or 0
-- end
-- Account.setId = function (self,var)
--   self.m_id = var
-- end
-- it helps us reduce so much codes to generate the getter and setter
-- it feel so good, enjoy it yourself!
function addProperty(class, varName, defaultValue, createGetter, createSetter)
    createGetter = (createGetter == nil) or createGetter;
    createSetter = (createSetter == nil) or createSetter;
    local tempName = "m_" .. varName
    local propName = string.upper(string.sub(varName, 1, 1)) .. (#varName > 1 and string.sub(varName, 2, -1) or "")
    class[tempName] = defaultValue
    if createGetter then
        class[string.format("get%s", propName)] = function(self)
            return self[tempName] == nil and defaultValue or self[tempName];
        end
    end
    if createSetter then
        class[string.format("set%s", propName)] = function(self,var)
            self[tempName] = var;
            return self
        end
    end
end

-- the same as addProperty, but the class is a table
-- example:
-- [if both createGetter and createSetter are true]
-- addProperty(Account,"m_id",0,true,true)
-- call this function equels:
-- Account.getId = function ()
--   return Account.m_id or 0
-- end
-- Account.setId = function (var)
--   Account.m_id = var
-- end
function addPropertyToTable(class, varName, defaultValue, createGetter, createSetter)
    createGetter = (createGetter == nil) or createGetter;
    createSetter = (createSetter == nil) or createSetter;
    local tempName = string.gsub(varName,"m_","");
    local propName = string.upper(string.sub(tempName, 1, 1)) .. (#tempName > 1 and string.sub(tempName, 2, -1) or "")
    class[varName] = defaultValue
    if createGetter then
        class[string.format("get%s", propName)] = function()
            return class[varName] or defaultValue;
        end
    end

    if createSetter then
        class[string.format("set%s", propName)] = function(var)
            class[varName] = var;
            return class
        end
    end
end

local string = string or {}
-- Checks to see if the string starts with the given characters
function string.startsWith(str, chars)
    return chars == '' or string.sub(str, 1, string.len(chars)) == chars
end

-- Checks to see if the string ends with the given characters
function string.endsWith(str, chars)
    return chars == '' or string.sub(str, -string.len(chars)) == chars
end

-- 过滤字符串替换掉要过滤的字符
-- @param str string 待过滤的字符串
-- @param list array 需要替换的 pattern 会有多个
-- {{"pattern1","replStr1"},{"pattern2", "replStr2"},...}
function string.filterStr(str, list)
    if not list then return str end
    for i=1, #list do
        str = string.gsub(str, list[i][1],list[i][2])
    end
    return str
end

-- str 是否为地址
function string.isUrl(str)
    if (not str) then return end
    return string.len(str) > 0 and (string.startsWith(str, "http://") or string.startsWith(str, "https://"))
end

-- str 是否为空
function string.isEmpty(str)
    return (not str or (type(str) == "string" and string.len(str) <= 0))
end

---
-- 转化成 16 进制的字符串
-- @num number lua 数字
function string.toHex(num)
    if not num then
        return ""
    end
    return string.format("0x%x", checknumber(num))
end

-- 随机打算数组
function randomShuffle(array)
    local count = #array
    for i = count, 1, -1 do
        local randomNum = math.random(1, i)
        array[randomNum], array[i] = array[i], array[randomNum]
    end
    return array
end

-- 获取基类的某个方法
-- table C++ 类或者lua table
-- methodName 函数名，也可以是成员变量名
-- return 基类的函数或成员变量值（如果 methodName 为变量名）
--          nil 表示找不到
function getSuperMethod(table, methodName)
    local mt = getmetatable(table)
    local method = nil
    while mt and not method do
        method = mt[methodName]
        if not method then
            local index = mt.__index
            if index and type(index) == "function" then
                method = index(mt, methodName)
            elseif index and type(index) == "table" then
                method = index[methodName]
            end
        end
        mt = getmetatable(mt)
    end
    return method
end

function math.round(value, pointNum)
    value = tonumber(value or 0);

    if value then
        if pointNum then
            return tonumber(string.format("%." .. pointNum .. "f", value));

        else
            return math.floor(value + 0.5)
        end
    end

    return 0;
end

function handlerEx(obj, method)
    if (not obj or tolua.isnull(obj)) then
        return
    end
    return handler(obj, method)
end

-- 获取两个坐标的角度
function math.getAngleByPos(p1, p2)
    local angleA  = 0
    local b       = math.abs(p1.y - p2.y)
    local c       = math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2))
    local radianA = math.acos(b / c)
    local angleA  = 180 / math.pi * radianA
    angleA = math.ceil(angleA)
    return angleA
end

function getVIPAlbum(level)
    if not nk.PlayerManager:getMyself():isSupportVIPFlag() then
        return "";
    end

    if not level then
        return "";
    end

    local user_album = "";

    if nk.Res.Common_vipAlbums[level] then
        user_album = "#" .. nk.Res.Common_vipAlbums[level]
    elseif level and level > 0 then
        user_album = "#" .. nk.Res.Common_vipAlbums[#nk.Res.Common_vipAlbums]
    end


    return user_album;
end

function getVIPChampion(level)
    if not nk.PlayerManager:getMyself():isSupportVIPFlag() then
        return "";
    end

    if not level then
        return "";
    end

    local user_album = "";

    if nk.Res.Common_vipChampions[level] then
        user_album = "#" .. nk.Res.Common_vipChampions[level]
    elseif level and level > 0 then
        user_album = "#" .. nk.Res.Common_vipChampions[#nk.Res.Common_vipChampions]
    end

    return user_album;
end

-- 根据时间戳计算时间
-- return day,hour,minute,surplusSeconds
function getTimeBySeconds(seconds)
    if not seconds then
        return;
    end

    local oneMinute = 60;
    local oneHour = oneMinute * 60;
    local oneDay = oneHour * 24;

    local day = math.floor(seconds / oneDay);

    local surplusSeconds = seconds - day * oneDay;

    if surplusSeconds > 0 then
        local hour = math.floor(surplusSeconds / oneHour)

        surplusSeconds = surplusSeconds - hour * oneHour;

        if surplusSeconds > 0 then
            local minute = math.floor(surplusSeconds / oneMinute)

            surplusSeconds = surplusSeconds - minute * oneMinute;

            if surplusSeconds > 0 then
                return day,hour,minute,surplusSeconds;

            else
                return day,hour,minute;
            end

        else
            return day, hour;
        end

    else
        return day;
    end

end

-- save the node to a file
-- @param node 待保存的节点
-- @param fileName 保存的路径
-- @param size optinal
function nodeToFile(node, fileName, size)
    if (not node or tolua.isnull(node) or not fileName) then return end
    local nodeSize      = size or node:getContentSize()
    if (nodeSize.width <= 0 or nodeSize.height <= 0) then
        LogUtil.d(TAG, "node's width or height is zero, please check the node!")
        return
    end
    local renderTexture = cc.RenderTexture:create(nodeSize.width, nodeSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    renderTexture:begin()
    node:visit()
    renderTexture:endToLua()
    local image    = renderTexture:newImage(true)
    -- local filename = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator .. "test.png"
    image:saveToFile(fileName)
end

-- convert the node to a sprite
-- @param node 待保存的节点
-- @param size optinal
-- @return sprite
function nodeToSprite(node, size)
    if (not node or tolua.isnull(node)) then return end
    local nodeSize      = size or node:getContentSize()
    if (nodeSize.width <= 0 or nodeSize.height <= 0) then
        LogUtil.d(TAG, "node's width or height is zero, please check the node!")
        return
    end
    local renderTexture = cc.RenderTexture:create(nodeSize.width, nodeSize.height, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, gl.DEPTH24_STENCIL8_OES)
    renderTexture:begin()
    node:visit()
    renderTexture:endToLua()
    return renderTexture:getSprite()
end

-- 获取两个坐标的角度
function math.getAngleByPos(p1, p2)
    local angleA  = 0
    local b       = math.abs(p1.y - p2.y)
    local c       = math.sqrt(math.pow(p1.x - p2.x, 2) + math.pow(p1.y - p2.y, 2))
    local radianA = math.acos(b / c)
    local angleA  = 180 / math.pi * radianA
    angleA = math.ceil(angleA)
    return angleA
end

-- c++ 对象是否为空
-- c++ 导出类 一般指节点类
function isCObjEmpty(cobj)
    if not cobj or (type(cobj) == "userdata" and tolua.isnull(cobj)) then
        return true
    end
    return false
end

local NIL = {} -- placeholder value for nil, storable in table.
function pack2(...)
    local n = select('#', ...)
    local t = {...}
    for i = 1,n do
        if t[i] == nil then
            t[i] = NIL
        end
    end
    return t
end

function unpack2(t, k, n)
    k = k or 1
    n = n or #t
    if k > n then return end
    local v = t[k]
    if v == NIL then v = nil end
    return v, unpack2(t, k + 1, n)
end

function isPlatform()
    return device.platform == "android" or device.platform == "ios"
end

local startIndex = 40960 -- 从 40960 开始新增
function getGIndex()
    startIndex = startIndex + 1
    return startIndex
end

function getHeaderData (headerStr)
    local data = {}
    if (string.isEmpty(headerStr)) then
        return data
    end
    local headArray    = string.split(headerStr, "\r\n")
    if (table.isEmpty(headArray)) then
        return data
    end
    for i = 1, #headArray do
        local splitIndex = string.find(headArray[i], ":")
        if (splitIndex) then
            local headerKey = string.sub(headArray[i], 1, splitIndex-1)
            local headerName = string.sub(headArray[i], splitIndex + 2, #headArray[i])
            if (not string.isEmpty(headerKey)) then
                data[headerKey] = headerName
            end
        end
    end
    return data
end

---
-- 牌转换成字符串
-- @cards array 牌的数组（仅支持牌是数组格式的）
-- @return string "{.., ..}"
function cardsToStr(cards)
    local str = ""
    if (table.isEmpty(cards)) then
        return str
    end
    str = "{ "
    for i = 1, #cards do
        if (i == #cards) then
            str = str .. string.toHex(cards[i])
        else
            str = str .. string.toHex(cards[i]) .. ", "
        end
    end
    str = str .. " }"
    return str
end

return GlobalFunction
