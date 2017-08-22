--  https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
require "imgui"

require("clients.login")
require("clients.musicPlayer")
require("clients.about")
require("clients.gameSelect")
require("clients.inputTester")
require("clients.screenFetch")

function love.load()
    clients = {}
    clients.musicPlayer = true
    startTime = love.timer.getTime()
    screen = {
        W = love.graphics.getWidth(),
        H = love.graphics.getHeight()
    }

    inputTester_LOAD()
    musicPlayer_LOAD()
    about_LOAD()
    gameSelect_LOAD()
    screenFetch_LOAD()

    login_LOAD()
end

function love.update(dt)
    require("libs.lovebird.lovebird").update()
    imgui.NewFrame()
end

function love.draw()
    local status -- ??
    love.graphics.clear(100, 100, 100, 255)

    love.graphics.push()
        love.graphics.scale(0.3, 0.3)         -- -sf.logo:getWidth()
        love.graphics.draw(screenFetch.logo, screen.W*(1/0.3)-30, screen.H*(1/0.3)-screenFetch.logo:getHeight(), 0, -1, 1)
    love.graphics.pop()

    login_DRAW()

    if userAuthenticated then
        -- Menu
        if imgui.BeginMainMenuBar() then
            if (imgui.BeginMenu("Menu")) then
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

        inputTester_DRAW()
        gameSelect_DRAW()
        about_DRAW()
        musicPlayer_DRAW()
        screenFetch_DRAW()
        if clients.demo then
            imgui.ShowTestWindow(true)
        end

    end
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

