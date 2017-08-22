function gameSelect_LOAD()
    gameselect = {
        title = "",
        description = "",
        tags = ""
    }
    games = {
        {"Pong", "A retro pong game where you play as a paddle hitting a ball", "Arcade, Retro, Casual"},
        {"Pacman", "Play as a yellow munchy thing"},
        {"Space Invaders", "Did you know, the reason why Space Invaders gets faster when more enemies are killed is because the number of draw calls decreases, thus FPS increases"}
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
                    gameselect.description = game[2] or "No description"
                    gameselect.tags = game[3] or "No tags"
                end
            end
            imgui.NextColumn()
            imgui.BeginChild(1)
            imgui.Text(gameselect.title)
            imgui.TextWrapped(gameselect.description)
            imgui.TextWrapped(gameselect.tags)
            if gameselect.title == "Pong" then
                if imgui.Button("Play", 50, 30) then
                end
            end
            imgui.EndChild()
        imgui.End()
    end
end