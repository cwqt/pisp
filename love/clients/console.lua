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
		for i=1, #console.commands do
			imgui.TextWrapped(console.commands[i])
			-- Stop making newlines for commands with no stdout
			if console.returned[i] ~= "" then
				imgui.TextWrapped(console.returned[i])
			end
		end
		imgui.SetScrollHere()
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

function executeCommand(command)
	-- Possible add threading?
	-- https://www.lua.org/pil/21.2.html
	local file = assert(io.popen(command, "r"))
	local output = file:read('*all')
	table.insert(console.returned, output)
	file:close()
end