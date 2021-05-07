-- Author: Jam
-- Date: 2015.04.28

local EventObject = class("EventObject")

function EventObject:ctor()
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods()
end

return EventObject
