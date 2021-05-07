--[[
    Class Name          : SoundManager
    description         : 声音管理类.
]]
local SoundManager = class("SoundManager");

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

SoundManager.VOLUMN_ENABLED = "volumeEnabled";
SoundManager.MUSIC_ENABLED  = "musicEnabled";
SoundManager.VOLUMN_VALUE   = "volumeValue";
SoundManager.MUSIC_VALUE    = "musicValue";

function SoundManager:ctor()
    self.m_soundPreLoadList = {}
    self.m_soundLoadedList  = {}
end

--[[
    从内存中预载入音效
    @soundsType  Table - 需要预载入的音效名字
    create-author       : ClarkWu
]]
function SoundManager:preload(soundsType)
    if (not soundsType or table.isEmpty(soundsType)) then
        return
    end

    if device.platform == "windows" then
        return;
    end

    self:addToQueue(soundsType)
    if not self.m_loadSoundScheduler then
        self.m_curIndex  = 1
        self.m_lastTime  = cc.net.SocketTCP.getTime()
        self.m_ignore    = 1
        local totalTime  = 0
        local consume    = {}
        self.m_beginTime  = self.m_lastTime
        self.m_loadSoundScheduler = scheduler.scheduleUpdateGlobal(function ()
            local curTime   = cc.net.SocketTCP.getTime()
            local diffTime  = curTime - self.m_lastTime
            self.m_lastTime = curTime
            if self.m_ignore < 6 then
                self.m_ignore = self.m_ignore + 1
            else
                if diffTime > 0.05 then
                    return
                end
                if (table.isEmpty(self.m_soundPreLoadList)) then
                    scheduler.unscheduleGlobal(self.m_loadSoundScheduler)
                    self.m_loadSoundScheduler = nil
                    self.m_soundPreLoadList   = {}
                    if DEBUG > 0 then
                        -- LogUtil.d(TAG, " SoundManager:preload eachTime: ", consume)
                        -- LogUtil.d(TAG, " SoundManager:preload load all sound cost time = ", totalTime, " total time = ", cc.net.SocketTCP.getTime() - self.m_beginTime)
                        nk.TopTipManager:showTopTip("预加载 distantTime:" .. totalTime)
                        -- LogUtil.d(TAG, "SoundManager:preload is over, total number = ", #self.m_soundLoadedList,
                            -- "self.m_soundLoadedList = ", self.m_soundLoadedList)
                    end
                    return
                end
                local soundName = table.remove(self.m_soundPreLoadList, 1)
                local startTime = cc.net.SocketTCP.getTime()
                audio.preloadSound(soundName)
                self.m_soundLoadedList[#self.m_soundLoadedList + 1] = soundName
                self.m_ignore   = 1
                local endTime = cc.net.SocketTCP.getTime()
                local oneTime = endTime - startTime
                consume[soundName] = oneTime
                totalTime = totalTime + oneTime
            end
        end)
    end
end

-- 把音效加入队列
function SoundManager:addToQueue(sounds)
    if (type(sounds) == "table") then
        for i = 1, #sounds do
            self:tryToAddToList(sounds[i])
        end
    else
        self:tryToAddToList(sounds)
    end
end

-- 从队列中移除音效
function SoundManager:removeFromQueue(sounds)
    if (type(sounds) == "table") then
        for i = 1, #sounds do
            self:tryToRemoveFromList(sounds[i])
        end
    else
        self:tryToRemoveFromList(sounds)
    end
end

-- 尝试加入队列
function SoundManager:tryToAddToList(soundName)
    if (table.indexof(self.m_soundLoadedList, soundName)) then
        return
    end
    if (table.indexof(self.m_soundPreLoadList, soundName)) then
        return
    end
    self.m_soundPreLoadList[#self.m_soundPreLoadList + 1] = soundName
end

-- 尝试从队列删除
function SoundManager:tryToRemoveFromList(soundName)
    local index = table.indexof(self.m_soundPreLoadList, soundName)
    if (index) then
        table.remove(self.m_soundPreLoadList, index)
        return
    end
    index = table.indexof(self.m_soundLoadedList, soundName)
    if (index) then
        table.remove(self.m_soundLoadedList, index)
    end
end

--[[
    从内存中预载入音乐
    @musicType  Table - 需要预载入的音效名字
    create-author       : ClarkWu
]]
function SoundManager:preloadMusic(musicType)
    if musicType and type(musicType) == "table" then
        for _,soundName in pairs(musicType) do
            audio.preloadMusic(soundName)
        end
    end
end

--[[
    从内存中卸载音效
    @soundsType  Table - 需要卸载的音效名字
    create-author       : ClarkWu
]]
function SoundManager:unload(soundsType)
    if (not soundsType or table.isEmpty(soundsType)) then
        return
    end
    self:removeFromQueue(soundsType)
    for _, soundName in pairs(soundsType) do
        audio.unloadSound(soundName)
    end
end

--[[
    播放当前的音效
    @soundName  String - 音效名字
    @loop Boolean - 是否重复播放
            true - 重复播放     false - 不重复播放
    create-author       : ClarkWu
]]
function SoundManager:playSound(soundName, loop)
    if self.m_volumeCanPlayFlag then
        audio.playSound(soundName, loop or false);
    end
end

--[[
    播放当前的音乐
    @voiceName  String - 音乐名字
    @loop Boolean - 是否重复播放
            true - 重复播放     false - 不重复播放
    create-author       : ClarkWu
]]
function SoundManager:playMusic(voiceName, loop)
    self.m_musicName = voiceName;

    if self.m_musicCanPlayFlag then
        audio.playMusic(voiceName, loop or false);
    end
end

--[[
    设置音乐音量
    create-author       : ClarkWu
]]
function SoundManager:setMusicVolume(musicVolume)
    self.m_musicVolume = musicVolume;

    audio.setMusicVolume(self.m_musicVolume);

    nk.GameState:putFloat(nk.SoundManager.MUSIC_VALUE, self.m_musicVolume)
end

--[[
    得到音乐音量
    create-author       : ClarkWu
]]
function SoundManager:getMusicVolume()
    if not self.m_musicVolume then
        local musicVolume = nk.GameState:getFloat(nk.SoundManager.MUSIC_VALUE, -1)

        if musicVolume == -1 then
            self.m_musicVolume = audio.getMusicVolume();

            if self.m_musicVolume == 0 then
                self.m_musicVolume = 0.5
            end

        else
            self.m_musicVolume = musicVolume;
            audio.setMusicVolume(self.m_musicVolume);
        end
    end

    return self.m_musicVolume;
end

--[[
    设置音效音量
    create-author       : ClarkWu
]]
function SoundManager:setSoundVolume(soundVolume)
    self.m_soundVolume = soundVolume;

    audio.setSoundsVolume(self.m_soundVolume);

    nk.GameState:putFloat(nk.SoundManager.VOLUMN_VALUE, self.m_soundVolume)
end

--[[
    得到音效音量
    create-author       : ClarkWu
]]
function SoundManager:getSoundVolume()
    if not self.m_soundVolume then
        local audioVolume = nk.GameState:getFloat(nk.SoundManager.VOLUMN_VALUE, -1)

        if audioVolume == -1 then
            self.m_soundVolume = audio.getSoundsVolume();

        else
            self.m_soundVolume = audioVolume;
            audio.setSoundsVolume(self.m_soundVolume);
        end
    end

    return self.m_soundVolume;
end

function SoundManager:isMusicCanPlay()
    return self.m_musicCanPlayFlag;
end

function SoundManager:setMusicCanPlay(isMusicCanPlayFlag)
    self.m_musicCanPlayFlag = isMusicCanPlayFlag;

    if not self.m_musicCanPlayFlag then
        audio.pauseMusic();
        self.m_isPauseMusicFlag = true;

    else
        if self.m_isPauseMusicFlag and audio.isMusicPlaying() then
            audio.resumeMusic();

        else
            if self.m_musicName then
                self:playMusic(self.m_musicName, true)
            end
        end

        self.m_isPauseMusicFlag = false;
    end
end

function SoundManager:isVolumeCanPlay()
    return self.m_volumeCanPlayFlag;
end

function SoundManager:setVolumeCanPlay(isVolumeCanPlayFlag)
    self.m_volumeCanPlayFlag = isVolumeCanPlayFlag;

    if not self.m_volumeCanPlayFlag then
        audio.pauseAllSounds();

    else
        audio.resumeAllSounds();
    end
end

function SoundManager:stopMusic()
    self.m_musicName = nil;
    self.m_isPauseMusicFlag = false;

    audio.stopMusic();
end

return SoundManager;
