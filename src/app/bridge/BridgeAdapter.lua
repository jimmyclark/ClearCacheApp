local BridgeAdapter = class("BridgeAdapter")

function BridgeAdapter:ctor()
end

function BridgeAdapter:getInitThings()
    return ""
end

function BridgeAdapter:showAlertDialog(params)
    dump(params, "params")
end

return BridgeAdapter