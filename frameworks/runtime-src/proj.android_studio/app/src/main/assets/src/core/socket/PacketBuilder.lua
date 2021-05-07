--[[
     封类
     Desc  : 封装Socket解包的方法
     Author: ClarkWu
     Date  : 2016.09.30
]]
local TYPE = import(".PACKET_DATA_TYPE");
local SocketKeycode = import(".SocketKeycode").new();
local PacketBuilder = class("PacketBuilder");

local logger = poker.Logger.new("PacketBuilder");

--[[
    @ Constructor
    @ param : cmd     : 协议名称
              protocol: 协议类 继承自SocketProtocol
]]
function PacketBuilder:ctor(cmd, protocol)
    self.m_cmd   = cmd;
    self.m_protocol = protocol;
    self.m_params = {};
end

function PacketBuilder:setProtocol(protocol)
    self.m_protocol = protocol;
end

--[[
    设置变量
    @ param : key value    键值对(发送给Server的参数)
]]
function PacketBuilder:setParameter(key, value)
    self.m_params[key] = value;
    return self;
end

--[[
    设置多个变量
    @ params : Table 键值对Table(发送给Server的参数)
]]
function PacketBuilder:setParameters(params)
    table.merge(self.m_params, params);
    return self;
end

function PacketBuilder:getBuf()
    local buf = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG)
    buf:setPos(1)
    return buf
end

--[[
    封包方法
]]
function PacketBuilder:build(buffer)
    -- 写数据方法
    local function writeData(buf, dtype, val, fmt)
        if dtype == TYPE.UBYTE then
            if type(val) == "string" and string.len(val) == 1 then
            else
                buf:writeUByte(tonumber(val) or 0);
            end

        elseif dtype == TYPE.BYTE then
            if type(val) == "string" and string.len(val) == 1 then
                buf:writeChar(val);

            else
                local n = tonumber(val);

                if n and n < 0 then
                    n = n + 2^8;
                end

                buf:writeByte(n or 0);
            end

        elseif dtype == TYPE.INT then
            buf:writeInt(tonumber(val) or 0);

        elseif dtype == TYPE.UINT then
            buf:writeUInt(tonumber(val) or 0);

        elseif dtype == TYPE.SHORT then
            buf:writeShort(tonumber(val) or 0);

        elseif dtype == TYPE.USHORT then
            buf:writeUShort(tonumber(val) or 0);

        elseif dtype == TYPE.LONG then
            val = tonumber(val) or 0;
            local low = val%2^32;
            local high = val/2^32;
            buf:writeInt(high);
            buf:writeUInt(low);

        elseif dtype == TYPE.ULONG then
            val = tonumber(val) or 0;
            local low = val%2^32;
            local high = val/2^32;
            buf:writeInt(high);
            buf:writeUInt(low);

        elseif dtype == TYPE.STRING then
            val = tostring(val) or "";
            buf:writeUInt(#val + 1);
            buf:writeStringBytes(val);
            buf:writeByte(0);

        elseif dtype == TYPE.ARRAY then
            local len = 0;

            if val then
                len = #val;
            end

            if fmt.lengthType then
                if fmt.lengthType == TYPE.UBYTE then
                    buf:writeUByte(len);

                elseif fmt.lengthType == TYPE.BYTE then
                    buf:writeByte(len);

                elseif fmt.lengthType == TYPE.INT then
                    buf:writeInt(len);

                elseif fmt.lengthType == TYPE.UINT then
                    buf:writeUInt(len);

                elseif fmt.lengthType == TYPE.LONG then
                    local low = len%2^32;
                    local high = len/2^32;
                    buf:writeInt(high);
                    buf:writeUInt(low);

                elseif fmt.lengthType == TYPE.ULONG then
                    local low = len%2^32;
                    local high = len/2^32;
                    buf:writeInt(high);
                    buf:writeUInt(low);
                end

            else
                buf:writeUByte(len);
            end

            if len > 0 then
                for i1,v1 in ipairs(val) do
                    for i2,v2 in ipairs(fmt) do
                        local name = v2.name;
                        local dtype = v2.type;
                        local fmt = v2.fmt;
                        local value = v1[name];
                        writeData(buf, dtype, value, fmt);
                    end
                end
            end
        end
    end

    local buf = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG);
    buf:setPos(1);

    -- 包头定义
    -- buf:writeInt(4);                -- 包长度 整体长度-4
    -- buf:writeStringBytes("QE");     -- magic word.QE
    -- buf:writeChar(0x01);            -- 版本 0x01
    -- buf:writeChar(0);               -- 额外数据长度
    -- buf:writeInt(self.m_cmd);       -- 命令字
    -- buf:writeShort(1);              -- 游戏Id
    -- buf:writeChar(1);               -- 校验码

    -- buf:writeStringBytes("IC");         -- IC       2
    -- buf:writeUShort(self.m_cmd);        -- 命令字    2
    -- -- 版本号
    -- buf:writeByte(2);                    --主板本号      1
    -- buf:writeByte(1);                    --子版本号      1
    -- buf:writeUShort(0);                  --包体长度      2
    -- buf:writeByte(0);
    -- buf:writeInt(0);

    if self.m_protocol and self.m_protocol:getClientConfig(self.m_cmd) and self.m_protocol:getClientConfig(self.m_cmd).fmt and #self.m_protocol:getClientConfig(self.m_cmd).fmt > 0 then
        -- 写包体
        for i,v in ipairs(self.m_protocol:getClientConfig(self.m_cmd).fmt) do
            local name = v.name;
            local dtype = v.type;
            local fmt = v.fmt;
            local value = self.m_params[name];

            if value then
                writeData(buf, dtype, value, fmt);
            end
        end

    elseif self.m_protocol and self.m_protocol:getClientConfig(self.m_cmd) and self.m_protocol:getClientConfig(self.m_cmd).freedom then
        buf = buffer

    else
        buf = self:getBuf()

        -- -- 修改包体长度
        -- buf:setPos(1);
        -- buf:writeInt(buf:getLen() - 4);
        -- buf:setPos(buf:getLen() + 1);
    end
    -- local byteCount = bit.bnot(buf:getLen()) + 1;

    -- local byteCount = bit.bnot(buf:getLen()) + 1;
    local byteCount = 0;

    buf:setPos(1);

    local byteList = {};

    for i = 1, #buf._buf do
        local tmpBit = string.byte(buf:readRawByte());
        byteCount = byteCount + tmpBit;
        byteList[i] = SocketKeycode:encode(tmpBit + 1);
    end

    local result = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG);

    result:setPos(1);

    -- 将byteCount 强制转换成byte
    local strByteCount = string.format("%x",byteCount);

    strByteCount = string.sub(strByteCount,string.len(strByteCount) - 1,string.len(strByteCount));

    strByteCount = tonumber(string.format("%d","0x"..strByteCount));

    -- print("取反前:包体" ..  string.format("%x",strByteCount) .. ";取反后:长度 " .. string.format("%x",bit.bnot(strByteCount) ));

    strByteCount = bit.bnot(strByteCount) + 1;

    local random = math.random(0,1000);

    -- 包头定义
    result:writeInt(4);                                   -- 包长度 整体长度      4
    result:writeChar(nk.Const.SOCKET_MAGIC_WORD[1]);      -- magic word           2
    result:writeChar(nk.Const.SOCKET_MAGIC_WORD[2]);
    result:writeShort(1);                                 -- 游戏Id               2
    result:writeChar(nk.Const.SOCKET_VERSION);            -- 版本 0x01            1
    result:writeInt(bit.bxor(self.m_cmd,random));         -- 命令字               4
    result:writeShort(random);                            -- 随机数               2
    result:writeChar(strByteCount);                       -- 校验码               1

    for j = 1,#byteList do
        if byteList[j] then
            result:writeByte(byteList[j]);
        end
    end

    result:setPos(1);
    result:writeInt(result:getLen());
    result:setPos(result:getLen() + 1);

    logger:debugf(string.format("BUILD Encode PACKET ==> %x(%s)[%s]", self.m_cmd, result:getLen(), cc.sockets.ByteArray.toString(result, 16)));
    return result;
end

function socket_write_byte(buf, val)
    if not buf then
        return
    end

    if type(val) == "string" and string.len(val) == 1 then
        buf:writeChar(val)

    else
        local n = tonumber(val)

        if n and n < 0 then
            n = n + 2^8
        end

        buf:writeByte(n or 0)
    end

    return buf
end

function socket_write_int(buf, val)
    if not buf then
        return
    end

    buf:writeInt(tonumber(val) or 0)

    return buf
end

function socket_write_short(buf, val)
    if not buf then
        return
    end

    buf:writeShort(tonumber(val) or 0)

    return buf
end

function socket_write_long(buf, val)
    if not buf then
        return
    end

    val = tonumber(val) or 0
    local low = val%2^32
    local high = val/2^32
    buf:writeInt(high)
    buf:writeUInt(low)

    return buf
end

function socket_write_string(buf, val)
    if not buf then
        return
    end

    val = tostring(val) or ""
    buf:writeUInt(#val + 1)
    buf:writeStringBytes(val)
    buf:writeByte(0)

    return buf
end

return PacketBuilder