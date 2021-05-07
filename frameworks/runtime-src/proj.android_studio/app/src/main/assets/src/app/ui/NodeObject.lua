---
-- 节点对象（用于节点对象池创建时使用）
-- @module NodeObject
-- @author Amnon
-- @date 2020-01-14
-- @usage

local TAG = "NodeObject"
local M = class(TAG, function ()
    return display.newNode()
end)

addProperty(M, "framesLeft", 0)
addProperty(M, "x", 0)
addProperty(M, "y", 0)
addProperty(M, "xVel", 0)
addProperty(M, "yVel", 0)

function M:ctor ()

end

function M:init (x, y, xVel, yVel, lifetime)
    self.m_x = x or 0
    self.m_y = y or 0
    self.m_xVel = xVel or 0
    self.m_yVel = yVel or 0
    self.m_framesLeft = lifetime or 0
end

function M:inUse ()
    return self.m_framesLeft > 0
end

function M:animate ()
    if (not self:inUse()) then return end
    self.m_framesLeft = self.m_framesLeft - 1
    self.m_x = self.m_x + self.m_xVel
    self.m_y = self.m_y + self.m_yVel
end

return M

--[[

class Particle
{
public:
  // ...

  Particle* getNext() const { return state_.next; }
  void setNext(Particle* next) { state_.next = next; }

private:
  int framesLeft_;

  union
  {
    // 使用时的状态
    struct
    {
      double x, y;
      double xVel, yVel;
    } live;

    // 可重用时的状态
    Particle* next;
  } state_;
};
]]