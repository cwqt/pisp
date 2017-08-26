function login_LOAD()
    login = {
        auth = {
            username = "milk",
            password = "succ"
        },
        username = "",
        password = "",
        errorMsg = ""
    }
    userAuthenticated = true
end

function login_DRAW()
    if not userAuthenticated then
        imgui.SetNextWindowPos(5, 5)
        imgui.Begin("PiSP OS",  false, { "AlwaysAutoResize", "NoTitleBar" })
            imgui.Text("PiSP OS")
        imgui.End()
        imgui.SetNextWindowPos(5, 38)
        imgui.Begin("Login",  false, { "AlwaysAutoResize", "NoTitleBar" })
            -- Set focus to input on startup
            if not imgui.IsAnyItemActive() then
                imgui.SetKeyboardFocusHere()
            end
            status, login.username = imgui.InputText("Username", login.username, 100, 100)
            status, login.password = imgui.InputText("Password", login.password, 64, {"Password", "CharsNoBlank"})
            if imgui.Button("Enter") then
                verifyAuthentication()
            end
            imgui.SameLine()
            imgui.Text(login.errorMsg)
        imgui.End()
    end
end

function verifyAuthentication()
    if login.username == login.auth.username and login.password == login.auth.password then
        userAuthenticated = true
    else
        login.errorMsg = "Invalid credentials!"
    end
end