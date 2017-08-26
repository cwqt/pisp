#!/usr/bin/env lua
-- https://github.com/Tieske/rpi-gpio/tree/master/lua
local GPIO = require("GPIO")
GPIO.setmode(GPIO.BOARD)
print ("Version: "..GPIO.VERSION..", Pi Rev: "..GPIO.RPI_REVISION)

-- Set up GPIO pins for inputs
joystick = nil
button = {
	Up 		= nil,
	Down 	= nil,
	Left	= nil,
	Right 	= nil,
	X 		= nil,
	Y 		= nil,
	A 		= nil,
	B 		= nil,
	Start 	= nil,
	Select 	= nil,
}

-- Set up GPIO for outputs
led = {
	Power 	 = nil,
	Activity = nil,
}

--[[
while true do -- poll inputs
	if GPIO.input(button.up) then
		pressKey("w+Up")
	elseif GPIO.input(button.down) then
		pressKey("s+Down")
	end
end

function pressKey(key)
	assert(type(key)=="string", "Expected string in function pressKey")
	os.execute("xdotool "..key)
end
]]


GPIO.cleanup()