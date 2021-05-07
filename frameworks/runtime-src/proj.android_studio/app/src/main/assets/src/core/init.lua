--[[
    Class Name        	: poker
    description       	: to wrap Some core Class.
    author            	: ClarkWu
    create-date       	: 2016/08/08
]]
local CURRENT_MODULE_NAME = ...;

poker                       = poker or {};
poker.PACKAGE_NAME          = string.sub(CURRENT_MODULE_NAME, 1, -6);
poker.Logger                = require(poker.PACKAGE_NAME .. ".util.Logger");
poker.HttpService           = require(poker.PACKAGE_NAME .. ".http.HttpService");
poker.ImageLoader           = require(poker.PACKAGE_NAME .. ".http.ImageLoader");
poker.ActivityImgLoader     = require(poker.PACKAGE_NAME .. ".http.ActivityImgLoader");
poker.TouchHelper           = require(poker.PACKAGE_NAME .. ".util.TouchHelper");
poker.LangUtil              = require(poker.PACKAGE_NAME .. ".util.LangUtil").new();
poker.SchedulerPool         = require(poker.PACKAGE_NAME .. ".util.SchedulerPool");
poker.TimeUtil              = require(poker.PACKAGE_NAME .. ".util.TimeUtil").new()
poker.SocketService         = require(poker.PACKAGE_NAME .. ".socket.SocketService");
poker.DataProxy             = require(poker.PACKAGE_NAME .. ".proxy.DataProxy");
poker.EventCenter           = require(poker.PACKAGE_NAME .. ".event.EventCenter");

require(poker.PACKAGE_NAME .. ".util.functions").exportMethods(poker);
require(poker.PACKAGE_NAME .. ".displayEx")

return poker;
