--  https://github.com/ocornut/imgui/blob/master/imgui_demo.cpp
GPIO      = require('periphery').GPIO
            require "imgui"

Gamestate = require("libs.hump.gamestate")
Camera    = require("libs.hump.camera")
flux      = require("libs.flux.flux")
lume      = require("libs.lume.lume")

-- OS
page      = require("os.page")
icon      = require("os.icon")
client    = require("os.client")
            require("clients.login")

-- System objects
battery   = require("os.objects.battery")
power     = require("os.objects.power")

-- Programs
about     = require("clients.about")
console   = require("clients.console")
editor    = require("clients.editor")
music     = require("clients.music")
files     = require("clients.files")
metrics   = require("clients.metrics")
inputs    = require("clients.inputs")
games     = require("clients.games")
feh       = require("clients.feh")
settings  = require("clients.settings")
sf        = require("clients.screenfetch")

-- Games
require("games.pong")

skipSplash = false

PiSPOS = {}
function PiSPOS:init()
    startTime = love.timer.getTime()
    imgui.SetGlobalFontFromFileTTF("gohu.ttf", 11, 1, 1)
    PiSP = {
        userAuthenticated = false,
        version = "0.3.7",
        pageNo = 0,
        currentPage = 1,
        currentSlot = 1,
		wallpaper = love.graphics.newImage("spook.png"),
        font = love.graphics.newFont("os/GTPMR.ttf", 14),
        imguiHasKeys = false
    }

    login_LOAD()

    pages = {
        page:new({
            { games:new(),             "Games",    "images/Luv/categories/32/games.png" },
            { console:new(),           "Console",  "images/Luv/apps/48/terminal.png" },
            { editor:new({"MenuBar"}), "Editor",   "images/Luv/categories/32/editor.png" },
            { files:new(),             "Files",    "images/Luv/apps/48/filemanager.png" },
            { music:new(),             "Music",    "images/Luv/apps/32/music.png" },
            { metrics:new(),           "Metrics",  "images/Luv/apps/32/metrics.png" }
        }),
        page:new({
            { inputs:new(),            "Inputs",   "images/Luv/actions/32/inputs.png" },
            { about:new(),             "About",    "images/Luv/status/48/about.png" },
            { feh:new(),               "feh",      "images/Luv/apps/32/feh.png" },
            { settings:new(),          "Settings", "images/Luv/actions/48/settings.png" },
            { nil,                     "Pico-8",   "images/pico8.png" },
            { nil,                     "RetroPie", "images/RetroPie.png"}
        }),
        page:new({
            { sf:new(),                "screenFetch" },
        })
    }

    systemObjects = {
        battery:new(60, 10, 5),
        power:new(10, 210),
    }
end

function PiSPOS:enter()
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
            flux.to(icon, 0.2, { r = math.rad(20) })
        else
            flux.to(icon, 0.2, {r = 0})
        end
    end

    -- Check if a page exists, move to it when asked
    if pages[PiSP.currentPage].ax ~= nil then
        PiSPCamera:lockX(pages[PiSP.currentPage].ax+screen.W/2, Camera.smooth.damped(10))
    end

    for k, object in ipairs(systemObjects) do
        object:update(dt)
    end
end

function PiSPOS:draw()
    local status -- ??
    imgui.PushStyleVar("WindowRounding", 0)
    love.graphics.clear(40, 40, 40, 255)

        love.graphics.push()
            love.graphics.scale(0.1)
            love.graphics.draw(PiSP.wallpaper, 2500, 1100)
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
            -- Crappy solution that allows one client open per page, see love.keypressed...
            for k, slot in ipairs(pages[PiSP.currentPage].slots) do
                if type(slot.client) == "table" then
                    if slot.client.drawing then
                        imgui.SetNextWindowPos(0,0)
                        imgui.SetNextWindowSize(love.graphics.getWidth(), love.graphics.getHeight())            -- "MenuBar"
                        status, slot.client.drawing = imgui.Begin("none", true, {"AlwaysAutoResize", "NoTitleBar", unpack(slot.client.args)})
                            slot.client:draw()
                        imgui.End()
                    end
                end
            end

            -- Draw system objects, batteries, power off etc.
            for k, object in ipairs(systemObjects) do
                object:draw()
            end
        else -- Not authenticated
            login_DRAW()
        end

    PiSP.imguiHasKeys = false
    -- A slow algo that detects if any client on any page is open
    for i, page in pairs(pages) do
    -- Check through all pages
        for _, slots in pairs(pages[i]) do
        -- And all their slots
            for _, slot in pairs(page.slots) do
                -- Verify a client exists
                if type(slot.client) == "table" then
                    -- Check if it's being drawn, disable background keys
                    if slot.client.drawing == true then
                        PiSP.imguiHasKeys = true
                    end
                end
            end
        end
    end

    imgui.PopStyleVar()
    imgui.Render()
end

function PiSPOS:keypressed(key)
    if PiSP.userAuthenticated then
        -- Load clients if one exists for the icon
        if key == "`" and type(pages[PiSP.currentPage].slots[PiSP.currentSlot].client) == "table" then
            -- Stop drawing all current clients
            for k, slot in ipairs(pages[PiSP.currentPage].slots) do
                if type(slot.client) == "table" then
                    -- Be able to toggle the current client on and off, because later not
                    if slot.client ~= pages[PiSP.currentPage].slots[PiSP.currentSlot].client then
                        -- Draw the client currently selected
                        if slot.client.drawing then
                            slot.client.drawing = false
                        end
                    end
                end
            end
            -- Draw the client that is currently selected
            pages[PiSP.currentPage].slots[PiSP.currentSlot].client.drawing = not pages[PiSP.currentPage].slots[PiSP.currentSlot].client.drawing
        end

        -- Only move around if no clients are open
        if PiSP.imguiHasKeys == false then
            -- UI programming is awful
            if key == "w" or key == "up" or key == "s" or key == "down" or key == "a" or key == "left" or key == "d" or key == "right" then
                for i=1, #pages[PiSP.currentPage].slots do
                    pages[PiSP.currentPage].slots[i].focused = false
                end
            end
            if key == "d" or key == "right" then
                if PiSP.currentSlot == #pages[PiSP.currentPage].slots then
                    if type(pages[PiSP.currentPage+1]) == "table" then
                        PiSP.currentSlot = 1
                        PiSP.currentPage = PiSP.currentPage + 1
                    end
                else
                    PiSP.currentSlot = PiSP.currentSlot + 1
                end
            elseif key == "a" or key == "left" then
                if PiSP.currentSlot == 1 then
                    if type(pages[PiSP.currentPage-1]) == "table" then
                        PiSP.currentSlot = #pages[PiSP.currentPage-1].slots
                        PiSP.currentPage = PiSP.currentPage - 1
                    end
                else
                    PiSP.currentSlot = PiSP.currentSlot - 1
                end
            elseif key == "w" or key == "up" then
                if PiSP.currentSlot >= 3 then
                    if pages[PiSP.currentPage].slots[PiSP.currentSlot-3] ~= nil then
                        PiSP.currentSlot = PiSP.currentSlot - 3
                    end
                else
                    PiSP.currentSlot = PiSP.currentSlot + 3
                end
            elseif key == "s" or key == "down" then
                if PiSP.currentSlot <= 3 then
                    if pages[PiSP.currentPage].slots[PiSP.currentSlot+3] ~= nil then
                        PiSP.currentSlot = PiSP.currentSlot + 3
                    end
                else
                    PiSP.currentSlot = PiSP.currentSlot - 3
                end
            end
        end
    end
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
    Gamestate.switch(boot)
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
-- Boot screen
--
boot = {}
splashy = require('libs.splashy.splashy')

function boot:init()
    bootImages = {
        love.graphics.newImage("images/pico8.png"),
        love.graphics.newImage("images/pico8.png")
    }
    bootFont = love.graphics.newFont("os/GTPMR.ttf", 14)
    love.graphics.setFont(bootFont)
end

function boot:enter()
    if skipSplash then Gamestate.switch(PiSPOS) end
    for _, image in ipairs(bootImages) do
        splashy.addSplash(image, 1)
    end
    splashy.onComplete(function() Gamestate.switch(PiSPOS) end)
end

function boot:update(dt)
    splashy.update(dt)
end

function boot:draw()
    love.graphics.print("PiSPOS", 10, screen.H-25)
    love.graphics.print("", screen.W-40, screen.H-25)
    splashy.draw()
end

function boot:keypressed(key)
    if key == "space" then
        splashy.skipAll()
    end
end