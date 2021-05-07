local LangUtil = class("LangUtil");


LangUtil.CHINESE = 1;       -- 中文
LangUtil.THAI = 2;          -- 泰语

LangUtil.language = LangUtil.CHINESE;          -- 1表示中文,2表示泰语

LangUtil.langPrefix = "th";

LangUtil.langRes = "image/language/" .. LangUtil.langPrefix .. "/";

LangUtil.AUDIO_ANDROID_PREFIX    = "sounds/android/%s/language/"
LangUtil.AUDIO_IOS_PREFIX        = "sounds/ios/%s/language/"

if DEBUG == 0 then
    LangUtil.language = LangUtil.THAI;

else
    if cc.UserDefault:getInstance():getIntegerForKey("language") == LangUtil.CHINESE then
        LangUtil.language = LangUtil.CHINESE;

    else
        LangUtil.language = LangUtil.THAI;
    end
end

-- 获取一个指定键值的text
function LangUtil:getText(primeKey, secKey, ...)
    assert(primeKey ~= nil and secKey ~= nil, "must set prime key and secondary key")
    local lang = {};

    if LangUtil.language == LangUtil.CHINESE then
        local cn_lang = self:getCnLang();
        lang = cn_lang;

    elseif LangUtil.language == LangUtil.THAI then
        local th_lang = self:getThLang();
        lang = th_lang;
    end

    if LangUtil.hasKey(primeKey, secKey,lang) then
        if (type(lang[primeKey][secKey]) == "string") then
            return LangUtil.formatString(lang[primeKey][secKey], ...)
        else
            return lang[primeKey][secKey]
        end
    else
        return ""
    end
end

function LangUtil:getCnLang()
    return require("app.test.monitor.cn.lang");
end

function LangUtil:getThLang()
    local ok, msg = false, ""
    local requireFile
    local platformName = "android"
    if (device.platform == "ios" or device.platform == "mac") then
        platformName = "ios"
    end
    ok, msg = pcall(function ()
        requireFile = require(string.format("app.%s.language.th.lang", platformName))
    end)
    if (ok) then
        return requireFile
    else
        print(string.format("the lang file in platform [%s] is not found\n%s", platformName, msg))
    end
    return require("app.language.th.lang")
end

-- 判断是否存在指定键值的text
function LangUtil.hasKey(primeKey, secKey,lang)
    return lang[primeKey] ~= nil and lang[primeKey][secKey] ~= nil
end

-- Formats a string in .Net-style, with curly braces ("{1}, {2}").
function LangUtil.formatString(str, ...)
    local numArgs = select("#", ...)
    if numArgs >= 1 then
        local output = str
        for i =1, numArgs do
            local value = select(i, ...)
            output = string.gsub(output, "{" .. i .. "}", value)
        end
        return output
    else
        return str
    end
end

function LangUtil:getLangRes(gameName)
    if gameName then
        return "image/" .. gameName .. "/language/" .. LangUtil.langPrefix .. "/";
    end
    return LangUtil.langRes;
end

function LangUtil:getLangResPrefix()
    return LangUtil.langPrefix;
end

function LangUtil:getAudioPrefix(gameName)
    local prefixFillStr = nk.Const.currentApi

    if gameName then
        prefixFillStr = gameName
    end

    local prefix = string.format(self.AUDIO_ANDROID_PREFIX, prefixFillStr)

    if device.platform == "ios" then
        prefix = string.format(self.AUDIO_IOS_PREFIX, prefixFillStr)
    end


    prefix = prefix .. "th/"

    return prefix
end

return LangUtil
