-- Author: Jam
-- Date: 2015-04-07

local TimeUtil = class("TimeUtil")

TimeUtil.TIME_DAY         = 86400 -- 24 * 60 * 60
TimeUtil.TIME_HOUR        = 3600  -- 60 * 60
TimeUtil.TIME_MIN         = 60
TimeUtil.SERVER_TIME_ZONE = 7 * TimeUtil.TIME_HOUR

--[[
    将一个时间数转换成"00:00"格式
]]
function TimeUtil:getTimeString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00:00"
    else
        return string.format("%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
    end
end

--[[
    取小时数
]]
function TimeUtil:getTimeMinuteString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", math.floor(timeInt/3600))
    end
end

--[[
    取分钟数
]]
function TimeUtil:getTimeMinuteString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", (timeInt/60)%60)
    end
end

--[[
    取秒数
]]
function TimeUtil:getTimeSecondString(timeInt)
    if (tonumber(timeInt) <= 0) then
        return "00"
    else
        return string.format("%02d", timeInt%60)
    end
end

-- 获取 x 天后剩余秒数
function TimeUtil:getRemainSecondsByDays(days)
    local curTime        = self:getToday()
    local hour           = curTime.hour
    local minutes        = curTime.min
    local curCostSeconds = hour * TimeUtil.TIME_HOUR + minutes * TimeUtil.TIME_MIN + curTime.sec
    local totalDays      = days or 1
    return TimeUtil.TIME_DAY * totalDays - curCostSeconds
end

-- 获取当前日期格式
-- return {
--  hour   时
--  min    分
--  wday   星期几(1 - 7)
--  day    日
--  month  月
--  year   年
--  sec    秒
--  yday   年内天数
--  isdst  是否夏令时
--}
function TimeUtil:getToday()
    local times = os.date("*t",os.time())
    local week = times.wday
    week = week -1
    if week == 0 then
        week = 7
    end
    times.wday = week
    return times
end

-- 将一个时间数转换成"00:00/00:00:00"格式
function TimeUtil:getTimeStringEx(timeInt, showHour)
    local defaultStr =  showHour and "00:00:00" or "00:00"
    if (checknumber(timeInt) <= 0) then
        return defaultStr
    elseif (checknumber(timeInt) < 3600) then
        if (showHour) then
            return string.format("00:%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
        else
            return string.format("%02d:%02d", math.floor((timeInt/60)%60), timeInt%60)
        end
    elseif (checknumber(timeInt) >= 3600) then
        return string.format("%02d:%02d:%02d", math.floor(timeInt / 3600), math.floor((timeInt/60)%60), timeInt%60)
    else
        return defaultStr
    end
end


-- 获取时间数据
-- {hour = "00", minute = "60", second = "28"}
function TimeUtil:getTimeData(timeInt)
    local timeStr  = self:getTimeStringEx(timeInt)
    local timeList = string.split(timeStr, ":")
    local hour, minute, second = "00", "00", "00"
    if (#timeList > 2) then
        hour   = timeList[1]
        minute = timeList[2]
        second = timeList[3]
    else
        minute = timeList[1]
        second = timeList[2]
    end
    return {hour = hour, minute = minute, second = second}
end

---
-- 通过秒数获取剩余天数和秒数 xx day xxx seconds
-- @return table {days = xx, seconds = xx}
--   @field number days 天数
--   @field number seconds 秒数
function TimeUtil:getDaysAndSecondes (seconds)
    if (not seconds or seconds <= 0) then
        return {days = 0, seconds = 0}
    end
    local remainDays    = 0
    local remainSeconds = 0
    remainDays = math.floor(seconds / TimeUtil.TIME_DAY)
    remainSeconds = seconds % TimeUtil.TIME_DAY
    return {days = remainDays, seconds = remainSeconds}
end

---
-- 设置服务器的时区
function TimeUtil:setServerTimeZone (timeZone)
    if (timeZone) then
        TimeUtil.SERVER_TIME_ZONE = timeZone * TimeUtil.TIME_HOUR
    end
end

-- 获取客户端本地时区
-- @return number seconds 本地的当前时区
function TimeUtil:getLocalTimeZone()
    local now = os.time()
    local localTimeZone = os.difftime(now, os.time(os.date("!*t", now)))
    local isdst = os.date("*t", now).isdst
    if isdst then localTimeZone = localTimeZone + TimeUtil.TIME_HOUR end
    return localTimeZone
end

-- 替代os.date函数，忽略本地时区设置，按服务器时区格式化时间
-- @param format: 同os.date第一个参数
-- @param timestamp:服务器时间戳
function TimeUtil:Date(format, timestamp)
    local timeZoneDiff = TimeUtil.SERVER_TIME_ZONE - self:getLocalTimeZone()
    return os.date(format, timestamp + timeZoneDiff)
end

-- 替代os.time函数，忽略本地时区设置，返回服务器时区时间戳
-- @param timedata: 服务器时区timedate
function TimeUtil:Time( timedate )
    local timeZoneDiff = TimeUtil.SERVER_TIME_ZONE - self:getLocalTimeZone()
    return os.time(timedate) - timeZoneDiff
end

return TimeUtil
