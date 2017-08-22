function inputTester_LOAD()
    inputTesterKeys = {}
end

function inputTester_DRAW()
    -- Input tester game
    if clients.inputTester then
        imgui.SetNextWindowSize(200, 500)
        status, clients.inputTester = imgui.Begin("inputTester", true)
        imgui.Text("Logged: " .. #inputTesterKeys)
        imgui.SameLine(imgui.GetWindowWidth()-62)
        if imgui.Button("Clear") then
            inputTesterKeys = {}
        end
        imgui.Separator();
        -- Get latest key presses
        for i=#inputTesterKeys, 1, -1 do
            imgui.Text("[" .. string.sub(inputTesterKeys[i][2]-startTime, 1, 4) .. "s]: " .. string.upper(inputTesterKeys[i][1]) .. " pressed")
        end
        imgui.End()
    end
end