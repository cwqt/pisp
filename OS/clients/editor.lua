function editor_LOAD()
	editor = {
		viewingFile = "",
		editing = false,
		editedValue = ""
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
					editor.editing = not editor.editing
					editor.editedValue = tostring(love.filesystem.read(editor.viewingFile))
				end
				if imgui.MenuItem("Save") then
					if editor.editing then
						love.filesystem.write(editor.viewingFile, editor.editedValue, 10000)
					end
				end
                imgui.EndMenu();
            end
            imgui.EndMenuBar()
        end

		if love.filesystem.isFile(editor.viewingFile) then
			if editor.editing then
		        status, editor.editedValue = imgui.InputTextMultiline("", editor.editedValue, 100000, imgui.GetWindowWidth()-15, imgui.GetWindowHeight()-50);
			else
				imgui.TextWrapped(love.filesystem.read(editor.viewingFile), 100000)
			end
		else
			imgui.Text("No file selected.")
		end
		imgui.End()
	else
		editor.editing = false
	end
end