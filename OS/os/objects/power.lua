local class = require('libs.middleclass.middleclass')
local Timer = require("libs.hump.timer")

local power = class('power')
local image = love.graphics.newImage("images/os/power.png")
function power:initialize(x, y)
	self.x, self.y = x, y
end

function power:update(dt)
end

function power:draw()
    imgui.PushStyleVar("WindowRounding", 0)
    imgui.PushStyleVar("Alpha", 0.1)
    imgui.PushStyleVar("WindowPadding", 0, 0)
	imgui.SetNextWindowPos(self.x, self.y)
	imgui.SetNextWindowSize(image:getWidth(), image:getHeight())
	    status, self.drawing = imgui.Begin("none", true, {"AlwaysAutoResize", "NoTitleBar"})
		    if imgui.Button("", image:getWidth(), image:getHeight()) then
				imgui.OpenPopup("power");
		    end

		    -- Draw the popup menu
			imgui.PushStyleVar("WindowPadding", 5, 5)
		    imgui.PushStyleVar("Alpha", 1)
		    	imgui.SetNextWindowPos(self.x+image:getWidth()+10, self.y-imgui.GetWindowHeight()*2-10)
				if imgui.BeginPopup("power") then
				    imgui.Text("Power");
				    imgui.Separator();
	                    if imgui.Selectable("Shutdown") then
	                        os.execute("systemctl poweroff")
	                    end
	                    if imgui.Selectable("Restart") then
	                        os.execute("systemctl reboot")
	                    end
	                    if imgui.Selectable("Sleep") then
	                        os.execute("systemctl suspend")
	                    end
				    imgui.EndPopup();
				end
			imgui.PopStyleVar(2)

	    imgui.End()
	    imgui.PopStyleVar(3)
	love.graphics.draw(image, self.x, self.y)
end

return power