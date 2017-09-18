local class = require('libs.middleclass.middleclass')
local Timer = require("libs.hump.timer")

local battery = class('battery')
local images = {
		charging = love.graphics.newImage("images/os/bat_ac.png"),
		full 	 = love.graphics.newImage("images/os/bat_full.png"),
		high 	 = love.graphics.newImage("images/os/bat_high.png"),
		med 	 = love.graphics.newImage("images/os/bat_med.png"),
		low 	 = love.graphics.newImage("images/os/bat_low.png"),
		empty 	 = love.graphics.newImage("images/os/bat_empty.png"),
	}
function battery:initialize(refreshTime, x, y)
	self.x, self.y = x, y
	self.percentage = 0
	self.state = images.med
	self.refreshTime = refreshTime or 60

	-- Update our current status on creation
	self:updateStatus()

	-- And then update the battery icon once every n seconds
	self.Timer = Timer.new()
	self.Timer:every(self.refreshTime, function() self:updateStatus() end)
end

function battery:update(dt)
	self.Timer:update(dt)
end

function battery:draw()
	love.graphics.draw(self.state, self.x, self.y)
end

function battery:updateStatus()
	-- Capture stdout + stderr
	local command = "cat /sys/class/power_supply/BAT0/capacity"
	local file = assert(io.popen(command .. " 2>&1", "r"))
	local output = file:read('*all')
	file:close()
	output = string.gsub(tostring(output), "sh: 1: ", "")
	self.percentage = output

	-- Update the image
	if tonumber(self.percentage) <= 5 then
		self.state = images.empty
	elseif tonumber(self.percentage) <= 25 then
		self.state = images.low
	elseif tonumber(self.percentage) <= 50 then
		self.state = images.med
	elseif tonumber(self.percentage) <= 75 then
		self.state = images.high
	else
		self.state = images.full
	end
end

return battery