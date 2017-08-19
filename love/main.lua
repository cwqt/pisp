require "imgui"

local image = love.graphics.newImage("logo.png")


function love.load()
    sf = {}
    getScreenfetchConfig()
    textValue = ""

    screen = {
        W = love.graphics.getWidth(),
        H = love.graphics.getHeight()
    }

    login = {
        username = "",
        password = "",
        errorMsg = ""
    }


Client = require("src.client")
test = Client:new("Title", {imgui.Text("tes")}, {x=10, y=10})

end

function love.update(dt)
    imgui.NewFrame()
end

function love.draw()
    local status

    test:draw()


    imgui.SetNextWindowPos(screen.W/2-125, screen.H/2-50)
    imgui.SetNextWindowSize(285, 80)
    imgui.Begin("Login",  true, { "AlwaysAutoResize", "NoTitleBar" })
        status, login.username = imgui.InputText("Username", login.username, 100, 100)
        status, login.password = imgui.InputText("Password", login.password, 100, 100)
        if imgui.Button("Enter") then
            verifyAuthentication()
        end
        imgui.SameLine()
        imgui.Text(login.errorMsg)
    imgui.End()

    love.graphics.clear(100, 100, 100, 255)

    if userAuthenticated then

        -- Menu
        if imgui.BeginMainMenuBar() then
            if imgui.BeginMenu("File") then
                imgui.MenuItem("Test")
                imgui.EndMenu()
            elseif imgui.BeginMenu("Edit") then
                imgui.MenuItem("Test")
                imgui.EndMenu()
            end
            imgui.EndMainMenuBar()
        end

        -- Screenfetch
        imgui.SetNextWindowSize(510, 227)
    	imgui.Begin("screenfetch", true)
            imgui.Image(image, 200, 200)
            imgui.SameLine()
            imgui.BeginChild(1)
        	    imgui.Text(sf.USER)
        	    imgui.Text("---------------------")
        		imgui.Text("OS: " 			.. sf.OS)
        	    imgui.Text("Uptime: " 		.. sf.UPTIME)
        	    imgui.Text("Packages: " 	.. sf.PACKAGES)
        	    imgui.Text("Resolution: " 	.. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
        	    imgui.Text("WM: " 			.. "PiSP WM")
        	    imgui.Text("CPU: " 			.. sf.CPU)
        	    imgui.Text("RAM: "			.. sf.RAM)
        	    imgui.Text("MEM: " 			.. string.sub(collectgarbage("count")/1024, 1, 5) .. "MB")
        	    imgui.Text("FPS: "			.. tostring(love.timer.getFPS()))
            imgui.EndChild()
    	imgui.End()

    end
    imgui.Render()
end

function verifyAuthentication()
    if login.username == "meme" and login.password == "meme" then
        userAuthenticated = true
    else
        login.errorMsg = "Invalid credentials!"
    end
end

function getScreenfetchConfig()
    sf.USER = io.popen ("echo $USER"):read() .. "@" .. io.popen ("uname -n"):read()
	sf.OS = io.popen ("cat /etc/issue |cut -c -7"):read() .. io.popen ("uname -o"):read()
	sf.UPTIME = io.popen ("uptime -p | cut -c4-"):read()
	sf.PACKAGES = io.popen("dpkg -l | grep -c '^ii'" ):read()
	sf.CPU = io.popen(" cat /proc/cpuinfo | grep 'model name' | uniq | cut -c14-"):read()
	sf.RAM = string.sub(io.popen("grep MemAvail /proc/meminfo | awk '{print $2}'"):read()/1024, 1, 7) .. "MB"
end

function love.quit()
    imgui.ShutDown();
end

--
-- User inputs
--
function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
    end
end

function love.keypressed(key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
    end
end