--[[
     解包类
     Desc  : 封装Socket解包的方法
     Author: ClarkWu
     Date  : 2016.09.30
]]
local TYPE = import(".PACKET_DATA_TYPE");

local PacketParser = class("PacketParser");

local logger = poker.Logger.new("PacketParser");

local SocketKeycode = import(".SocketKeycode").new();

local HEAD_LEN = 16; -- 包头长度

--[[
    @ Constructor
    @ protocol    继承SocketProtocol的一个协议类
]]
function PacketParser:ctor(protocol)
    self.m_protocol = protocol;
    self.m_buf = nil;
end

function PacketParser:setProtocol(protocol)
    self.m_protocol = protocol;
end

--[[
    -- 重置包体
]]
function PacketParser:reset()
    self.m_buf = nil;
end

--[[
    读取包体内容
    @param  : buf 包体内容
    @param  : skipDecode 跳过解密
    @return : Boolean
              true  --> 读取成功
              false --> 读取失败
]]
function PacketParser:read(buf, skipDecode)

    -- 校验包头，并返回包体长度与命令字,校验不通过则都返回-1
    local function verifyHeadAndGetBodyLenAndCmd(buf)
        local cmd = -1;
        local len = -1;
        local pos = buf:getPos();
        buf:setPos(1);
        -- 包体长度
        local tempLen = buf:readInt();
        local headStr1 = buf:readChar(1);
        local headStr2 = buf:readChar(1);
        local gameId  = buf:readShort(1);
        local version = buf:readChar(1);
        local tempCmd = buf:readInt(1);
        local tempRandom = buf:readShort(2);

        if headStr1 == nk.Const.SOCKET_MAGIC_WORD[1] and
           headStr2 == nk.Const.SOCKET_MAGIC_WORD[2] and
           version == nk.Const.SOCKET_VERSION then
            cmd = bit.bxor(tempCmd, tempRandom);
            len = tempLen - HEAD_LEN;
        end

        buf:setPos(pos);
        return cmd,len;
    end

    local ret = {};
    local success = true;

    while true do
        if not self.m_buf then
            self.m_buf = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG);
        else
            self.m_buf:setPos(self.m_buf:getLen() + 1);
        end

        local available = buf:getAvailable();
        local buffLen = self.m_buf:getLen();

        if available <= 0 then
            break;
        else
            local headCompleted = (buffLen >= HEAD_LEN);

            -- 先收包头
            if not headCompleted then
                -- 收到完整包头，按包头长度写入缓冲区
                if available + buffLen >= HEAD_LEN then
                    for i = 1, HEAD_LEN - buffLen do
                        self.m_buf:writeRawByte(buf:readRawByte());
                    end
                    headCompleted = true;

                -- 不够完整包头，把全部内容写入缓冲区
                else
                    for i = 1, available do
                        self.m_buf:writeRawByte(buf:readRawByte());
                    end

                    break;
                end
            end

            -- 包头已经完整，取包体长度并校验包头
            if headCompleted then
                local command, bodyLen = verifyHeadAndGetBodyLenAndCmd(self.m_buf);

                -- 无包体，直接返回一个只有cmd字段的table，并重置缓冲区
                if bodyLen == 0 then
                    ret[#ret + 1] = {cmd = command};

                    self:reset();

                 -- 有包体
                elseif bodyLen > 0 then
                    available = buf:getAvailable();
                    buffLen = self.m_buf:getLen();

                    if available <= 0 then
                        break;

                    -- 收到完整包，向缓冲区补齐当前包剩余字节
                    elseif available + buffLen >= HEAD_LEN + bodyLen then
                        for i = 1, HEAD_LEN + bodyLen - buffLen do
                            local encodeBuf = string.byte(buf:readRawByte());
                            if (skipDecode) then
                                self.m_buf:writeByte(encodeBuf);
                            else
                                self.m_buf:writeByte(SocketKeycode:decode(encodeBuf + 1));
                            end
                        end

                        -- 开始解析
                        local packet = self:parsePacket(self.m_buf);

                        if packet then
                            ret[#ret + 1] = packet;
                        end

                        -- 重置缓冲区
                        self:reset();

                    --  不够包体长度，全部内容写入缓冲区
                    else
                        for i = 1, available do
                            local encodeBuf = string.byte(buf:readRawByte());
                            if (skipDecode) then
                                self.m_buf:writeByte(encodeBuf);
                            else
                                self.m_buf:writeByte(SocketKeycode:decode(encodeBuf + 1));
                            end
                        end
                        break;
                    end
                -- 包头校验失败
                else
                    return false, "PACKAGE HEAD VERIFY ERROR,"..cc.sockets.ByteArray.toString(self.m_buf, 16);
                end
            end
        end
    end

    return true, ret;
end

--[[
    读取包体数据
]]
function PacketParser:readData(ctx, buf, dtype, thisFmt)
    local ret;

    if buf:getAvailable() <= 0 and thisFmt.optional then
        return nil;
    end

    if not buf then
        return;
    end

    if dtype == TYPE.UBYTE then
        ret = buf:readUByte();

        if ret < 0 then
            ret = ret + 2^8;
        end

    elseif dtype == TYPE.BYTE then
        local ret,errMsg = pcall(function()
            ret = buf:readByte();

            if ret > 2^7 - 1 then
                ret = ret - 2^8;
            end
        end);

        if not ret then
            return
        end

    elseif dtype == TYPE.INT then
        ret = buf:readInt();

    elseif dtype == TYPE.UINT then
        ret = buf:readUInt();

    elseif dtype == TYPE.SHORT then
        ret = buf:readShort();

    elseif dtype == TYPE.USHORT then
        ret = buf:readUShort();

    elseif dtype == TYPE.LONG then
        local high = buf:readInt();
        local low = buf:readUInt();
        ret = high * 2^32 + low;

    elseif dtype == TYPE.ULONG then
        local high = buf:readInt();
        local low = buf:readUInt();
        ret = high * 2^32 + low;

    elseif dtype == TYPE.STRING then
        local len = buf:readUInt();
        local pos = buf:getPos();
        buf:setPos(pos + len - 1);
        local lastByte = buf:readByte();
        buf:setPos(pos);

        -- 防止server出尔反尔，个别协议中出现字符串不以\0结尾的情况，这里做个判断
        if lastByte == 0 then
            ret = buf:readStringBytes(len - 1);
            buf:readByte(); -- 消费掉最后一个字节
        else
            ret = buf:readStringBytes(len);
        end

    elseif dtype == TYPE.ARRAY then
        ret = {};
        local contentFmt = thisFmt.fmt;

        -- 配置文件中未指定长度，从包体中得到
        if not thisFmt.fixedLength then
            -- 配置文件中指定了长度字段的类型
            if thisFmt.lengthType then
                if thisFmt.lengthType == TYPE.UBYTE then
                    logger:debug("read ubyte length");
                    len = buf:readUByte();

                elseif thisFmt.lengthType == TYPE.BYTE then
                    logger:debug("read byte length");
                    len = buf:readByte();

                elseif thisFmt.lengthType == TYPE.INT then
                    logger:debug("read int length");
                    len = buf:readInt();

                elseif thisFmt.lengthType == TYPE.UINT then
                    logger:debug("read uint length");
                    len = buf:readUInt();

                elseif thisFmt.lengthType == TYPE.LONG then
                    logger:debug("read long length");
                    local high = buf:readInt();
                    local low = buf:readUInt();
                    len = high * 2^32 + low;

                elseif thisFmt.lengthType == TYPE.ULONG then
                    logger:debug("read ulong length");
                    local high = buf:readInt();
                    local  low = buf:readUInt();
                    len = high * 2^32 + low;
                end

            -- 未指定长度字段类型，默认按照无符号byte类型读
            else
                len = buf:readUByte();
            end

        -- 配置文件中直接指定了长度
        else
            len = thisFmt.fixedLength;
        end

        if len > 0 then
            if #contentFmt == 1 then
                local dtype = contentFmt[1].type;

                for i = 1,len do
                    if contentFmt[1].depends then
                        if contentFmt[1].depends(ctx) then
                            ret[#ret + 1] = self:readData(ctx, buf, dtype, contentFmt[1]);
                        end

                    else
                        ret[#ret + 1] = self:readData(ctx, buf, dtype, contentFmt[1]);
                    end
                end

            elseif #contentFmt == 0 and contentFmt.type then
                for i = 1, len  do
                   if contentFmt.depends then
                        if contentFmt.depends(ctx) then
                            ret[#ret + 1] = self:readData(ctx, buf, contentFmt.type, contentFmt);
                        end

                   else
                        ret[#ret + 1] = self:readData(ctx, buf, contentFmt.type, contentFmt);
                   end
                end

            else
                for i = 1, len do
                    local ele = {};
                    ret[#ret + 1] = ele;
                    for i,v in ipairs(contentFmt) do
                        local name = v.name;
                        local dtype = v.type;
                        if v and v.depends then
                            if v.depends(ctx, ele) then
                                ele[name] = self:readData(ctx, buf, dtype, v);
                            end

                        else
                            ele[name] = self:readData(ctx, buf, dtype, v);
                        end
                    end
                end
            end
        end
    end

    return ret;
end

--[[
    解析包体内容
    @param  : buf 包体内容
]]
function PacketParser:parsePacket(buf)
    logger:normalPrint("[PACK_PARSE] len:" .. buf:getLen() .. "[" .. cc.sockets.ByteArray.toString(buf, 16) .. "]");

    local ret = {};
    local cmd = buf:setPos(10):readInt();
    local random = buf:setPos(14):readShort();

    local tempCmd = bit.bxor(cmd, random);

    logger:normalPrint("tempCmd:" .. (tempCmd or "nil"))

    local config = self.m_protocol:getServerConfig(tempCmd);
    if not config then
        logger:normalPrint("Config ERROR" .. tempCmd);
        return;
    end

    if config.freedom then
        ret.cmd = tempCmd;
        buf:setPos(HEAD_LEN + 1);
        ret.buf = buf;
        return ret;
    end

    if config and not config.freedom then
        local fmt = config.fmt;
        --if ver ~= 1 then
        --    fmt = config["fmt" .. ver]
        --end
        buf:setPos(HEAD_LEN + 1);

        if type(fmt) == "function" then
            fmt(ret, buf);

        elseif fmt then
            for i,v in ipairs(fmt) do
                local name = v.name;
                local dtype = v.type;
                local depends = v.depends;

                if depends then
                    if depends(ret) then
                        local fpos = buf:getPos();
                        ret[name] = self:readData(ret, buf, dtype, v);
                        local epos = buf:getPos();

                        if type(ret[name]) == "table" then
                            logger:debug(string.format("[%03d-%03d][%03d]%s=%s", fpos, epos - 1, epos - fpos, name, json.encode(ret[name])));
                        else
                            logger:debug(string.format("[%03d-%03d][%03d]%s=%s", fpos, epos - 1, epos - fpos, name, ret[name]));
                        end

                        buf:setPos(epos);
                    end

                else
                    local fpos = buf:getPos();
                    ret[name] = self:readData(ret, buf, dtype, v);
                    local epos = buf:getPos();

                    if type(ret[name]) == "table" then
                         logger:debug(string.format("[%03d-%03d][%03d]%s=%s", fpos, epos - 1, epos - fpos, name, json.encode(ret[name])));
                    else
                         logger:debug(string.format("[%03d-%03d][%03d]%s=%s", fpos, epos - 1, epos - fpos, name, ret[name]));
                    end

                    buf:setPos(epos);
                end
            end
        end

        if buf:getLen() ~= buf:getPos() - 1 and DEBUG > 0 then
            logger:debug(string.format("PROTOCOL ERROR !!!! %x bufLen:%s pos:%s [%s]", tempCmd, buf:getLen(), buf:getPos(), cc.sockets.ByteArray.toString(buf, 16)));
        end

        ret.cmd = tempCmd;
        return ret;

    else
        logger:debug(string.format("========> [NOT_PROCESSED_PKG] ========> %x", tempCmd));
        return nil;
    end
end

-- 定义外部读取Socket的一些函数
function socket_read_ubyte(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readUByte();

    if ret < 0 then
        ret = ret + 2^8;
    end

    return ret;
end

function socket_read_byte(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readByte();

    if ret > 2^7 - 1 then
        ret = ret - 2^8;
    end

    return ret;
end

function socket_read_int(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readInt();

    return ret;
end

function socket_read_uint(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readUInt();

    return ret;
end

function socket_read_short(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readShort();

    return ret;
end

function socket_read_ushort(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    ret = buf:readUShort();

    return ret;
end

function socket_read_long(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end
    local high = buf:readInt();
    local low = buf:readUInt();
    ret = high * 2^32 + low;
    return ret;
end

function socket_read_ulong(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    local high = buf:readInt();
    local low = buf:readUInt();
    ret = high * 2^32 + low;

    return ret;
end

function socket_read_string(buf)
    local ret;

    if buf:getAvailable() <= 0 then
        return nil;
    end

    local len = buf:readUInt();
    local pos = buf:getPos();
    buf:setPos(pos + len - 1);
    local lastByte = buf:readByte();
    buf:setPos(pos);

    -- 防止server出尔反尔，个别协议中出现字符串不以\0结尾的情况，这里做个判断
    if lastByte == 0 then
        ret = buf:readStringBytes(len - 1);
        buf:readByte(); -- 消费掉最后一个字节

    else
        ret = buf:readStringBytes(len);
    end

    return ret;
end

function socket_read_sub_data(buf, returnPacket)
    local ret
    if buf:getAvailable() <= 0 then
        return nil
    end

    local len = buf:readUInt()
    ret = buf:readBuf(len)

    if (not returnPacket) then return ret end

    local newBuf = cc.sockets.ByteArray.new(cc.sockets.ByteArray.ENDIAN_BIG)
    -- 跳过包头
    newBuf:writeBuf(ret)
    newBuf:setPos(16)

    return newBuf
end

return PacketParser
