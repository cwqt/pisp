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
    -- Log in
    imgui.SetNextWindowPos(screen.W/2-142.5, screen.H/2-50)
    imgui.SetNextWindowSize(285, 80)
    if not userAuthenticated then
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