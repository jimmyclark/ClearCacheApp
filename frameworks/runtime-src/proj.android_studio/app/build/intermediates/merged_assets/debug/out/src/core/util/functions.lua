require("lfs")
local socket = require("socket")

local functions = {}

function functions.getTime()
    return socket.gettime()
end

function functions.isFileExist(path)
    return path and cc.FileUtils:getInstance():isFileExist(path)
end

function functions.isDirExist(path)
    local success, msg = lfs.chdir(path)
    return success
end

function functions.mkdir(path)
    if DEBUG > 0 then
        print("=====mkdir " .. path)
    end
    pcall(function()
        if not functions.isDirExist(path) then
            local prefix = ""
            if string.sub(path, 1, 1) == device.directorySeparator then
                prefix = device.directorySeparator
            end
            local pathInfo = string.split(path, device.directorySeparator)
            local i = 1
            while(true) do
                if i > #pathInfo then
                    break
                end
                local p = string.trim(pathInfo[i] or "")
                if p == "" or p == "." then
                    table.remove(pathInfo, i)
                elseif p == ".." then
                    if i > 1 then
                        table.remove(pathInfo, i)
                        table.remove(pathInfo, i - 1)
                        i = i - 1
                    else
                        return false
                    end
                else
                    i = i + 1
                end
            end
            for i = 1, #pathInfo do
                local curPath = prefix .. table.concat(pathInfo, device.directorySeparator, 1, i) .. device.directorySeparator
                if not functions.isDirExist(curPath) then
                    local succ, err = lfs.mkdir(curPath)
                    if not succ then
                        if DEBUG > 0 then
                            print("=== mkdir" .. path .. " failed, " .. err)
                        end
                        return false
                    end
                else
                    if DEBUG > 0 then
                        print("curPath exists")
                    end
                end
            end
        end

    end)
    if DEBUG > 0 then
        print("===== done mkdir")
    end
    return true
end

function functions.rmdir(path)
    if DEBUG > 0 then
        print("rmdir " .. path)
    end
    if functions.isDirExist(path) then
        local function _rmdir(path)
            pcall(function()
                local iter,dir_obj = lfs.dir(path)
                while true do
                    local dir = iter(dir_obj)
                    if dir == nil then break end
                    if dir ~= "." and dir ~= ".." then
                        local curDir = path..dir
                        local mode = lfs.attributes(curDir, "mode")
                        if mode == "directory" then
                            _rmdir(curDir.."/")
                        elseif mode == "file" then
                            os.remove(curDir)
                        end
                    end
                end
                local succ,des = lfs.rmdir(path)
                if not succ then
                    if DEBUG > 0 then
                        print("remove dir " .. path .. " failed, " .. des)
                    end
                end
                return succ

            end)

            return false;
        end
        _rmdir(path)
    end
    if DEBUG > 0 then
        print("done rmdir " .. path)
    end
    return true
end

function functions.cacheFile(url, callback, dirName)
    local dirPath = device.writablePath .. "cache" .. device .directorySeparator .. (dirName or "tmpfile") .. device.directorySeparator
    local hash = crypto.md5(url)
    local filePath = dirPath .. hash
    if DEBUG > 0 then
        print("cacheFile filePath == " .. filePath)
    end
    if functions.mkdir(dirPath) then
        if io.exists(filePath) then
            if DEBUG > 0 then
                print("cacheFile io exists", filePath)
            end
            callback("success", io.readfile(filePath))
        else
            if DEBUG > 0 then
                print("cacheFile url = " .. url)
            end
            poker.HttpService.GET_URL(url, {}, function(data)
                io.writefile(filePath, data, "w+")
                callback("success", data)
            end,
            function()
                callback("fail")
            end)
        end
    end
end

functions.exportMethods = function(target)
    for k,v in pairs(functions) do
        if k ~= "exportMethods" then
            target[k] = v
        end
    end
end

function functions.formatBigNumber(num)
    local len = string.len(tostring(num))
    local temp = tonumber(num)
    local ret
    if len >= 13 then
        temp = temp / 1000000000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "T"
    elseif len >= 10 then
        temp = temp / 1000000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "B"
    elseif len >= 7 then
        temp = temp / 1000000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "M"
    elseif len >= 5 then
        temp = temp / 1000
        ret = string.format("%.3f", temp)
        ret = string.sub(ret, 1, string.len(ret) - 1)
        ret = ret .. "K"
    else
        return tostring(temp)
    end

    if string.find(ret, "%.") then
        while true do
            local len = string.len(ret)
            local c = string.sub(ret, len - 1, string.len(ret) - 1)
            if c == "." then
                ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                break
            else
                c = tonumber(c)
                if c == 0 then
                    ret = string.sub(ret, 1, len - 2) .. string.sub(ret, len)
                else
                    break
                end
            end
        end
    end

    return ret
end

-- json数据解析
function functions.decode(str)
    if str == nil or str == "" then return nil end
    if type(str) == "string" then
        return json.decode(str)
    elseif type(str) == "table" then
        return str
    end
    return nil
end

-- 圆形图片剪裁
--[[
@res 资源路径
@viewClipNode
@w 设置图片的宽度
@h 设置图片的高度
]]
function functions.clipCircle(sprite, viewClipNode, w, h)
    -- 图片
    local size =  sprite:getContentSize()
    local r = math.min(size.width, size.height)
    if r <= 0 then return end
    --遮罩
    local stencil = display.newDrawNode()
    stencil:drawSolidCircle(cc.p(0, 0), math.floor(r/2), 360, 360, cc.c4f(0, 0, 0, 0))
    viewClipNode:setStencil(stencil)
    viewClipNode:addChild(sprite)
    viewClipNode:setScale(w/r, h/r)
end

-- 检查节点是否存在
function functions.checkNodeExist(node)
    return node and not tolua.isnull(node) and node:getParent()
end

-- 安全移除节点
function functions.safeRemoveNode(node)
    if functions.checkNodeExist(node) then
        node:stopAllActions()
        node:removeSelf()
        node = nil
    end
end

return functions
