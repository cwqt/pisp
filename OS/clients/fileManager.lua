function fileManager_LOAD()
	fileManager = {
		previousFolder = "",
		selectedFile = "",
		currentFolder = "",
		allCurrentFiles = {},
		allCurrentFolders = {},
		key = 0
		--love.filesystem.isDirectory( filename )
	}
	getCurrentFolderandFiles()
end

function fileManager_DRAW()
	if clients.fileManager then
		setFullscreen()
		status, clients.fileManager = imgui.Begin("File Manager", true, {"AlwaysAutoResize"})

			status, fileManager.key = imgui.Combo("Dirs", fileManager.key, fileManager.allCurrentFolders, #fileManager.allCurrentFolders)

			if status then
				fileManager.previousFolder = fileManager.currentFolder
				fileManager.currentFolder = fileManager.previousFolder .. "/" .. fileManager.allCurrentFolders[fileManager.key]
				getCurrentFolderandFiles()
			end
			imgui.SameLine()

			if imgui.Button("../") then
				-- Remove everything after the last /
				fileManager.currentFolder = fileManager.currentFolder:gsub("(.*)%/.*$","%1")
				getCurrentFolderandFiles()
			end

			imgui.Text(fileManager.currentFolder)
			imgui.Separator()

			imgui.Columns(3,0,true)
				imgui.Text("Filename")
				imgui.NextColumn()
				imgui.Text("Filesize")
				imgui.NextColumn()
				imgui.Text("Last edited")
			imgui.Columns(1)
			imgui.Separator()
			imgui.BeginChild(1,imgui.GetWindowWidth()-10,105)
			for k, file in ipairs(fileManager.allCurrentFiles) do
				imgui.Columns(3,0,true)
				if imgui.Selectable(file[1], file.selected, {"SpanAllColumns"}) then
					file.selected = not file.selected
					if file.selected then
						fileManager.selectedFile = fileManager.currentFolder .. "/" .. file[1]
					end
				end
				imgui.NextColumn()
				imgui.TextWrapped(string.sub(love.filesystem.getSize(fileManager.currentFolder .. "/" .. file[1])/1024, 1, 5).."kb")
				imgui.NextColumn()
				imgui.TextWrapped(os.date("%r", love.filesystem.getLastModified(fileManager.currentFolder .. "/" ..  file[1])))
			imgui.Columns(1)
			end
			imgui.EndChild()
			imgui.Separator()

			if love.filesystem.isFile(fileManager.selectedFile) then
				-- Open files into windows with their respective extension
				if imgui.Button("Open") then
					local file = love.filesystem.newFileData(fileManager.selectedFile)
					if file:getExtension() == "mp3" or file:getExtension() == "wav" or file:getExtension() == "ogg" then
						-- Integrate with musicPlayer
						muteAllOtherTracks()
						clients.musicPlayer = true
				        music.tracks[#music.tracks+1] = {file:getFilename(), track=love.audio.newSource(fileManager.selectedFile)}
				        music.currentTrackKey = #music.tracks
		                music.tracks[music.currentTrackKey].track:play()
					elseif file:getExtension() == "txt" or file:getExtension() == "lua" then
						clients.editor = true
						editor.viewingFile = fileManager.selectedFile
					elseif file:getExtension() == "png" or file:getExtension() == "jpg" then
						clients.feh = true
						feh.currentImage = love.graphics.newImage(fileManager.selectedFile)
					else
						clients.editor = true
						editor.viewingFile = fileManager.selectedFile
					end
				end
				imgui.SameLine()

				-- Delete files
				if imgui.Button("Delete", 1) then
	                imgui.OpenPopup("verifyDeletion")
				end
				--imgui.SetNextWindowPos(screen.W-imgui.GetWindowWidth()/1.2, 100)
				if imgui.BeginPopup("verifyDeletion") then
					imgui.PushTextWrapPos(200)
					imgui.TextWrapped("Are you sure you want to delete ".. fileManager.selectedFile .."?")
					if imgui.Button("Yes") then
						love.filesystem.remove(fileManager.selectedFile)
						imgui.CloseCurrentPopup("verifyDeletion")
					end
					imgui.SameLine()
					if imgui.Button("No") then
						imgui.CloseCurrentPopup("verifyDeletion")
					end
				imgui.EndPopup()
				end
			end
		imgui.End()
	end
end

function getCurrentFolderandFiles()
	fileManager.key = 0
	fileManager.allCurrentFiles = {}
	fileManager.allCurrentFolders = {}
	for k, item in ipairs(love.filesystem.getDirectoryItems(fileManager.currentFolder)) do
		if love.filesystem.isDirectory(fileManager.currentFolder .. "/" .. item) then
			table.insert(fileManager.allCurrentFolders, item)
		else
			table.insert(fileManager.allCurrentFiles, {item, selected=false})
		end
	end
end