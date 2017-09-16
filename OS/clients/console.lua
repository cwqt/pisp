local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local console = class('client')
function console:initialize()
    client.initialize(self)
	self.console = {
		currentCommand = "",
		commands = {},
		returned = {},
	}
end

function console:draw()
		for i=1, #self.console.commands do -- RGBA, decimalised? fuck sake.
			imgui.TextColorHex("32CD32", self.console.commands[i])
			-- Stop making newlines for commands with no stdout
			if self.console.returned[i] ~= "" then
				imgui.TextWrapped(self.console.returned[i])
			end
		end
		if consoleEntered then
				-- New command, scroll to it
				imgui.SetScrollHere()
		end

		imgui.PushItemWidth(imgui.GetWindowWidth()-15)
			consoleEntered, self.console.currentCommand = imgui.InputText("", self.console.currentCommand, 300, {"EnterReturnsTrue"})
		imgui.PopItemWidth()
		imgui.SetKeyboardFocusHere(-1);
		if consoleEntered then
			if self.console.currentCommand == "clear" then
				self.console.commands = {}
				self.console.returned = {}
			elseif self.console.currentCommand == "exit" then
				self.drawing = false
				self.console.commands = {}
				self.console.returned = {}
			else
				self:executeCommand(self.console.currentCommand)
				table.insert(self.console.commands, "> " .. self.console.currentCommand)
			end
			self.console.currentCommand = ""
		end
end

-- Possibly add threading?
function console:executeCommand(command)
	-- Capture stdout + stderr
	local file = assert(io.popen(command .. " 2>&1", "r"))
	local output = file:read('*all')
	file:close()
	output = string.gsub(tostring(output), "sh: 1: ", "")
	table.insert(self.console.returned, output)
end

function imgui.TextColorHex(hex, value)
    --hex = hex:gsub("#","")
    r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	imgui.TextColored((r*1/255), (g*1/255), (b*1/255), 1, value)
end

return console