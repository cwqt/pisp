local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local inputs = class('client')
function inputs:initialize()
    client.initialize(self)
    self.inputTesterKeys = {}
end

function inputs:draw()
    imgui.Text("Logged: " .. #self.inputTesterKeys)
    imgui.SameLine(imgui.GetWindowWidth()-62)
    if imgui.Button("Clear") then
        self.inputTesterKeys = {}
    end
    imgui.Separator();
    -- Get latest key presses
    for i=#self.inputTesterKeys, 1, -1 do
        imgui.Text("[" .. string.sub(self.inputTesterKeys[i][2]-startTime, 1, 4) .. "s]: " .. string.upper(self.inputTesterKeys[i][1]) .. " pressed")
    end
end

function inputs:keypressed(key)
    self.inputTesterKeys[#self.inputTesterKeys+1] = {key, love.timer.getTime()}
end

return inputs