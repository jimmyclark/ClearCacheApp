local ImageLoader = require("core.http.ImageLoader")

local ActivityImgLoader = class("ActivityImgLoader",ImageLoader);
ActivityImgLoader.DEFAULT_TMP_DIR = device.writablePath .. "cache" .. device.directorySeparator .. "activityImg" .. device.directorySeparator

function ActivityImgLoader:ctor()
	ActivityImgLoader.super.ctor(self);
end

function ActivityImgLoader:getSaveDir()
    return ActivityImgLoader.DEFAULT_TMP_DIR;
end

return ActivityImgLoader;