#!/usr/bin/env lua
-- https://github.com/Tieske/rpi-gpio/tree/master/lua
local GPIO = require("GPIO")
GPIO.setmode(GPIO.BOARD)

-- Set up GPIO pins for inputs
joystick = nil
button = {
	A 	= nil
	B 	= nil
	Start 	= nil
	Select 	= nil
	Power 	= nil
}

-- Set up GPIO for outputs
led = {
	Power 	 = nil
	Activity = nil
}
















