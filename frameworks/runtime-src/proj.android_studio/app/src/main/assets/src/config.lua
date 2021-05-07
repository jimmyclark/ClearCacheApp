--[[
    Class Name          : config
    description         : just some configs in the application.
    create-author       : ClarkWu
]]

-- 测试模式
-- 0 - 正式          1-5 测试           >5 开发版本
DEBUG = 5

-- 打包时间 只在非正式包时使用
BUILD_TIME = "20210506_171701"

-- 日志开关
LOG_OPEN = (DEBUG > 0) and 1 or 0

-- 用于测试正式包但是使用正式国内可以访问的服务器地址
DEBUG_NORMAL_SERVER = 0

-- FB 审核权限
TEST_FB_REVIEW = 0

-- 是否模拟Server
-- 1 - 是   					   0 - 否
DEBUG_MONITOR = 0;

-- 是否模拟断网状态
-- 1 - 是 						   0 - 否
DEBUG_HTTP = 0;

-- 是否自动下注
AUTO_MATIC = 0;

-- 云测参数
TEST_YUNCE = 0;

-- 用于调试用，正式不会用
TEST_BUG = 0;

-- 用于测试ENJOY
TEST_ENJOY = 0;

-- 用于测试分享
TEST_SHARE = 0;

-- 用于测试BPY
TEST_BPY = 0;

-- 用于测试CD
TEST_CD = 0

-- 用于测试私人房数据
TEST_PRIVATE_ROOM = 0;

-- 是否需要显示FPS
-- true - 是 	.				  false - 否
DEBUG_FPS = true;

-- 是否显示内存
-- true - 是 					  false - 否
DEBUG_MEM = false;

-- 是否为活动测试数据
DEBUG_ACTIVITY_TEST = false;

-- 强制正式环境把值设置为正确的
if DEBUG == 0 and TEST_YUNCE ~= 1 then
	DEBUG_FPS = false;
	DEBUG_MEM = false;
    DEBUG_ACTIVITY_TEST = false;
	DEBUG_MONITOR = 0;
	DEBUG_HTTP = 0;
    AUTO_MATIC = 0;
    TEST_YUNCE = 0;
    TEST_PRIVATE_ROOM = 0;
    TEST_ENJOY = 0;
    TEST_SHARE = 0;

elseif TEST_YUNCE == 1 then
    DEBUG_FPS = false;
    DEBUG_MEM = false;
    DEBUG_MONITOR = 0;
    DEBUG_HTTP = 0;
    AUTO_MATIC = 1;
end

if DEBUG > 0 then
    if cc.UserDefault:getInstance():getIntegerForKey("forbidTest") == 1 then
        DEBUG_FPS = false;
    else
        DEBUG_FPS = true;
    end
end

-- load deprecated API
LOAD_DEPRECATED_API = false;

-- load shortcodes API
LOAD_SHORTCODES_API = true;

-- screen orientation
CONFIG_SCREEN_ORIENTATION = "landscape";

-- design resolution
CONFIG_SCREEN_WIDTH  = 1280;
CONFIG_SCREEN_HEIGHT = 720;

-- auto scale mode
CONFIG_SCREEN_AUTOSCALE = "FIXED_AUTO"
