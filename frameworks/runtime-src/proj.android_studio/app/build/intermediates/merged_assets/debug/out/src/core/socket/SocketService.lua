--[[
     Socket基类
     Desc  : 封装Socket相关的方法
     Author: ClarkWu
     Date  : 2016.09.30
]]
cc.sockets = require("framework.cc.utils.init");
cc.net = require("framework.cc.net.init");

local PacketBuilder = import(".PacketBuilder");
local PacketParser = import(".PacketParser");

local SocketService = class("SocketService");

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler");

-- 定义事件
SocketService.EVT_PACKET_RECEIVED = "SocketService.EVT_PACKET_RECEIVED";    -- 收到包体
SocketService.EVT_CONN_SUCCESS    = "SocketService.EVT_CONN_SUCCESS";       -- 连接成功
SocketService.EVT_CONN_FAIL       = "SocketService.EVT_CONN_FAIL";          -- 连接失败
SocketService.EVT_ERROR           = "SocketService.EVT_ERROR";              -- 连接异常
SocketService.EVT_CLOSED          = "SocketService.EVT_CLOSED";             -- 连接关闭
SocketService.EVT_CLOSE           = "SocketService.EVT_CLOSE";              -- 连接正在关闭

-- Socket计数器
local SOCKET_ID = 1;

local logger = poker.Logger.new("SocketService");

--[[
    @ Constructor
    @ param : protocol    : 协议类
]]
function SocketService:ctor(protocol)
    cc(self):addComponent("components.behavior.EventProtocol"):exportMethods();

    self.m_protocol = protocol;                            -- 协议类
    self.m_packerParser = PacketParser.new(protocol);      -- 解包器
    self.m_socketReceiver = nil;
end

function SocketService:setProtocol(protocol)
    self.m_protocol = protocol;
    self.m_packerParser:setProtocol(protocol);
end

function SocketService:setSocketReceiver(receiver)
    self.m_socketReceiver = receiver;
end

--[[
    创建包体方法
    @ param  : cmd  命令字
    @ return : 包体
]]
function SocketService:createPacketBuilder(cmd)
    if self.m_protocol:getClientConfig(cmd) then
        return PacketBuilder.new(cmd, self.m_protocol);
    end
end

--[[
    得到当前的Socket
    @return : self.m_socket
]]
function SocketService:getSocketTCP()
    return self.m_socket;
end

function SocketService:getFailedMsg()
    if self.m_socket then
        return self.m_socket:getFailedMsg();
    end
end

--[[
    设置Socket名称(没有则默认SocketTCP)
    @ param : name  String
]]
function SocketService:setName(name)
    self.m_socket:setName(name);
end

--[[
    Socket连接方法
    @ param : host                      : ip
              post                      : port
              retryConnectWhenFailure   : 连接失败是否重连
]]
function SocketService:connect(host, port, retryConnectWhenFailure)
    self:disconnect();

    if not self.m_socket then
        SOCKET_ID = SOCKET_ID + 1;
        self.m_socket = cc.net.SocketTCP.new(host, port, retryConnectWhenFailure or false);
        self.m_socket.socketId = SOCKET_ID;

        -- 注册事件
        self.m_socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECTED, handler(self, self.onConnected));
        self.m_socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSE, handler(self, self.onClose));
        self.m_socket:addEventListener(cc.net.SocketTCP.EVENT_CLOSED, handler(self, self.onClosed));
        self.m_socket:addEventListener(cc.net.SocketTCP.EVENT_CONNECT_FAILURE, handler(self, self.onConnectFailure));
        self.m_socket:addEventListener(cc.net.SocketTCP.EVENT_DATA, handler(self, self.onData));
    end

    self.m_socket:connect();
end

--[[
    Socket断开连接方法
    @param noEvent Boolean
            true   表示需要移除事件，再断开连接
            false  先断开连接，后移除事件
]]
function SocketService:disconnect(noEvent)
    if self.m_socket then
        local socket = self.m_socket;
        self.m_socket = nil;

        if noEvent then
            socket:removeAllEventListeners();
            socket:disconnect();
        else
            socket:disconnect();
            socket:removeAllEventListeners();
        end
    end
end

--[[
    Socket 向服务器发送数据
    @param data String
                PacketBuilder 一般都是包体
]]
function SocketService:send(data)
    if self.m_socket then
        if type(data) == "string" then
            self.m_socket:send(data);
        else
            self.m_socket:send(data:getPack());
        end
    end
end

--[[
    @ 接收响应 --> cc.net.SocketTCP.EVENT_CONNECTED
    连接成功后
]]
function SocketService:onConnected(evt)
    if not evt then
        sendClientLog("SocketService:onConnected()")

    else
        sendClientLog(string.format("SocketService:onConnected(evt socketId = %s, name = %s)",evt.target.socketId,
            evt.name))
    end

    -- 包解析器重置
    self.m_packerParser:reset();
    self:dispatchEvent({name = SocketService.EVT_CONN_SUCCESS});
end

--[[
    @ 接收响应 --> cc.net.SocketTCP.EVENT_CLOSE
    连接即将关闭
]]
function SocketService:onClose(evt)
    if not evt then
        sendClientLog("SocketService:onClose()")

    else
        sendClientLog(string.format("SocketService:onClose(evt socketId = %s, name = %s)",evt.target.socketId,
            evt.name))
    end

    self:dispatchEvent({name = SocketService.EVT_CLOSE});
end

--[[
    @ 接收响应 --> cc.net.SocketTCP.EVENT_CLOSED
    连接关闭
]]
function SocketService:onClosed(evt)
    if not evt then
        sendClientLog("SocketService:onClosed()")

    else
        sendClientLog(string.format("SocketService:onClosed(evt socketId = %s, name = %s)",evt.target.socketId,
            evt.name))
    end

    self:dispatchEvent({name = SocketService.EVT_CLOSED});
end

--[[
    @ 接收响应 --> cc.net.SocketTCP.EVENT_CONNECT_FAILURE
    连接服务器失败
]]
function SocketService:onConnectFailure(evt)
    if not evt then
        sendClientLog("SocketService:onConnectFailure()")

    else
        sendClientLog(string.format("SocketService:onConnectFailure(evt socketId = %s, name = %s)",evt.target.socketId,
            evt.name))
    end

    self:dispatchEvent({name = SocketService.EVT_CONN_FAIL});
end

--[[
    @ 接收响应 --> cc.net.SocketTCP.EVENT_DATA
    服务器接收到数据
]]
function SocketService:onData(evt)
    if not evt then
        sendClientLog("SocketService:onData()")

    else
        local isMonitor = false

        if evt.data then
            isMonitor = evt.data.isMonitor
        end

        if not isMonitor then
            pcall(function()
                sendClientLog(string.format("SocketService:onData(evt data = %s)",
                    cc.sockets.ByteArray.toString(evt.data, 16)))
            end)
        end
    end

    local isMonitor = evt.data.isMonitor

    if isMonitor then
        if self.m_socketReceiver then
            local event = {data = evt.data}
            event.extData = evt.extData or {}
            self.m_socketReceiver:onPacketReceived(event)
        end
        return
    end

    local buf = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG);
    buf:writeBuf(evt.data);
    buf:setPos(1);

    local skipDecode = evt.skipDecode and true or false
    local success, packets = self.m_packerParser:read(buf,skipDecode);

    if not success then
        self:dispatchEvent({name = SocketService.EVT_ERROR});
    else
        local needOtherDispathPacket = {};

        local needEndSocketFlag = false;

        for i,v in ipairs(packets) do
            if v and v.cmd then
                -- if v.cmd == 0x4003 or v.cmd == 0x1052 or v.cmd == 0x4004 then
                --     if not needEndSocketFlag then
                --         needOtherDispathPacket[#needOtherDispathPacket + 1] = v;
                --     else
                --         if self.m_socketReceiver then
                --             local event = {data = v};
                --             self.m_socketReceiver:onPacketReceived(event);
                --         end
                --     end
                -- else
                    if self.m_socketReceiver then
                        v.extData = evt.extData or {}
                        local event = {data = v};
                        self.m_socketReceiver:onPacketReceived(event);
                    end
                -- end
            end
       end

       self:executeBetAnim(needOtherDispathPacket);
    end
end

function SocketService:executeBetAnim(needOtherDispathPacket)
    local isRepeatFlag = false;

    for i =1 ,#needOtherDispathPacket do
        if self.m_socketReceiver then
            local event = {data = needOtherDispathPacket[i]};
            self.m_socketReceiver:onPacketReceived(event);
            isRepeatFlag = true;
            needOtherDispathPacket[i] = nil;
            table.remove(needOtherDispathPacket,i);
            break;
        end
    end

    if isRepeatFlag then
        scheduler.performWithDelayGlobal(function()
            self:executeBetAnim(needOtherDispathPacket);
        end,0.0001);
    end

end

return SocketService