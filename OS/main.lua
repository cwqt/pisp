--  https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
require "imgui"
Gamestate = require("libs.hump.gamestate")
Camera = require("libs.hump.camera")
CScreen = require "libs.cscreen"

require("games.pong")

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


page = require("os.page")
icon = require("os.icon")

clients = {}
screen = {
    W = love.graphics.getWidth(),
    H = love.graphics.getHeight()
}

PiSPOS = {}
function PiSPOS:init()
    startTime = love.timer.getTime()
    imgui.SetGlobalFontFromFileTTF("gohu.ttf", 11, 1, 1)
    PiSP = {
        version = "0.3.6",
		wallpaper = love.graphics.newImage("spook.png"),
        currentPage = 1,
        currentClient = 1
    }
end

function PiSPOS:enter()
    CScreen.init(320, 240, true)

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

    clients.ReturnToPiSPMenu = false

    pages = {}
    table.insert(pages, page:new({
        { clients.feh, "Console", "images/48/star-48.png" },
        { clients.feh, "Editor", "images/48/edit-48.png" },
        { clients.feh, "Files", "images/48/documents-48.png" },
        { clients.feh, "Games", "images/48/play-48.png" },
        { clients.feh, "Input tester", "images/48/settings-48.png" },
        { clients.feh, "Metrics", "images/48/utilities-48.png" }
    }))
    PiSPCamera = Camera(320/2, 240/2, 1)
end

function PiSPOS:update(dt)
    imgui.NewFrame()
end

function PiSPOS:draw()
    local status -- ??
    imgui.PushStyleVar("WindowRounding", 0)
    love.graphics.clear(100, 100, 100, 255)

    CScreen.apply()

        love.graphics.push()
            love.graphics.scale(0.1)
            love.graphics.draw(PiSP.wallpaper, 2500, 1100)
        love.graphics.pop()
        login_DRAW()

        if userAuthenticated then

            love.graphics.print(os.date("%H:%M%P"), screen.W-60, 4)

            PiSPCamera:attach()
                for k, page in ipairs(pages) do
                    page:draw()
                end
            PiSPCamera:detach()

            -- more screaming
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
            muteAllOtherTracks()
        end

        imgui.PopStyleVar()
        imgui.Render()
    CScreen.cease()
end

--
-- Love setup
--
function love.load()
    collectgarbage()
    Gamestate.registerEvents()
    Gamestate.switch(PiSPOS)
end

function love.update()
    require("libs.lovebird.lovebird").update()
end

function love.draw()

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
        inputTesterKeys[#inputTesterKeys+1] = {key, love.timer.getTime()}
    if not imgui.GetWantCaptureKeyboard() then
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if key == "p" and Gamestate.current() ~= PiSPOS then
        clients.ReturnToPiSPMenu = true
    end
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
	    inputTesterKeys[#inputTesterKeys+1] = {"mouse " .. button, love.timer.getTime()}
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
--[[

    if userAuthenticated then
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
                if imgui.MenuItem("Games") then clients.gameSelect = not clients.gameSelect end
                if imgui.MenuItem("Music") then clients.musicPlayer = not clients.musicPlayer end
                if imgui.MenuItem("screenFetch") then clients.screenFetch = not clients.screenFetch end
                if imgui.MenuItem("Inputs") then clients.inputTester = not clients.inputTester end
                imgui.EndMenu();
            end
            if (imgui.BeginMenu("Help")) then
                    if imgui.MenuItem("About") then clients.about = not clients.about end
                    if imgui.MenuItem("Demo") then clients.demo = not clients.demo end
                imgui.EndMenu();
            end
            imgui.SameLine(imgui.GetWindowWidth()-60)
            imgui.MenuItem(os.date("%H:%M%P"))
            imgui.EndMainMenuBar()
        end
]]