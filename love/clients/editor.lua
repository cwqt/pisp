function editor_LOAD()
	editor = {
		viewingFile = "",
		editing = false
	}
end

function editor_DRAW()
	if clients.editor then
		setFullscreen()
		status, clients.editor = imgui.Begin("Editor", true, {"AlwaysAutoResize", "MenuBar"})

        if imgui.BeginMenuBar() then
            if imgui.BeginMenu("File") then
				if imgui.MenuItem("New") then

				end
				if imgui.MenuItem("Edit") then

				end
				if imgui.MenuItem("Save") then

				end
				if imgui.MenuItem("Save As") then

				end
                imgui.EndMenu();
            end
            imgui.EndMenuBar()
        end

		if love.filesystem.isFile(editor.viewingFile) then
			if editor.editing == false then
				imgui.TextWrapped(love.filesystem.read(editor.viewingFile))
			else
			end
		else
			imgui.Text("No file selected.")
		end
		imgui.End()
	end
end