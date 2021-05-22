local BridgeAdapter = class("BridgeAdapter")

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

function BridgeAdapter:ctor()
end

function BridgeAdapter:getInitThings()
    return ""
end

function BridgeAdapter:showAlertDialog(params)
    scheduler.performWithDelayGlobal(function()
    	if params.cancelFunc then 
    		params.cancelFunc()
    	end

    	dump(params, "params")
    end, 5)
end

return BridgeAdapter