local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local files = class('client')
function files:initialize()
    client.initialize(self)
	self.fileManager = {
		previousFolder = "",
		selectedFile = "",
		currentFolder = "",
		allCurrentFiles = {},
		allCurrentFolders = {},
		key = 0
		--love.filesystem.isDirectory( filename )
	}
	self:getCurrentFolderandFiles()
end

function files:draw()
	status, self.fileManager.key = imgui.Combo("Dirs", self.fileManager.key, self.fileManager.allCurrentFolders, #self.fileManager.allCurrentFolders)

	if status then
		self.fileManager.previousFolder = self.fileManager.currentFolder
		self.fileManager.currentFolder = self.fileManager.previousFolder .. "/" .. self.fileManager.allCurrentFolders[self.fileManager.key]
		self:getCurrentFolderandFiles()
	end
	imgui.SameLine()

	if imgui.Button("../") then
		-- Remove everything after the last /
		self.fileManager.currentFolder = self.fileManager.currentFolder:gsub("(.*)%/.*$","%1")
		self:getCurrentFolderandFiles()
	end

	imgui.Text(self.fileManager.currentFolder)
	imgui.Separator()

	imgui.Columns(3,0,true)
		imgui.Text("Filename")
		imgui.NextColumn()
		imgui.Text("Filesize")
		imgui.NextColumn()
		imgui.Text("Last edited")
	imgui.Columns(1)
	imgui.Separator()
	imgui.BeginChild(1,imgui.GetWindowWidth()-10,135)
	for k, file in ipairs(self.fileManager.allCurrentFiles) do
		imgui.Columns(3,0,true)
		if imgui.Selectable(file[1], file.selected, {"SpanAllColumns"}) then
			file.selected = not file.selected
			if file.selected then
				self.fileManager.selectedFile = self.fileManager.currentFolder .. "/" .. file[1]
			end
		end
		imgui.NextColumn()
		imgui.TextWrapped(string.sub(love.filesystem.getSize(self.fileManager.currentFolder .. "/" .. file[1])/1024, 1, 5).."kb")
		imgui.NextColumn()
		imgui.TextWrapped(os.date("%r", love.filesystem.getLastModified(self.fileManager.currentFolder .. "/" ..  file[1])))
	imgui.Columns(1)
	end
	imgui.EndChild()
	imgui.Separator()

	if love.filesystem.isFile(self.fileManager.selectedFile) then
		-- Open files into windows with their respective extension
		if imgui.Button("Open") then
			local file = love.filesystem.newFileData(self.fileManager.selectedFile)
			-- Integrate with musicPlayer
			--[[
			if file:getExtension() == "mp3" or file:getExtension() == "wav" or file:getExtension() == "ogg" then
				muteAllOtherTracks()
				clients.musicPlayer = true
		        music.tracks[#music.tracks+1] = {file:getFilename(), track=love.audio.newSource(self.fileManager.selectedFile)}
		        music.currentTrackKey = #music.tracks
                music.tracks[music.currentTrackKey].track:play()
			elseif file:getExtension() == "txt" or file:getExtension() == "lua" then
				clients.editor = true
				editor.viewingFile = self.fileManager.selectedFile
			elseif file:getExtension() == "png" or file:getExtension() == "jpg" then
				clients.feh = true
				feh.currentImage = love.graphics.newImage(self.fileManager.selectedFile)
			else
				clients.editor = true
				editor.viewingFile = self.fileManager.selectedFile
			end
			]]
		end
		imgui.SameLine()

		-- Delete files
		if imgui.Button("Delete", 1) then
            imgui.OpenPopup("verifyDeletion")
		end
		--imgui.SetNextWindowPos(screen.W-imgui.GetWindowWidth()/1.2, 100)
		if imgui.BeginPopup("verifyDeletion") then
			imgui.PushTextWrapPos(200)
			imgui.TextWrapped("Are you sure you want to delete ".. self.fileManager.selectedFile .."?")
			if imgui.Button("Yes") then
				love.filesystem.remove(self.fileManager.selectedFile)
				imgui.CloseCurrentPopup("verifyDeletion")
			end
			imgui.SameLine()
			if imgui.Button("No") then
				imgui.CloseCurrentPopup("verifyDeletion")
			end
		imgui.EndPopup()
		end
	end
end

function files:getCurrentFolderandFiles()
	self.fileManager.key = 0
	self.fileManager.allCurrentFiles = {}
	self.fileManager.allCurrentFolders = {}
	for k, item in ipairs(love.filesystem.getDirectoryItems(self.fileManager.currentFolder)) do
		if love.filesystem.isDirectory(self.fileManager.currentFolder .. "/" .. item) then
			table.insert(self.fileManager.allCurrentFolders, item)
		else
			table.insert(self.fileManager.allCurrentFiles, {item, selected=false})
		end
	end
end

return files
