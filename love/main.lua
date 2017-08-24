--  https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
require "imgui"

require("clients.login")
require("clients.musicPlayer")
require("clients.about")
require("clients.gameSelect")
require("clients.inputTester")
require("clients.screenFetch")
require("clients.imguiMetrics")
require("clients.console")
require("clients.fileManager")
require("clients.editor")
require("clients.feh")

function love.load()
    wallpaper = love.graphics.newImage("wallpaper.png")
    startTime = love.timer.getTime()
    clients = {}
    PiSP = {
        version = 0.2
    }
    screen = {
        W = love.graphics.getWidth(),
        H = love.graphics.getHeight()
    }

    feh_LOAD()
    editor_LOAD()
    fileManager_LOAD()
    console_LOAD()
    inputTester_LOAD()
    musicPlayer_LOAD()
    about_LOAD()
    gameSelect_LOAD()
    screenFetch_LOAD()
    login_LOAD()

    clients.fileManager = true
    imgui.SetGlobalFontFromFileTTF("gohu.ttf", 11, 1, 1)
end

function love.update(dt)
    require("libs.lovebird.lovebird").update()
    imgui.NewFrame()
end

function love.draw()
    -- Remove rounded corners for all windows
    imgui.PushStyleVar("WindowRounding", 0)

    local status -- ??
    love.graphics.clear(100, 100, 100, 255)

    love.graphics.push()
        love.graphics.scale(0.6)
        love.graphics.draw(wallpaper, 0, 0)
    love.graphics.pop()

    login_DRAW()

    if userAuthenticated then
        -- Menu
        if imgui.BeginMainMenuBar() then
            if imgui.BeginMenu("Menu") then
                    if imgui.MenuItem("Files") then clients.fileManager = true end
                    if imgui.MenuItem("Editor") then clients.editor = true end
                    if imgui.MenuItem("Console") then clients.console = true end
                    if imgui.MenuItem("Metrics") then clients.imguiMetrics = true end
                    imgui.Separator();
                    if imgui.MenuItem("Log out") then userAuthenticated = false end
                    if imgui.BeginMenu("Power") then
                        -- systemD has its uses...
                        if imgui.MenuItem("Shutdown") then
                            os.execute("systemctl poweroff")
                        end
                        if imgui.MenuItem("Restart") then
                            os.execute("systemctl reboot")
                        end
                        if imgui.MenuItem("Sleep") then
                            os.execute("systemctl suspend")
                        end
                        imgui.EndMenu()
                    end
                    if imgui.MenuItem("Quit PiSPOS") then love.quit() end
                imgui.EndMenu();
            end
            if (imgui.BeginMenu("Applications")) then
                if imgui.MenuItem("Game selector") then clients.gameSelect = not clients.gameSelect end
                if imgui.MenuItem("Music Player") then clients.musicPlayer = not clients.musicPlayer end
                if imgui.MenuItem("screenFetch") then clients.screenFetch = not clients.screenFetch end
                if imgui.MenuItem("Input tester") then clients.inputTester = not clients.inputTester end
                imgui.EndMenu();
            end
            if (imgui.BeginMenu("Help")) then
                    if imgui.MenuItem("About") then clients.about = not clients.about end
                    if imgui.MenuItem("Demo") then clients.demo = not clients.demo end
                imgui.EndMenu();
            end
            imgui.EndMainMenuBar()
        end

        feh_DRAW()
        editor_DRAW()
        fileManager_DRAW()
        console_DRAW()
        imguiMetrics_DRAW()
        inputTester_DRAW()
        gameSelect_DRAW()
        about_DRAW()
        musicPlayer_DRAW()
        screenFetch_DRAW()

        if clients.demo then
            imgui.ShowTestWindow(true)
        end
    else -- Not authenticated
        for k,v in ipairs(clients) do
            print(v)
        end
    end
    imgui.PopStyleVar()
    imgui.Render()

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
        inputTesterKeys[#inputTesterKeys+1] = {key, love.timer.getTime()}
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
    inputTesterKeys[#inputTesterKeys+1] = {"mouse " .. button, love.timer.getTime()}
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

function setFullscreen()
    imgui.SetNextWindowPos(0, 17)
    imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight()-17)
end