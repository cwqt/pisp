function about_LOAD()

end

function about_DRAW()
    if clients.about then
        imgui.SetNextWindowSize(410, 300)
        status, clients.about = imgui.Begin("About PiSP", true, {"AlwaysAutoResize"})
            imgui.SameLine(65) -- push text to center
            imgui.Text(
            "::::::::::. ::: .::::::.::::::::::. \n" ..
            " `;;;```.;;;;;;;;;`    ` `;;;```.;;;\n" ..
            "  `]]nnn]]' [[['[==/[[[[, `]]nnn]]' \n" ..
            "   $$$''    $$$  '''    $  $$$''    \n" ..
            "   888o     888 88b    dP  888o     \n" ..
            "   YMMMb    MMM  'YMmMY'   YMMMb    \n")
            imgui.Separator()
            imgui.BeginChild(1)
                imgui.TextWrapped("PiSP is a open-source handheld inspired by PicoChip; created by May W. for the Level 3 EPQ.\n" ..
                                  "You can find more documentation here: https://github.com/twentytwoo\n\n")
                imgui.Text("Libraries/Software used:")
                imgui.BulletText("love-imgui,  https://github.com/slages/love-imgui")
                imgui.BulletText("middleclass, https://github.com/kikito/middleclass")
                imgui.BulletText("HUMP,        https://github.com/vrld/hump")
                imgui.Text("\nHardware used:")
                imgui.BulletText("Raspberry Pi Zero W")
                imgui.BulletText('Adafruit 2.2" 18-bit color TFT LCD')
                imgui.BulletText("Mini 2-Axis Analog Thumbstick")
                imgui.Text("\n 19/08/17 - Software released under MIT")
            imgui.EndChild()
        imgui.End()
    end
end