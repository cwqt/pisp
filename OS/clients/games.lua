local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local games = class('client')
function games:initialize()
    client.initialize(self)
    self.gameSelect = {
        title = "",
        description = "",
        tags = "",
        state = ""
    }
    self.games = {
        {"Pong", pong, "A retro pong game where you play as a paddle hitting a ball", {"Arcade", "Retro", "Casual"}}
    }
end

function games:draw()
    imgui.Columns(2);
    for k, game in ipairs(self.games) do
        if imgui.Button(game[1], imgui.GetColumnWidth()-10, 20 ) then
            self.gameSelect.title = game[1]
            self.gameSelect.state = game[2]
            self.gameSelect.description = game[3] or "No description"
            self.gameSelect.tags = game[4] or "No tags"
        end
    end
    imgui.NextColumn()
    imgui.BeginChild(1)
    imgui.Text(self.gameSelect.title)
    imgui.TextWrapped(self.gameSelect.description)

    -- Show the tags
    if type(self.gameSelect.tags) == "table" then
        for i, tag in ipairs(self.gameSelect.tags) do
            -- Only show commas on every tag except the last
            if i ~= #self.gameSelect.tags then
                imgui.TextWrapped(tag .. ",")
                imgui.SameLine()
            else
                imgui.TextWrapped(tag)
            end
        end
    else -- "No tags", probably
        imgui.TextWrapped(self.gameSelect.tags)
    end

    if self.gameSelect.title ~= "" then
        if imgui.Button("Play", 50, 30) then
            Gamestate.switch(self.gameSelect.state)
        end
    end
    imgui.EndChild()
end

return games