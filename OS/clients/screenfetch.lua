local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local screenfetch = class('client')
function screenfetch:initialize()
    client.initialize(self)
    self.screenFetch = { logo = love.graphics.newImage("logo.png")}
    self:getCurrentConfig()
end

function screenfetch:draw()
    imgui.Image(self.screenFetch.logo, 100, 100)
    imgui.SameLine()
    imgui.BeginChild(1)
	    imgui.TextWrapped(self.screenFetch.USER)
	    imgui.TextWrapped("---------------------")
		imgui.TextWrapped("OS: " 			.. self.screenFetch.OS)
	    imgui.TextWrapped("Uptime: " 		.. self.screenFetch.UPTIME)
	    imgui.TextWrapped("Packages: " 	.. self.screenFetch.PACKAGES)
	    imgui.TextWrapped("Resolution: " 	.. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
	    imgui.TextWrapped("WM: " 			.. "PiSP WM")
	    imgui.TextWrapped("CPU: " 			.. self.screenFetch.CPU)
	    imgui.TextWrapped("RAM: "			.. self.screenFetch.RAM)
	    imgui.TextWrapped("MEM: " 			.. string.sub(collectgarbage("count")/1024, 1, 5) .. "MB")
	    imgui.TextWrapped("FPS: "			.. tostring(love.timer.getFPS()))
    imgui.EndChild()
end

function screenfetch:getCurrentConfig()
    self.screenFetch.USER = io.popen ("echo $USER"):read() .. "@" .. io.popen ("uname -n"):read()
	self.screenFetch.OS = io.popen ("cat /etc/issue |cut -c -7"):read() .. io.popen ("uname -o"):read()
	self.screenFetch.UPTIME = io.popen ("uptime -p | cut -c4-"):read()
	self.screenFetch.PACKAGES = io.popen("dpkg -l | grep -c '^ii'" ):read()
	self.screenFetch.CPU = io.popen(" cat /proc/cpuinfo | grep 'model name' | uniq | cut -c14-"):read()
	self.screenFetch.RAM = string.sub(io.popen("grep MemAvail /proc/meminfo | awk '{print $2}'"):read()/1024, 1, 7) .. "MB"
end

return screenfetch