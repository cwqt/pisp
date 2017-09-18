local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local editor = class('client')
function editor:initialize(args)
    client.initialize(self, args)
	self.editor = {
		viewingFile = "",
		editing = false,
		editedValue = ""
	}
end

function editor:draw()
    if imgui.BeginMenuBar() then
        if imgui.BeginMenu("File") then
			if imgui.MenuItem("New") then

			end
			if imgui.MenuItem("Edit") then
				self.editor.editing = not self.editor.editing
				self.editor.editedValue = tostring(love.filesystem.read(self.editor.viewingFile))
			end
			if imgui.MenuItem("Save") then
				if self.editor.editing then
					love.filesystem.write(self.editor.viewingFile, self.editor.editedValue, 10000)
				end
			end
            imgui.EndMenu();
        end
        imgui.EndMenuBar()
    end


	if love.filesystem.isFile(self.editor.viewingFile) then
		if self.editor.editing then
	        status, self.editor.editedValue = imgui.InputTextMultiline("", self.editor.editedValue, 100000, imgui.GetWindowWidth()-15, imgui.GetWindowHeight()-50);
		else
			imgui.TextWrapped(love.filesystem.read(self.editor.viewingFile), 100000)
		end
	else
		imgui.Text("No file selected.")
	end
end

return editor