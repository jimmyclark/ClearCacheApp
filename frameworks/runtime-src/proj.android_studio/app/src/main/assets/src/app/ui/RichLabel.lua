
local RichLabel = class("RichLabel", function()
    local node = display.newNode();
    return node;
end)	

--创建方法 
--[[
	local params = {
		fontName = "Arial",
		fontSize = 30,
		fontColor = cc.c3b(255, 0, 0),
		dimensions = cc.size(300, 200),
		text = [fontColor=f75d85 fontSize=20]hello world[/fontColor],
	}

	text 目前支持参数
			文字 
			fontName  : font name
			fontSize  : number
			fontColor : 十六进制

			图片
			image : "xxx.png"
			scale : number
]]
function RichLabel:ctor(params)
	self:init(params);
end

function RichLabel:init(params)
	self.m_fontName   = params.fontName; --默认字体
	self.m_fontSize   = params.fontSize or 28;
	self.m_fontColor  = params.fontColor or cc.c3b(255, 255, 255); --默认白色
	self.m_dimensions = params.dimensions or cc.size(0, 0); --默认无限扩展，即沿着x轴往右扩展
	self.m_text       = params.text;
	self.m_onlyOneLine= params.onlyOneLine == nil and true or false;
	self.m_alignment  = params.align or cc.ui.TEXT_ALIGN_CENTER

	--装文字和图片精灵
	self.m_containLayer = display.newNode();
	self:addChild(self.m_containLayer);
	
    self:setLabelString(self.m_text);
end

-- string.split()
function RichLabel:stringSplit(str, flag)
	local tab = {}
	while true do
		local n = string.find(str, flag)
		if n then
			local first = string.sub(str, 1, n-1) 
			str = string.sub(str, n+1, #str) 
			table.insert(tab, first)
		else
			table.insert(tab, str)
			break
		end
	end
	return tab
end

--[[解析16进制颜色rgb值]]
function  RichLabel:convertColor(xStr)
    local function toTen(v)
        return tonumber("0x" .. v)
    end

    local b = string.sub(xStr, -2, -1) 
    local g = string.sub(xStr, -4, -3) 
    local r = string.sub(xStr, -6, -5)

    local red = toTen(r) or self.m_fontColor.r
    local green = toTen(g) or self.m_fontColor.g
    local blue = toTen(b) or self.m_fontColor.b
    return cc.c3b(red, green, blue)
end


--文字解析，按照顺序转换成数组，每个数组对应特定的标签
function RichLabel:parseString(str)
	local clumpheadTab = {} -- 标签头

	--作用，取出所有格式为[xxxx]的标签头
	for w in string.gfind(str, "%b[]") do 
		if  string.sub(w,2,2) ~= "/" then-- 去尾
			table.insert(clumpheadTab, w);
		end
	end

	-- 解析标签
	local totalTab = {};
	for k,ns in pairs(clumpheadTab) do
		local tab = {};
		local tStr  ;
		-- 第一个等号前为块标签名
		string.gsub(ns, string.sub(ns, 2, #ns-1), function (w)
			local n = string.find(w, "=")
			if n then
				local temTab = self:stringSplit(w, " ") -- 支持标签内嵌
				for k,pstr in pairs(temTab) do
					local temtab1 = self:stringSplit(pstr, "=")
					
					local pname = temtab1[1]

					if k == 1 then 
						tStr = pname 
					end -- 标签头
					
					local js = temtab1[2]

					local p = string.find(js, "[^%d.]")

        			if not p then 
        				js = tonumber(js) 
        			end

					local switchState = {
						["fontColor"]	 = function()
							tab["fontColor"] = self:convertColor(js)
						end,
					} --switch end

					local fSwitch = switchState[pname] --switch 方法

					--存在switch
					if fSwitch then 
						--目前只是颜色需要转换
						local result = fSwitch() --执行function
					else --没有枚举
						tab[pname] = js		
						return
					end
				end
			end
		end)
		if tStr then
			-- 取出文本
			local beginFind,endFind = string.find(str, "%[%/"..tStr.."%]")
			local endNumber = beginFind-1
			local gs = string.sub(str, #ns+1, endNumber)
			if string.find(gs, "%[") then
				tab["text"] = gs
			else
				string.gsub(str, gs, function (w)
					tab["text"] = w
				end)
			end
			-- 截掉已经解析的字符
			str = string.sub(str, endFind+1, #str)
			table.insert(totalTab, tab)
		end
	end
	-- 普通格式label显示
	if table.nums(clumpheadTab) == 0 then
		local ptab = {}
		ptab.text = str
		table.insert(totalTab, ptab)
	end
	return totalTab
end


--将字符串转换成一个个字符
function RichLabel:formatString(parseArray)
	for i,dic in ipairs(parseArray) do
		local text = dic.text
		if text then
			local textArr = self:stringToChar(text)
			dic.textArray = textArr
		end
	end
end

-- 拆分出单个字符
function RichLabel:stringToChar(str)
    local list = {}
    local len = string.len(str)
    local i = 1 
    while i <= len do
        local c = string.byte(str, i)
        local shift = 1
        if c > 0 and c <= 127 then
            shift = 1
        elseif (c >= 192 and c <= 223) then
            shift = 2
        elseif (c >= 224 and c <= 239) then
            shift = 3
        elseif (c >= 240 and c <= 247) then
            shift = 4
        end
        local char = string.sub(str, i, i+shift-1)
        i = i + shift
        table.insert(list, char)
    end
	return list, len
end

--设置text
function RichLabel:setLabelString(text)
	if self.m_text then --删除之前的string
		self.m_textSpriteArray = nil;
		self.m_containLayer:removeAllChildren();
	end

	-- self.m_labelStatus = 1;
	-- self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT);
	-- self:unscheduleUpdate();

	self.m_text = text;
	
	--转化好的数组
	local parseArray = self:parseString(text);

	--将字符串拆分成一个个字符
	self:formatString(parseArray)

	--创建精灵
	local spriteArray = self:createSprite(parseArray)
	self.m_spriteArray = spriteArray
	
	if not self.m_onlyOneLine then 
		self:adjustPosition()
	end
end

--[[ 公共方法
	创建方法 create

	set:
	设置文字方法 setLabelString
	设置尺寸方法 setDimensions

	get:
	获得文字实际占用尺寸 getLabelSize
]]--

--[[-------------------
    -------value-----
    ---------------------]]

RichLabel.__index      = RichLabel
RichLabel._fontName = nil
RichLabel._fontSize = nil
RichLabel._fontColor = nil
RichLabel._containLayer = nil --装载layer
RichLabel._spriteArray = nil --精灵数组
RichLabel._textStr = nil
RichLabel._maxWidth = nil
RichLabel._maxHeight = nil

--播放状态 1 表示未开始 2 表示播放中 3 表示已经播放完毕 
RichLabel._labelStatus = 1

--[[-------------------
    ---Public Method-----
    ---------------------]]





--设置尺寸
function RichLabel:setDimensions(dimensions)
	self._containLayer:setContentSize(dimensions)
	self._dimensions = dimensions

	self:adjustPosition()
end

--获得label尺寸
function RichLabel:getLabelSize()
	if not self.m_onlyOneLine then 
		local width = self.m_maxWidth or 0
		local height = self.m_maxHeight or 0
		return cc.size(width, height)
	else
		local width,height = self:getSizeOfSprites(self.m_spriteArray)[1];
		return cc.size(width,height or 0);
	end
end

--是否在播放动画
function RichLabel:isRunningAmim()
	local isRunning = false
	if self._labelStatus == 2 then
		isRunning = true
	end
	return isRunning
end

--强制停止播放动画
function RichLabel:playEnded()
	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
	self:unscheduleUpdate()

	self._labelStatus = 3 --播放完毕
	for i, sprite in ipairs(self._spriteArray) do
		sprite:stopActionByTag(99)
		sprite:setOpacity(255)
	end
end

--播放fade in 动画
function RichLabel:playFadeInAnim(wordPerSec)
	local spriteArray = self._spriteArray

	if spriteArray then

		if self._labelStatus == 2 then --上一个动画播放中
			self:playEnded()
		end

		self._labelStatus = 2--播放中

		wordPerSec = wordPerSec or 15 --每秒多少个字

		local delay = 1 / wordPerSec

		do -- next action
			local curTime = 0

			local totalNum = #spriteArray

			if totalNum == 0 then
				self._labelStatus = 3 --播放完毕
				return
			end

			local totalTime = totalNum * delay
			local curIntIndex = 1

			--init
			for i, sprite in ipairs(spriteArray) do
				sprite:setOpacity(0)
			end

		    local function updatePosition(dt)

		                curTime = curTime + dt

		                --这个类似动作里面的update的time参数
		                local time = curTime / totalTime

		                local fIndex = (totalNum - 1) * time + 1 --从1开始
		                local index  = math.floor(fIndex)

		                if index < totalNum then


		                else --最后一个点
		                	self._labelStatus = 3 --播放完毕
		                	self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
		                	self:unscheduleUpdate()
		                end

	                	if index >= curIntIndex then
	                		for i = curIntIndex, index do
	                			local sprite = spriteArray[i]
	                			
	                			if sprite then
	                				local action = CCFadeIn:create(0.2)
	                				action:setTag(99)
	                				sprite:runAction(action)
	                			else
	                				print("Error: sprite not exist")
	                			end
	                		end

	                		curIntIndex = index + 1
	                	end
		       
		    end
		    
		    self:removeNodeEventListenersByEvent(cc.NODE_ENTER_FRAME_EVENT)
		    self:unscheduleUpdate()
		    self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, updatePosition) 
		    self:scheduleUpdate_()
		end
	end
end

--[[-------------------
    ---Private Method-----
    ---------------------]]




--获得每个精灵的尺寸
function RichLabel:getSizeOfSprites(spriteArray)
	local widthArr = {} --宽度数组
	local heightArr = {} --高度数组

	--精灵的尺寸
	for i, sprite in ipairs(spriteArray) do
		-- local contentSize = sprite:getContentSize()
		local rect = sprite:getBoundingBox();

		if self.m_onlyOneLine then 
			rect = sprite:getContentSize()
		end
		
		widthArr[i] = rect.width
		heightArr[i] = rect.height
	end
	return widthArr, heightArr
end

--获得每个精灵的位置
function RichLabel:getPointOfSprite(widthArr, heightArr, dimensions)
	local totalWidth = dimensions.width
	local totalHight = dimensions.height

	local maxWidth = 0
	local maxHeight = 0

	local curHeight = heightArr[1];

	local spriteNum = #widthArr

	--从左往右，从上往下拓展
	local curX = 0 --当前x坐标偏移
	local curY = 0;
	
	local curIndexX = 1 --当前横轴index
	local curIndexY = 1 --当前纵轴index

	local pointArrX = {} --每个精灵的x坐标
	local pointArrY = {};

	local rowIndexArr = {} --行数组，以行为index储存精灵组

	local eachHeightY = {} --每个精灵的行index

	--计算宽度，并自动换行
	for i, spriteWidth in ipairs(widthArr) do
		local nexX = curX + spriteWidth
		local pointX = 0;
		local rowIndex = curIndexY
		
		pointArrX[i] = curX;
		pointArrY[i] = curY;

		-- local halfWidth = spriteWidth * 0.5
		if nexX >= totalWidth and totalWidth ~= 0 then --超出界限了
			pointX = curX;
			curIndexY = curIndexY + 1 --y坐标自增
			curIndexX = 1;
			curX = 0;

			eachHeightY[#eachHeightY + 1] = heightArr[i];

			curY = curY - math.max(unpack(eachHeightY));
			curHeight = curHeight + math.max(unpack(eachHeightY));

			eachHeightY = {};
		else
			pointX = curX + spriteWidth --精灵坐标x
			curX = curX + spriteWidth --精灵最右侧坐标
			curIndexX = curIndexX + 1;

			eachHeightY[#eachHeightY + 1] = heightArr[i];
		end
	end

	self.m_maxHeight = curHeight;

	return pointArrX, pointArrY
end

--调整位置（设置文字和尺寸都会触发此方法）
function RichLabel:adjustPosition()
	local spriteArray = self.m_spriteArray

	if not spriteArray then --还没创建
		return
	end

	--获得每个精灵的宽度和高度
	local widthArr, heightArr = self:getSizeOfSprites(spriteArray)

	--获得每个精灵的坐标
	local pointArrX, pointArrY = self:getPointOfSprite(widthArr, heightArr, self.m_dimensions)
	for i, sprite in ipairs(spriteArray) do
		sprite:setPosition(pointArrX[i], pointArrY[i])
	end
end
 
--创建精灵
function RichLabel:createSprite(parseArray)
	local spriteArray = {}
	local tempContent = "";
	local nowWidth = 0;
	local lastWidth = 0;

	for i, dic in ipairs(parseArray) do
		local textArr = dic.textArray

		if textArr and #textArr > 0 then --创建文字
			local fontName = dic.fontName or self.m_fontName
			local fontSize = dic.fontSize or self.m_fontSize
			local fontColor = dic.fontColor or self.m_fontColor

			for j, word in ipairs(textArr) do
				local label = cc.ui.UILabel.new({
                                UILabelType = 2, 
                                text = word, 
                                size = fontSize, 
                                align = self.m_alignment
                            })

				nowWidth = nowWidth + label:getContentSize().width;
				tempContent = tempContent .. word;

				-- 超过了一行，该换行了,才真正创建文字
				if nowWidth + lastWidth >= self.m_dimensions.width then 
					local line = cc.ui.UILabel.new({
									UILabelType = 2,
									text = tempContent,
									size = fontSize
								})
					line:setColor(fontColor);

					spriteArray[#spriteArray + 1] = line;
					self.m_containLayer:addChild(line);

					nowWidth = 0;
					lastWidth = 0;
					tempContent = "";
				end
			end

			-- 这类文字结束了，创建该文字，并设置该文字宽度
			if nowWidth > 0 then 
				local line = cc.ui.UILabel.new({
									UILabelType = 2,
									text = tempContent,
									size = fontSize
								})
					line:setColor(fontColor);

					spriteArray[#spriteArray + 1] = line;
					self.m_containLayer:addChild(line);

				lastWidth = nowWidth;
				nowWidth = 0;
				tempContent = "";
			end
		end
	end

	return spriteArray
end


return RichLabel
