local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local settings = class('client')
function settings:initialize(x, y)
    client.initialize(self)
    self.x, self.y = x, y
    self.settings = {
    	TFTbrightness = 1,
    	globalVolume = 1,
    	muted = false,
    	muteState = "Mute"
	}
end

function settings:update(dt)

end

function settings:draw()
    status, self.settings.globalVolume = imgui.SliderFloat("Volume", self.settings.globalVolume, 0, 1)
    imgui.SameLine()
    if imgui.Button(self.settings.muteState) then
    	if self.settings.muteState == "Mute" then
    		self.settings.globalVolume = 0
    		self.settings.muteState = "Muted"
    	elseif self.settings.muteState == "Muted" then
    		self.settings.globalVolume = 1
    		self.settings.muteState = "Mute"
    	end
    end
end

return settings