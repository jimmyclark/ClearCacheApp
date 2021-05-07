-- Author: Jam
-- Date: 2016.09.10
local Progress = class("Progress", function()
    return display.newNode()
end)

Progress.LEFT_TO_RIGHT = 1
Progress.RIGHT_TO_LEFT = 2
Progress.TOP_TO_BOTTOM = 3
Progress.BOTTOM_TO_TOP = 4

function Progress:ctor(fill, direction)
    self.fill = display.newProgressTimer(fill, display.PROGRESS_TIMER_BAR)
    if direction == Progress.LEFT_TO_RIGHT then
    	self.fill:setMidpoint(CCPoint(0, 0.5))
    	self.fill:setBarChangeRate(CCPoint(1.0, 0))
    elseif direction == Progress.RIGHT_TO_LEFT then
    	self.fill:setMidpoint(CCPoint(1.0, 0.5))
    	self.fill:setBarChangeRate(CCPoint(1.0, 0))
    elseif direction == Progress.TOP_TO_BOTTOM then
    	self.fill:setMidpoint(CCPoint(0.5, 1))
    	self.fill:setBarChangeRate(CCPoint(0, 1.0))
    elseif direction == Progress.BOTTOM_TO_TOP then
    	self.fill:setMidpoint(CCPoint(0.5, 0))
    	self.fill:setBarChangeRate(CCPoint(0, 1.0))
    end
    self.fill:setPosition(display.left, display.bottom)
    self.fill:setPercentage(100)
    self.fill:opacity(120)
    self.fill:addTo(self)
end

function Progress:setProgress(progress)
	if progress < 0 then
		progress = 0
	end
	if progress > 100 then
		progress = 100
	end
	self.fill:setPercentage(progress)
end

return Progress