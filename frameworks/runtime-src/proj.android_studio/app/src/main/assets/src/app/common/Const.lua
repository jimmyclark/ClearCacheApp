local Const = {}

Const.DEFAULT_GAME_VERSION = "1.0.0"

Const.LAST_GAME_VERSION    = "last_game_version"
Const.GAME_VERSION_UPDATE  = Const.DEFAULT_GAME_VERSION .. ".0"

-- 初始化参数定义
Const.rat           = "1280x720"                    -- 机屏大小
Const.imei          = nil                           -- 机器码
Const.osv           = ""                            -- 终端操作系统
Const.net           = ""                            -- 接入方式，例如wifi
Const.operator      = "未知"                        -- 运营商
Const.imsi          = ""                            -- 手机号唯一标示符
Const.mac           = ""                            -- mac地址
Const.appid         = "0"                           -- 渠道id
Const.appkey        = "0"                           -- 渠道key
Const.googleSid     = 0                             -- Google推送Sid
Const.supportSDCard = 0                             -- 是否支持SDCard
Const.deviceModel   = ""                            -- 设备型号
Const.customName    = ""                            -- 设备自定义名字
Const.isAndroid10   = false                         -- 是否为 Android 10 设备

Const.isNeedFirstClose = true

return Const
