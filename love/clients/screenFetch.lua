function screenFetch_LOAD()
    screenFetch = {
        logo = love.graphics.newImage("logo.png")
    }
    getScreenfetchConfig()
end

function screenFetch_DRAW()
    -- Screenfetch
    if clients.screenFetch then
        imgui.SetNextWindowSize(510, 227)
    	status, clients.screenfetch = imgui.Begin("screenFetch", true)
            imgui.Image(screenFetch.logo, 200, 200)
            imgui.SameLine()
            imgui.BeginChild(1)
        	    imgui.Text(screenFetch.USER)
        	    imgui.Text("---------------------")
        		imgui.Text("OS: " 			.. screenFetch.OS)
        	    imgui.Text("Uptime: " 		.. screenFetch.UPTIME)
        	    imgui.Text("Packages: " 	.. screenFetch.PACKAGES)
        	    imgui.Text("Resolution: " 	.. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
        	    imgui.Text("WM: " 			.. "PiSP WM")
        	    imgui.Text("CPU: " 			.. screenFetch.CPU)
        	    imgui.Text("RAM: "			.. screenFetch.RAM)
        	    imgui.Text("MEM: " 			.. string.sub(collectgarbage("count")/1024, 1, 5) .. "MB")
        	    imgui.Text("FPS: "			.. tostring(love.timer.getFPS()))
            imgui.EndChild()
    	imgui.End()
    end
end

function getScreenfetchConfig()
    screenFetch.USER = io.popen ("echo $USER"):read() .. "@" .. io.popen ("uname -n"):read()
	screenFetch.OS = io.popen ("cat /etc/issue |cut -c -7"):read() .. io.popen ("uname -o"):read()
	screenFetch.UPTIME = io.popen ("uptime -p | cut -c4-"):read()
	screenFetch.PACKAGES = io.popen("dpkg -l | grep -c '^ii'" ):read()
	screenFetch.CPU = io.popen(" cat /proc/cpuinfo | grep 'model name' | uniq | cut -c14-"):read()
	screenFetch.RAM = string.sub(io.popen("grep MemAvail /proc/meminfo | awk '{print $2}'"):read()/1024, 1, 7) .. "MB"
end
