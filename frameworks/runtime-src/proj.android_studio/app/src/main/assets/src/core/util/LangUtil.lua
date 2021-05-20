local LangUtil = class("LangUtil");


LangUtil.CHINESE = 1;       -- 中文

LangUtil.language = LangUtil.CHINESE;          -- 1表示中文,2表示泰语

LangUtil.langPrefix = "zh_CN";

LangUtil.langRes = "lang/" .. LangUtil.langPrefix .. "/";

-- 获取一个指定键值的text
function LangUtil:getText(primeKey, secKey, ...)
    assert(primeKey ~= nil and secKey ~= nil, "must set prime key and secondary key")
    local lang = {};

    if LangUtil.language == LangUtil.CHINESE then
        local cn_lang = self:getCnLang();
        lang = cn_lang;
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
    return require("app.language.zh_CN.lang");
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

function LangUtil:getLangResPrefix()
    return LangUtil.langPrefix;
end

return LangUtil
