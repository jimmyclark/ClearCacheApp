--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

local c = cc
local Sprite = c.Sprite

function Sprite:playAnimationOnce(animation, removeWhenFinished, onComplete, delay)
    return transition.playAnimationOnce(self, animation, removeWhenFinished, onComplete, delay)
end

function Sprite:playAnimationForever(animation, delay)
    return transition.playAnimationForever(self, animation, delay)
end

local setSpriteFrame_ = Sprite.setSpriteFrame
-- @override
function Sprite:setSpriteFrame(sprite)
    if (not sprite) then
        assert(sprite, "Sprite:setSpriteFrame sprite is not nil!")
        return
    end
    if (type(sprite) == "string") then
        local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(sprite)
        if (spriteFrame) then
            setSpriteFrame_(self, spriteFrame)
        else
            assert(spriteFrame, "Sprite:setSpriteFrame can't find spriteFrame " .. sprite)
        end
    else
        setSpriteFrame_(self, sprite)
    end
end
