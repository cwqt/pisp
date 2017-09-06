function gameSelect_LOAD()
    gameselect = {
        title = "",
        description = "",
        tags = "",
        state = ""
    }
    games = {
        {"Pong", pong, "A retro pong game where you play as a paddle hitting a ball", {"Arcade", "Retro", "Casual"},
    }
end

function gameSelect_DRAW()
    setFullscreen()
    if clients.gameSelect then
        status, clients.gameSelect = imgui.Begin("Game select", true, {"AlwaysAutoResize"})
            imgui.Columns(2);
            for k, game in ipairs(games) do
                if imgui.Button(game[1], imgui.GetColumnWidth()-10, 20 ) then
                    gameselect.title = game[1]
                    gameselect.state = game[2]
                    gameselect.description = game[3] or "No description"
                    gameselect.tags = game[4] or "No tags"
                end
            end
            imgui.NextColumn()
            imgui.BeginChild(1)
            imgui.Text(gameselect.title)
            imgui.TextWrapped(gameselect.description)

            -- Show the tags
            if type(gameselect.tags) == "table" then
                for i, tag in ipairs(gameselect.tags) do
                    imgui.SameLine()
                    -- Only show commas on every tag except the last
                    if i ~= #gameselect.tags then
                        imgui.Text(tag .. ", ")
                    else
                        imgui.Text(tag)                        
                    end
                end
            else -- "No tags", probably
                imgui.TextWrapped(gameselect.tags)
            end

            if gameselect.title ~= "" then
                if imgui.Button("Play", 50, 30) then
                    Gamestate.switch(gameselect.state)
                end
            end
            imgui.EndChild()
        imgui.End()
    end
end
