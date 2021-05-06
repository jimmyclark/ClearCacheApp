--Author:Jam
--Date:2015.08.25

require("lfs")

local ImageLoader = class("ImageLoader")
local logger = poker.Logger.new("ImageLoader"):enabled(true)

ImageLoader.CACHE_TYPE_NONE = "CACHE_TYPE_NONE"
ImageLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "tmpimg" .. device.directorySeparator

function ImageLoader:ctor()
    self.loadId_ = 0
    self.cacheConfig_ = {}
    self.loadingJobs_ = {}
    --poker.rmdir(ImageLoader.DEFAULT_TMP_DIR)
    poker.mkdir(self:getSaveDir())
    self:registerCacheType(ImageLoader.CACHE_TYPE_NONE, {path=self:getSaveDir()})
end

function ImageLoader:getSaveDir()
    return ImageLoader.DEFAULT_TMP_DIR;
end

function ImageLoader:registerCacheType(cacheType, cacheConfig)
    self.cacheConfig_[cacheType] = cacheConfig
    if cacheConfig.path then
        poker.mkdir(cacheConfig.path)
    else
        cacheConfig.path = self:getSaveDir()
    end
end

function ImageLoader:clearCache()
    poker.rmdir(self:getSaveDir())
    poker.mkdir(self:getSaveDir())
end

function ImageLoader:nextLoaderId()
    self.loadId_ = self.loadId_ + 1
    return self.loadId_
end

function ImageLoader:loadAndCacheImage(loadId, url, callback, cacheType,mid,notDownload)
    logger:normalPrint("=======loadAndCacheImage(%s, %s, %s)", loadId, url, cacheType,mid)
    self:cancelJobByLoaderId(loadId)
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    self:addJob_(loadId, url, self.cacheConfig_[cacheType], callback,mid,notDownload)
end

function ImageLoader:loadImage(url, callback, cacheType)
    local loadId = self:nextLoaderId()
    cacheType = cacheType or ImageLoader.CACHE_TYPE_NONE
    local config = self.cacheConfig_[cacheType]
    logger:normalPrint("loadImage(%s, %s, %s)", loadId, url, cacheType)
    self:addJob_(loadId, url, config, callback)
end

function ImageLoader:cancelJobByUrl_(url)
    local loadingJob = self.loadingJobs_[url]
    if loadingJob then
        loadingJob.callbacks = {}
    end
end

function ImageLoader:cancelJobByLoaderId(loaderId)
    if loaderId then
        for url, loadingJob in pairs(self.loadingJobs_) do
            loadingJob.callbacks[loaderId] = nil
        end
    end
end

function ImageLoader:addJob_(loadId, url, config, callback,mid, notDownload)
    if not loadId then
        return;
    end
    LogUtil.d(" ImageLoader:addJob_(loadId, url " ,loadId, url)
    local hash = crypto.md5(url)
    local path = config.path .. hash
    if io.exists(path) then
        LogUtil.d("ImageLoader file exists (%s, %s, %s)", loadId, url, path)
        lfs.touch(path)
        local tex
        pcall(function()
            tex = cc.Director:getInstance():getTextureCache():addImage(path)
        end)
        if not tex then
            os.remove(path)
        elseif callback ~= nil then
            logger:normalPrint(loadedId , mid)
            callback(tex ~= nil, cc.Sprite:createWithTexture(tex),loadId,mid,tex, path)
        end
    else
        if notDownload then
            return;
        end
        LogUtil.d("start job -> %s", url)
        local loadingJob = {}
        loadingJob.callbacks = {}
        loadingJob.callbacks[loadId] = callback
        self.loadingJobs_[url] = loadingJob
        local function onRequestFinished(evt)
            local v_request = evt.request;
            local errorCode = v_request:getErrorCode()
            -- LogUtil.d("ImageLoader:onRequestFinished evt = errorCode ", evt.name, errorCode)
            if tonumber(errorCode) == 302 then
                local headerString = v_request:getResponseHeadersString();
                local headArray = string.split(headerString, "\n");
                if headArray ~= nil then
                    for i = 1, #headArray do
                        if headArray[i] ~= nil and string.sub(headArray[i],1,8) == "Location" then
                            local redirectUrl = string.sub(headArray[i], 10);
                            local re_request = network.createHTTPRequest(onRequestFinished, redirectUrl, "GET")
                            loadingJob.request = re_request
                            re_request:start()
                            break;
                        end
                    end
                end
                return
            end
            if evt.name ~= "progress" then
                local ok = (evt.name == "completed")
                local request = evt.request
                LogUtil.d("ImageLoader:onRequestFinished ok = ", tostring(ok))
                if not ok then
                    -- 请求失败，显示错误代码和错误消息
                    LogUtil.d("[%d] errCode=%s errmsg=%s", loadId, request:getErrorCode(), request:getErrorMessage())
                    local values = table.values(loadingJob.callbacks)
                    for i,v in ipairs(values) do
                        if v ~= nil then
                            v(false, request:getErrorCode() .. " " .. request:getErrorMessage(), loadId, mid)
                        end
                    end
                    self.loadingJobs_[url] = nil
                    return
                end

                local code = request:getResponseStatusCode()

                if code ~= 200 then
                    --请求结束，但没有返回200响应代码
                    logger:normalPrint("[%d] code = %s", loadId, code)
                    local values = table.values(loadingJob.callbacks)
                    for i,v in ipairs(values) do
                        if v ~= nil then
                            v(false, code,loadId,mid)
                        end
                    end
                    self.loadingJobs_[url] = nil
                    return
                end

                --请求成功，显示服务器返回的内容
                local content = request:getResponseData()
                LogUtil.d("loaded from network, save to file -> %s", path, string.len(content))
                io.writefile(path, content, "w+b")

                if poker.isFileExist(path) then
                    local tex = nil
                    for k,v in pairs(loadingJob.callbacks) do
                        if v then
                            local ret, msg
                            if not tex then
                                lfs.touch(path)
                                ret, msg = pcall(function()
                                    tex = cc.Director:getInstance():getTextureCache():addImage(path)
                                end)
                            end
                            if not tex then
                                os.remove(path)
                            else
                                v(true, cc.Sprite:createWithTexture(tex),k,mid)
                            end
                        end
                    end
                    if config.onCacheChanged then
                        config.onCacheChanged(config.path)
                    end
                else
                    logger:debug("file not exists - >" .. path)
                end
                self.loadingJobs_[url] = nil
            end
        end
        --创建一个请求，并以指定method发送数据到服务器HttpService.cloneDefaultParams初始化
        local request = network.createHTTPRequest(onRequestFinished, url, "GET")
        loadingJob.request = request
        request:start()
    end
end

return ImageLoader
