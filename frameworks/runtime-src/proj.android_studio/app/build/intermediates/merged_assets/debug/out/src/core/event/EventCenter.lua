-- Author: Jam
-- Date: 2015.04.28
--[[
    全局事件管理类
    用法:
        local eventHandle = poker.EventCenter:addEventListener("EVENT_NAME", handler(self, self.handle), 1)
        poker.EventCenter:hasEventListener("EVENT") -- 目前有bug，等待修复
        poker.EventCenter:dispatchEvent({name = "EVENT_NAME", data = {"a", "b"}, ...可自定义})
        poker.EventCenter:removeEventListener(eventHandle)

        function handle(event)
            print(event.name)
            event.stop() --  停止后续的派发
        end

]]

local EventCenter = class("EventCenter")
local CURRENT_MODULE_NAME = ...

function EventCenter:ctor()
    self.eventObject_ = import(".EventObject", CURRENT_MODULE_NAME).new()
end

-- 侦听一个事件，返回一个唯一的数字字符
function EventCenter:addEventListener(eventName, listener, tag)
    return self.eventObject_:addEventListener(eventName, listener, tag)
end

-- 派发事件
function EventCenter:dispatchEvent(eventObj)
    if type(eventObj) == "string" then
        eventObj = {name = string.upper(tostring(eventObj))}
    end
    return self.eventObject_:dispatchEvent(eventObj)
end

-- 移除某一事件，handlToRemove是由addEventListener返回一个唯一字符
function EventCenter:removeEventListener(handleToRemove)
    assert(type(handleToRemove) == "string" and handleToRemove ~= "", "EventCenter:removeEventListener() - invalid handleToRemove, should be a string")
    return self.eventObject_:removeEventListener(handleToRemove)
end

-- 移除由该tag标记的所有侦听
function EventCenter:removeEventListenersByTag(tagToRemove)
    return self.eventObject_:removeEventListenersByTag(tagToRemove)
end

-- 移除某一事件的所有侦听
function EventCenter:removeEventListenersByEvent(eventName)
    return self.eventObject_:removeEventListenersByEvent(eventName)
end

-- 检测是否已经侦听某个事件
function EventCenter:hasEventListener(eventName)
    return self.eventObject_:hasEventListener(eventName)
end

--  打印所有事件
function EventCenter:dumpAllEventlisteners()
    return self.eventObject_:dumpAllEventListeners()
end

return EventCenter.new()
