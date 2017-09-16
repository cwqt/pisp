--  https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
require "imgui"
Gamestate = require("libs.hump.gamestate")
Camera  = require("libs.hump.camera")
CScreen = require("libs.cscreen")
flux    = require("libs.flux.flux")
lume    = require("libs.lume.lume")

require("games.pong")

-- OS
page    = require("os.page")
icon    = require("os.icon")
client  = require("os.client")

-- Programs
about   = require("clients.about")
console = require("clients.console")
editor  = require("clients.editor")
music   = require("clients.music")
files   = require("clients.files")
metrics = require("clients.metrics")
inputs  = require("clients.inputs")
games   = require("clients.games")
feh     = require("clients.feh")

PiSPOS = {}
function PiSPOS:init()
    startTime = love.timer.getTime()
    imgui.SetGlobalFontFromFileTTF("gohu.ttf", 11, 1, 1)
    PiSP = {
        userAuthenticated = true,
        version = "0.3.6",
        pageNo = 0,
        currentPage = 1,
        currentSlot = 1,
		wallpaper = love.graphics.newImage("spook.png"),
        font = love.graphics.newFont("os/GTPMR.ttf", 14)
    }

    pages = {}
    table.insert(pages, page:new({
        { games:new(),      "Games",   "images/Luv/categories/32/games.png" },
        { console:new(),    "Console", "images/Luv/apps/48/terminal.png" },
        { editor:new(),     "Editor",  "images/Luv/categories/32/editor.png" },
        { files:new(),      "Files",   "images/Luv/apps/48/filemanager.png" },
        { music:new(),      "Music",   "images/Luv/apps/32/music.png" },
        { metrics:new(),    "Metrics", "images/Luv/apps/32/metrics.png" }
    }))
    table.insert(pages, page:new({
        { inputs:new(),     "Inputs",   "images/Luv/actions/32/inputs.png" },
        { about:new(),      "About",    "images/Luv/status/48/about.png" },
        { feh:new(),         "feh",      "images/Luv/apps/32/feh.png" },
        { nil,              "Networks", "images/Luv/apps/32/networking.png" },
        { nil,              "PICO-8",   "images/pico8.png" },
    }))
end

function PiSPOS:enter()
    CScreen.init(320, 240, true)
    love.graphics.setFont(PiSP.font)

    PiSPCamera = Camera(screen.W/2, screen.H/2)
    pages[1].slots[1].focused = true
end

function PiSPOS:update(dt)
    imgui.NewFrame()
    flux.update(dt)
    pages[PiSP.currentPage].slots[PiSP.currentSlot].focused = true
    for k, icon in ipairs(pages[PiSP.currentPage].slots) do
        if icon.focused == true then
            flux.to(icon, 0.5, { r = math.rad(20) })
        else
            flux.to(icon, 0.2, {r = 0})
        end
    end
    -- Check if a page exists, move to it when asked
    if pages[PiSP.currentPage].ax ~= nil then
        PiSPCamera:lockX(pages[PiSP.currentPage].ax+screen.W/2, Camera.smooth.damped(10))
    end
end

function PiSPOS:draw()
    local status -- ??
    imgui.PushStyleVar("WindowRounding", 0)
    love.graphics.clear(50, 50, 50, 255)

    CScreen.apply()
        love.graphics.push()
            love.graphics.scale(0.1)
            --love.graphics.draw(PiSP.wallpaper, 2500, 1100)
        love.graphics.pop()
        if PiSP.userAuthenticated then
            love.graphics.print(os.date("%H:%M%P"), screen.W-65, 4)
            PiSPCamera:attach()
                for k, page in ipairs(pages) do
                    -- Define an actual x position for the camera
                    page.ax = screen.W*(k-1)
                    -- Shift each page to the right
                    page:draw(page.ax, 0)
                end
            PiSPCamera:detach()
        else -- Not authenticated
            muteAllOtherTracks()
        end
    CScreen.cease()

    -- BUG: currently renders all content inside one imgui window
    for k, slot in ipairs(pages[PiSP.currentPage].slots) do
        if type(slot.client) == "table" then
            if slot.client.drawing then
                imgui.SetNextWindowPos(0,0)
                imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight())            -- "MenuBar"
                status, slot.client.drawing = imgui.Begin(tostring(slot.client.windowTitle), true, {"AlwaysAutoResize", "NoTitleBar"})
                    slot.client:draw()
                imgui.End()
            end
        end
    end
    imgui.PopStyleVar()
    imgui.Render()

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

    -- Load clients if one exists for the icon, toggle it with space (temporary)
    if key == "space" and type(pages[PiSP.currentPage].slots[PiSP.currentSlot].client) == "table" then
        pages[PiSP.currentPage].slots[PiSP.currentSlot].client.drawing = not pages[PiSP.currentPage].slots[PiSP.currentSlot].client.drawing
    end

    -- UI programming is awful
    if key == "w" or key == "s" or key == "a" or key =="d" then
        for i=1, #pages[PiSP.currentPage].slots do
            pages[PiSP.currentPage].slots[i].focused = false
        end
    end
    if key == "d" then
        if PiSP.currentSlot == #pages[PiSP.currentPage].slots then
            if type(pages[PiSP.currentPage+1]) == "table" then
                PiSP.currentSlot = 1
                PiSP.currentPage = PiSP.currentPage + 1
            end
        else
            PiSP.currentSlot = PiSP.currentSlot + 1
        end
    elseif key == "a" then
        if PiSP.currentSlot == 1 then
            if type(pages[PiSP.currentPage-1]) == "table" then
                PiSP.currentSlot = #pages[PiSP.currentPage].slots
                PiSP.currentPage = PiSP.currentPage - 1
            end
        else
            PiSP.currentSlot = PiSP.currentSlot - 1
        end
    elseif key == "w" then
        if PiSP.currentSlot >= 3 then
            if pages[PiSP.currentPage].slots[PiSP.currentSlot-3] ~= nil then
                PiSP.currentSlot = PiSP.currentSlot - 3
            end
        else
            PiSP.currentSlot = PiSP.currentSlot + 3
        end
    elseif key == "s" then
        if PiSP.currentSlot <= 3 then
            if pages[PiSP.currentPage].slots[PiSP.currentSlot+3] ~= nil then
                PiSP.currentSlot = PiSP.currentSlot + 3
            end
        else
            PiSP.currentSlot = PiSP.currentSlot - 3
        end
    end
end

function love.keyreleased(key)
    imgui.KeyReleased(key)
    if key == "p" and Gamestate.current() ~= PiSPOS then
        PiSP.ReturnToPiSPMenu = true
    end
    if not imgui.GetWantCaptureKeyboard() then
    end
end

function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
        -- Pass event to the game
    end
end

--
-- Love setup
--
function love.load()
    collectgarbage()
    screen = {
        W = love.graphics.getWidth(),
        H = love.graphics.getHeight()
    }
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