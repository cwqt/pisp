local class = require("libs.middleclass.middleclass")



--[[function feh_LOAD()
	feh = {
		currentImage = ""
	}
end

function feh_DRAW()
	if clients.feh then
		setFullscreen()
		status, clients.feh = imgui.Begin("feh", true, {"AlwaysAutoResize"})
			if type(feh.currentImage) == "userdata" then
	            imgui.Image(feh.currentImage, imgui.GetWindowWidth()-31, imgui.GetWindowHeight())
	        else
	        	imgui.Text("No image")
	        end
		imgui.End()
	end
end]]