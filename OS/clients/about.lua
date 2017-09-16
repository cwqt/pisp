local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local about = class('client')
function about:initialize()
    client.initialize(self)
end

function about:draw()
    imgui.Text( -- Thou art thine shitte oh ess
    " _____ _ _____ _____         \n"..
    "|  _  |_|   __|  _  |___ ___ \n"..
    "|   __| |__   |   __| . |_ -|\n"..
    "|__|  |_|_____|__|  |___|___ ")
    imgui.Text("PiSPOS v." .. PiSP.version)
    imgui.Separator()
    imgui.BeginChild("About content")
        imgui.TextWrapped("The PiSP is a open-source handheld game console inspired by PicoChip and the Sony PSP; created by May W. for the Level 3 EPQ.\n\n" ..
                          "PiSPOS runs on the LÖVE Lua framework making heavy use of the 'dear imgui' immediate mode GUI.\n\n"..
                          "You can find more documentation at: https://github.com/twentytwoo/PiSP\n\n")
        imgui.Text("Libraries/Software used:")
        imgui.BulletText("LÖVE,         https://love2d.org/")
        imgui.BulletText("love-imgui,   https://github.com/slages/love-imgui")
        imgui.BulletText("middleclass,  https://github.com/kikito/middleclass")
        imgui.BulletText("HUMP,         https://github.com/vrld/hump")
        imgui.Text("\nHardware used:")
        imgui.BulletText("Raspberry Pi Zero W")
        imgui.BulletText('Adafruit 2.2" 18-bit color TFT LCD')
        imgui.BulletText("Mini 2-Axis Analog Thumbstick")

        imgui.Text("Font: GohuFont, http://font.gohu.org/")
        imgui.Text("\n04/09/17 - PiSPOS released under MIT")
    imgui.EndChild()
end

return about