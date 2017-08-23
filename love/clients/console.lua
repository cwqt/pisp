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

		imgui.BeginChild("10", imgui.GetWindowWidth(), 180)
		for i=1, #console.commands do
			imgui.Text(console.commands[i])
			-- Stop making newlines for commands with no stdout
			if console.returned[i] ~= "" then
				imgui.Text(console.returned[i])
			end
			imgui.SetScrollHere()
		end
		imgui.EndChild()

		consoleEntered, console.currentCommand = imgui.InputText("", console.currentCommand, 100, {"EnterReturnsTrue"})
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

function executeCommand(command)
	-- Possible add threading?
	local file = assert(io.popen(command))
	local output = file:read('*all')
	table.insert(console.returned, output)
	file:close()
end