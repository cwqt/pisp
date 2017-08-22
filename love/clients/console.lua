function console_LOAD()
	console = {
		submittedCommand = "",
		returned = {
			{ from="user", command="ls" }
		}
	}
end

function console_DRAW()
	if clients.console then
		setFullscreen()
		status, clients.console = imgui.Begin("Console", true, {"AlwaysAutoResize"})

		for k, command in ipairs(console.returned) do
			if command.from == "user" then
				imgui.Text("> " .. command.command)
			end
		end

		status, console.submittedCommand = imgui.InputText("", console.submittedCommand, 100)
		imgui.End()
	end
end