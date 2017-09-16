local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local feh = class('client')
function feh:initialize()
	self.feh = { currentImage = "" }
end

function feh:draw()
	if type(self.feh.currentImage) == "userdata" then
        imgui.Image(self.feh.currentImage, imgui.GetWindowWidth()-31, imgui.GetWindowHeight())
    else
    	imgui.Text("No image")
    end
end

return feh