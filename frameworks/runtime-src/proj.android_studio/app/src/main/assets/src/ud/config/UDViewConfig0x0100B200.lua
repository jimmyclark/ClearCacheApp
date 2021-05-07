-- UDViewConfig0x0100B200.lua
-- Author: Amnon
-- Date: 2019-07-26 12:18:07
-- Desc:
-- Usage:
--

local TAG = "UDViewConfig0x0100B200"

local APIRes = "0x0100B200"

return {
    spriteFrame = {
        plist = string.format("image/r%s/udView/udView.plist", APIRes),
        png   = string.format("image/r%s/udView/udView.png", APIRes),
    },
    progress = {
        bg        = "#ud_progress_bg.png",
        front     = "#ud_progress_front.png",
        frontSize = {w = 555, h = 31},
        size      = cc.size(555, 31),
        x         = display.cx + 275,
        y         = display.cy - 250,
        fillPosX  = 0,
        fillPosY  = 0,
    },
    tipsLabel = {
        color       = cc.c3b(255, 255, 255),
        fontSize    = 25,
        pos         = cc.p(display.cx, display.cy - 240),
        shadowColor = cc.c3b(106, 57, 6),
        align       = display.CENTER_BOTTOM,
        offsetPos   = cc.p(display.cx, display.cy - 230),
    },
    shadowBg = {
        file      = "#ud_shadow_bg.png",
        pos       = cc.p(display.cx, display.cy - 240),
        offsetPos = cc.p(display.cx, display.cy - 230),
        align       = display.CENTER_BOTTOM,
    }
}
