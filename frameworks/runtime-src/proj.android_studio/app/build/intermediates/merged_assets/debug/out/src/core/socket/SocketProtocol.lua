local SocketProtocol = class("SocketProtocol");

SocketProtocol.cmd = {};

SocketProtocol.CLIENT_CONFIG = {};

SocketProtocol.SERVER_CONFIG = {};

SocketProtocol.DELAY_CONFIG = {};

SocketProtocol.DELAY_INTERUPT_CONFIG = {};

function SocketProtocol:ctor()

end

function SocketProtocol:getClientConfig(tempCmd)
	return SocketProtocol.CLIENT_CONFIG[tempCmd];
end

function SocketProtocol:getServerConfig(tempCmd)
	return SocketProtocol.SERVER_CONFIG[tempCmd];
end

function SocketProtocol:getDelayConfig(tempCmd)
	return SocketProtocol.DELAY_CONFIG[tempCmd];
end

function SocketProtocol:getDelayInteruptConfig(tempCmd)
    return SocketProtocol.DELAY_INTERUPT_CONFIG[tostring(tempCmd)];
end

function SocketProtocol:dtor()

end

return SocketProtocol;