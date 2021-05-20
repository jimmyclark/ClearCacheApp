-- UDHelper.lua
-- Author: Amnon
-- Date: 2018-01-03 17:19:33
-- Desc: 更新帮助类，负责初始化
--

local UDConfig       = require("ud.UDConfig")
local LocalFileUtils = require("app.util.LocalFileUtils")
local CCFileUtils    = cc.FileUtils:getInstance()
local device         = device

local TAG = "UDHelper"
local M   = {}

addProperty(M, "isActionDelete", false)

-- 初始化接口
-- 获取当前需要的相关配置信息
-- 获取本地的游戏 ID
function M:init( ... )
    if (not self.m_isInited) then
        self.m_udPath        = device.writablePath .. UDConfig.LOCAL_STORAGE
        self.m_isInited = true
    end
    return self
end

-- 添加搜索路径
function M:addSearchPath(path, isFront)
    if (CCFileUtils:isDirectoryExist(path)) then
        CCFileUtils:addSearchPath(path, isFront and true or false)
    end
end

-- 创建文件夹
function M:createDir(dirPath)
    if not (CCFileUtils:isDirectoryExist(dirPath)) then
        CCFileUtils:createDirectory(dirPath)
    end
end

-- 初始化目录和搜索路径
function M:initSearchPath()
    self:createDir(UDConfig.udConfig)
    self:addSearchPath(UDConfig.udConfig .. "/res/", true)
    self:addSearchPath(UDConfig.udConfig .. "/src/", true)

end

-- 获取当前最新的版本号
function M:getCurrentNewestVersion()
    -- 先去取热更新目录下的配置文件version.manifest
    local DOWNLOAD_VERSION = UDConfig.udConfig .. "/project.manifest"
    local versionStr       = nk.Const.GAME_VERSION_UPDATE
    local gameIdMap        = {}
    local versionFileStr
    -- 逐个查找最新的游戏版本号包含热更新版本号
    if CCFileUtils:isFileExist(DOWNLOAD_VERSION) then
        versionFileStr = CCFileUtils:getStringFromFile(DOWNLOAD_VERSION)
    end
    if versionFileStr and string.len(versionFileStr) > 0 then
        local versionFileMap = json.decode(versionFileStr) or {}
        versionStr = versionFileMap.version and versionFileMap.version or versionStr
    end
    if (nk.Const.GAME_VERSION_UPDATE ~= versionStr) then
        nk.Const.GAME_VERSION_UPDATE = versionStr
    end
    return versionStr, json.encode(gameIdMap)
end

-- 检查热更新是否有效
function M:checkUpdateValid(upPath, count)
    local fileList, fileCount = LocalFileUtils:listFiles(upPath)
    if (table.isEmpty(fileList)) then
        return false
    end
    if (fileCount ~= count) then
        return false
    end
    for i = 1, #fileList do
        if (fileList[i] and string.find(fileList[i], ".zip")) then
            return false
        end
    end
    return true
end

-- 检查已下载的文件
-- 因为有 IO 操作，会耗时
function M:checkUpdatedFiles()
    nk.Const.GAME_VERSION_UPDATE = self:getCurrentNewestVersion()

    local updateConfig = json.decode(LocalFileUtils:getStringFromFile(UDConfig.UD_CONFIG_FILE, "{}"))
    local upPath
    local isUpdateConfig = false
    local removeList = {}
    local reloadLuaFileList = {}
    for gameId, fileCount in pairs(updateConfig) do
        if (gameId == "0") then
            upPath = UDConfig.udConfig
            if (not self:checkUpdateValid(upPath, fileCount)) then
                CCFileUtils:removeDirectory(upPath)
                CCFileUtils:removeFile(UDConfig.VERSION_NAME)
                isUpdateConfig = true
                removeList[#removeList + 1] = gameId
            end
        elseif (gameId == "0_lua") then
            table.insertto(reloadLuaFileList, fileCount)
        end
    end
    -- 删除热更新临时目录，虽然会导致重新走热更新逻辑，但这个目录在某些情况下会有异常，这是致命的
    -- 下载 配置文件成功，更新文件失败
    -- 下载更新文件成功，解压失败
    -- 会导致当前热更新失败，但底层又当做成功来处理
    local udTempPath = UDConfig.udConfig .. "_temp"
    if (CCFileUtils:isDirectoryExist(udTempPath)) then
        local _, fileCount = LocalFileUtils:listFiles(udTempPath)
        if (fileCount > 0) then
            CCFileUtils:removeDirectory(udTempPath)
        end
    end
    if (isUpdateConfig) then
        for i = 1, #removeList do
            updateConfig[removeList[i]] = nil
            updateConfig[removeList[i] .. "_lua"] = nil
        end
        self.m_isActionDelete = true
        LocalFileUtils:writeStringToFile(UDConfig.UD_CONFIG_FILE, json.encode(updateConfig))
        local version  = string.gsub(nk.Const.GAME_VERSION_UPDATE, "%.", "_")
        local keyValue = string.format(kUmengUDActionDelete or "%s", version)
        nk.Umeng:reportMap(kUmengUDKey, kUmengUDCheck, keyValue)
    else
        if (table.isEmpty(reloadLuaFileList)) then return end
        self:reloadLuaFile(reloadLuaFileList, UDConfig.udConfig .. "/src/")
    end
end

-- 生成大厅更新文件的差异列表，并返回个数
function M:genHallManifestDiff()
    local localManifest   = UDConfig.MANIFEST
    local updatedManifest = UDConfig.udConfig .. "/project.manifest"
    return self:genManifestDiff(localManifest, updatedManifest)
end

-- 对比生成两个 project.manifest 中的差异
function M:genManifestDiff(orgFile, dstFile)
    local orgStr = LocalFileUtils:getStringFromFile(orgFile)
    local dstStr = LocalFileUtils:getStringFromFile(dstFile)
    if (string.len(orgStr) <= 0 or string.len(dstStr) <= 0) then
        return
    end
    local orgTab = json.decode(orgStr)
    local dstTab = json.decode(dstStr)
    if (not orgTab or table.isEmpty(orgTab)
        or not dstTab or table.isEmpty(dstTab)) then
        return
    end
    local orgAssets = orgTab.assets or {}
    local dstAssets = dstTab.assets or {}
    local diffTab = {}
    local count = 0
    for fileName, value in pairs(dstAssets) do
        local tempValue = orgAssets[fileName]
        if (not tempValue or table.isEmpty(tempValue)
            or tempValue["md5"] ~= value["md5"]) then
            diffTab[fileName] = value
            count = count + 1
        end
    end
    return diffTab, count
end

-- 重新加载 lua 文件
function M:reloadLuaFile(fileList, perfixPath)
    perfixPath = perfixPath or (UDConfig.udConfig .. "/src/")
    for i = 1, #fileList do
        local fileName = fileList[i]
        if (CCFileUtils:isFileExist(fileName)) then
            local finalFileName = string.gsub(fileName, perfixPath, "")
            finalFileName = string.gsub(finalFileName, ".luac", "")
            finalFileName = string.gsub(finalFileName, ".lua", "")
            finalFileName = string.gsub(finalFileName, "/", ".")
            if (package.loaded[finalFileName]) then
                package.loaded[finalFileName] = nil
            end
            if (package.preload[finalFileName]) then
                package.preload[finalFileName] = nil
            end
            pcall(require, finalFileName)
        end
    end
end
-- use soon or not end -----

return M
