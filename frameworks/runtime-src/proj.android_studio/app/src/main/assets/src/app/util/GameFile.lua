local GameFile = class("GameFile");

function GameFile:ctor()
    self.m_configTable = {};
end

function GameFile:readToCache(fileName,playerId)
    local ret,msg = pcall(function()
        self.m_fileName = cc.FileUtils:getInstance():getWritablePath() .. (fileName or "") .. (playerId or "") .. ".dat";

        if cc.FileUtils:getInstance():isFileExist(self.m_fileName) then
            self.m_configTable = cc.FileUtils:getInstance():getValueMapFromFile(self.m_fileName) or {};

        else
            self.m_configTable = {};
        end

    end)

    if not ret then
        self.m_configTable = {};
        return {};
    end

    return self.m_configTable;
end

--[[
    保存布尔类型的值到文件中
    @param key String    - 键值
    @param value Boolean - 布尔值
    create-author       : ClarkWu
]]
function GameFile:putBool(key, value)
    if key then
        self.m_configTable[key] = value;
    end
end

--[[
    保存数值(double)类型的值到文件中
    @param key String           - 键值
    @param value Number(double) - 数值
    create-author       : ClarkWu
]]
function GameFile:putDouble(key, value)
    if key then
        self.m_configTable[key] = value;
    end
end

--[[
    保存数值(float)类型的值到文件中
    @param key String           - 键值
    @param value Number(float)  - 数值
    create-author       : ClarkWu
]]
function GameFile:putFloat(key, value)
    if key then
        self.m_configTable[key] = value;
    end
end

--[[
    保存数值(Int)类型的值到文件中
    @param key String           - 键值
    @param value Number(Int)    - 数值
    create-author       : ClarkWu
]]
function GameFile:putInt(key, value)
    if key then
        self.m_configTable[key] = value;
    end
end

--[[
    保存字符串类型的值到文件中
    @param key String           - 键值
    @param value String         - 字符串
    create-author       : ClarkWu
]]
function GameFile:putString(key, value)
    if key and value then
        self.m_configTable[key] = value;
    end
end

--[[
    从文件中得到键值key对应的布尔值
    @param key String          - 键值
    @param defaultBool Boolean - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameFile:getBool(key,defaultBool)
    if key then
        return (self.m_configTable[key] == nil) and defaultBool or self.m_configTable[key];

    else
        return defaultBool;
    end
end

--[[
    从文件中得到键值key对应的Number(double)值
    @param key String             - 键值
    @param default Number(double) - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameFile:getDouble(key,default)
    if key then
        return self.m_configTable[key] or default;

    else
        return default;
    end
end

--[[
    从文件中得到键值key对应的Number(float)值
    @param key String             - 键值
    @param default Number(float)  - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameFile:getFloat(key,default)
    if key then
        return self.m_configTable[key] or default;

    else
        return default;
    end
end

--[[
    从文件中得到键值key对应的Number(int)值
    @param key String             - 键值
    @param default Number(int)    - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameFile:getInt(key,default)
    if key then
        return self.m_configTable[key] or default;

    else
        return default;
    end
end

--[[
    从文件中得到键值key对应的字符串值
    @param key String             - 键值
    @param default String         - 默认没有取到的值
    create-author       : ClarkWu
]]
function GameFile:getString(key,default)
    if key then
        return self.m_configTable[key] or default;

    else
        return default;
    end
end

function GameFile:clearAll()
    self.m_configTable = {};
end

function GameFile:removeKey(key)
    if self.m_configTable[key] then
        self.m_configTable[key] = nil;
    end
end

function GameFile:deleteMyself()
    self:clearAll();

    if cc.FileUtils:getInstance():isFileExist(self.m_fileName) then
        os.remove(self.m_fileName);
    end
end

function GameFile:commit()
    if self.m_configTable and self.m_fileName then
        cc.FileUtils:getInstance():writeToFile(self.m_configTable,self.m_fileName);
    end
end

return GameFile;
