function console_LOAD()
	console = {
		currentCommand = "",
		commands = {},
		returned = {},
	}
end

function console_DRAW()
	if clients.console then
		setFullscreen()
		status, clients.console = imgui.Begin("Console", true, {"AlwaysAutoResize"})

		imgui.BeginChild("10", imgui.GetWindowWidth(), 165)
		for i=1, #console.commands do -- RGBA, decimalised? fuck sake.
			imgui.TextColorHex("32CD32", console.commands[i])
			-- Stop making newlines for commands with no stdout
			if console.returned[i] ~= "" then
				imgui.TextWrapped(console.returned[i])
			end
		end
		if consoleEntered then
				-- New command, scroll to it
				imgui.SetScrollHere()
		end
		imgui.EndChild()

		imgui.PushItemWidth(imgui.GetWindowWidth()-15)
			consoleEntered, console.currentCommand = imgui.InputText("", console.currentCommand, 300, {"EnterReturnsTrue"})
		imgui.PopItemWidth()
		imgui.SetKeyboardFocusHere(-1);
		if consoleEntered then
			if console.currentCommand == "clear" then
				console.commands = {}
				console.returned = {}
			elseif console.currentCommand == "exit" then
				clients.console = false
				console.commands = {}
				console.returned = {}
			else
				executeCommand(console.currentCommand)
				table.insert(console.commands, "> " .. console.currentCommand)
			end
			console.currentCommand = ""
		end
		imgui.End()
	end
end

-- Possibly add threading?
function executeCommand(command)
	-- Capture stdout + stderr
	local file = assert(io.popen(command .. " 2>&1", "r"))
	local output = file:read('*all')
	file:close()
	output = string.gsub(tostring(output), "sh: 1: ", "")
	table.insert(console.returned, output)
end

function imgui.TextColorHex(hex, value)
    --hex = hex:gsub("#","")
    r, g, b = tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
	imgui.TextColored((r*1/255), (g*1/255), (b*1/255), 1, value)
end