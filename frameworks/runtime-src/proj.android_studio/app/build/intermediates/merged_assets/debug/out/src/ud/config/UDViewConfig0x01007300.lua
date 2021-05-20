-- UDViewConfig0x01007300.lua
-- Author: Amnon
-- Date: 2019-07-26 12:18:07
-- Desc:
-- Usage:
--

local TAG = "UDViewConfig0x01007300"

local APIRes = "0x01007300"

return {
    spriteFrame = {
        plist = string.format("image/r%s/udView/udView.plist", APIRes),
        png   = string.format("image/r%s/udView/udView.png", APIRes),
    },
    progress = {
        bg        = "#ud_progress_bg.png",
        front     = "#ud_progress_front.png",
        frontSize = {w = 280, h = 18},
        size      = cc.size(280, 24),
        x         = display.cx + 407,
        y         = display.cy - 30,
        fillPosX  = 2,
        fillPosY  = 3,
    },
    tipsLabel = {
        color       = cc.c3b(255, 255, 255),
        fontSize    = 25,
        pos         = cc.p(display.cx + 265, display.cy - 20),
        shadowColor = cc.c3b(106, 57, 6),
        align       = display.CENTER_BOTTOM,
        offsetPos   = cc.p(display.cx, display.cy - 10),
    },
}
