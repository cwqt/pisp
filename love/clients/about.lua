function about_LOAD()

end

function about_DRAW()
    setFullscreen()
    if clients.about then
        status, clients.about = imgui.Begin("About PiSP", true, {"AlwaysAutoResize"})
            imgui.SameLine(45) -- push text to center
            imgui.Text(
            "ooooooooo.  o8o   .oooooo..o  ooooooooo.  \n"..
            "`888   `Y88.  `''  d8P'    `Y8   `888   `Y88.\n"..
            " 888   .d88' oooo  Y88bo.       888   .d88'\n"..
            " 888ooo88P' `888    `'Y8888o.   888ooo88P' \n"..
            " 888          888       `'Y88b  888        \n"..
            " 888          888  oo     .d8P  888        \n"..
            "o888o        o888o 8''88888P'  o888o\n")
            imgui.Text("PiSP OS v." .. PiSP.version)
            imgui.Separator()
            imgui.BeginChild(1)
                imgui.TextWrapped("PiSP is a open-source handheld inspired by PicoChip; created by May W. for the Level 3 EPQ.\n" ..
                                  "You can find more documentation here: https://github.com/twentytwoo/PiSP\n\n")
                imgui.Text("Libraries/Software used:")
                imgui.BulletText("LÖVE,         https://love2d.org/")
                imgui.BulletText("love-imgui,   https://github.com/slages/love-imgui")
                imgui.BulletText("middleclass,  https://github.com/kikito/middleclass")
                imgui.BulletText("HUMP,         https://github.com/vrld/hump")
                imgui.Text("\nHardware used:")
                imgui.BulletText("Raspberry Pi Zero W")
                imgui.BulletText('Adafruit 2.2" 18-bit color TFT LCD')
                imgui.BulletText("Mini 2-Axis Analog Thumbstick")

                imgui.Text("Global Font is tiny.tff, http://www.dafont.com/tiny.font")
                imgui.Text("\n 19/08/17 - Software released under MIT")
            imgui.EndChild()
        imgui.End()
    end
end