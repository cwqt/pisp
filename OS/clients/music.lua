local class = require('libs.middleclass.middleclass')
local client = require('os.client')

local music = class('client')
function music:initialize()
    client.initialize(self)
    self.music = {
        currentTrackKey = 1,
        volume = 0.8,
        currentTime = 0,
        currentlyPlaying = "",
        currentTitle = "",
        searchQuery = "",
        files = love.filesystem.getDirectoryItems("music"),
        tracks = {},
    }

    for k, filename in ipairs(self.music.files) do
        -- Insert all tracks and show them all
        self.music.tracks[#self.music.tracks+1] = {filename, track=love.audio.newSource("music/" .. filename), show=true}
    end
end

function music:draw()
    -- Create a search bar and search button
    status, self.music.searchQuery = imgui.InputText("", self.music.searchQuery, 100, 100)
    imgui.SameLine()

    if imgui.Button("Search") then
        for k, filename in ipairs(self.music.tracks) do
            -- Filter results by checking against current search contents
            if string.find(filename[1], self.music.searchQuery) then
                filename.show = true
            else
                filename.show = false
            end
        end
    end

    imgui.Text("Directory: music/")
    imgui.Separator()

    imgui.BeginChild("one", imgui.GetWindowContentRegionWidth(), 100, false, {"HorizontalScrollbar", "NoBorder"})
    --imgui.SetScrollHere();
    for i, filename in ipairs(self.music.tracks) do
        if filename.show then
            if imgui.Selectable(filename[1], self.music.test, {"SpanAllColumns"}) then
                -- Stop the other tracks if one is playing
                imgui.NextColumn()
                self:muteAllOtherTracks()
                -- Change over to the new track
                self.music.currentTrackKey = i
                filename.track:play()
            end
        end
    end
    imgui.EndChild()

    imgui.Separator()

    if imgui.Button("Previous") then
        self:muteAllOtherTracks()
        if self.music.tracks[self.music.currentTrackKey-1] ~= nil then
            self.music.currentTrackKey = self.music.currentTrackKey - 1
        else
            self.music.currentTrackKey = #self.music.tracks
        end
        self.music.tracks[self.music.currentTrackKey].track:play()
    end
    imgui.SameLine()
    if imgui.Button("Play") then
        self.music.tracks[self.music.currentTrackKey].track:play()
    end
    imgui.SameLine()
    if imgui.Button("Pause") then
        self.music.tracks[self.music.currentTrackKey].track:pause()
    end
    imgui.SameLine()
    if imgui.Button("Next") then
        self:muteAllOtherTracks()
        if self.music.tracks[self.music.currentTrackKey+1] ~= nil then
            self.music.currentTrackKey = self.music.currentTrackKey + 1
        else
            self.music.currentTrackKey = 1
        end
        self.music.tracks[self.music.currentTrackKey].track:play()
    end

    -- just strips the last 4 chars off the string
    imgui.Text("Currently playing: " .. string.sub(self.music.tracks[self.music.currentTrackKey][1], 1, string.len(self.music.tracks[self.music.currentTrackKey][1])-4))
    status, self.music.volume = imgui.SliderFloat("Volume", self.music.volume, 0, 1)
    if type(self.music.tracks[self.music.currentTrackKey].track) == "userdata" then
        self.music.tracks[self.music.currentTrackKey].track:setVolume( self.music.volume )
    end
    -- Get current and end time of currently playing track
    status, self.music.currentTime = imgui.SliderFloat(self:secondsToClock(self.music.tracks[self.music.currentTrackKey].track:tell("seconds")) .. "-" .. self:secondsToClock(self.music.tracks[self.music.currentTrackKey].track:getDuration("seconds")), self.music.tracks[self.music.currentTrackKey].track:tell("seconds"), 0, self.music.tracks[self.music.currentTrackKey].track:getDuration("seconds"))
end

function music:muteAllOtherTracks() -- music.tracks[1].track
    if type(self.music.tracks[self.music.currentTrackKey].track) == "userdata" then
        self.music.tracks[self.music.currentTrackKey].track:stop()
    end
end

--I'm lazy
--https://gist.github.com/jesseadams/791673
function music:secondsToClock(seconds)
  local seconds = tonumber(seconds)

  if seconds <= 0 then
    return "00:00";
  else
    hours = string.format("%02.f", math.floor(seconds/3600));
    mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)));
    secs = string.format("%02.f", math.floor(seconds - hours*3600 - mins *60));
    return mins..":"..secs
  end
end

return music

--[[

function musicPlayer_LOAD()
    music = {
        currentTrackKey = 1,
        volume = 0.8,
        currentTime = 0,
        currentlyPlaying = "",
        currentTitle = "",
        searchQuery = "",
        files = love.filesystem.getDirectoryItems("music"),
        tracks = {},
    }

    for k, filename in ipairs(music.files) do
        -- Insert all tracks and show them all
        music.tracks[#music.tracks+1] = {filename, track=love.audio.newSource("music/" .. filename), show=true}
    end
end

function musicPlayer_DRAW()
    setFullscreen()
    if clients.musicPlayer then
        status, clients.musicPlayer = imgui.Begin("Music", true, {"AlwaysAutoResize"})

            -- Create a search bar and search button
            status, music.searchQuery = imgui.InputText("", music.searchQuery, 100, 100)
            imgui.SameLine()

            if imgui.Button("Search") then
                for k, filename in ipairs(music.tracks) do
                    -- Filter results by checking against current search contents
                    if string.find(filename[1], music.searchQuery) then
                        filename.show = true
                    else
                        filename.show = false
                    end
                end
            end

            imgui.Text("Directory: music/")
            imgui.Separator()

            imgui.BeginChild("one", imgui.GetWindowContentRegionWidth(), 70, false, {"HorizontalScrollbar", "NoBorder"})
            --imgui.SetScrollHere();
            for i, filename in ipairs(music.tracks) do
                if filename.show then
                    if imgui.Selectable(filename[1], music.test, {"SpanAllColumns"}) then
                        -- Stop the other tracks if one is playing
                        imgui.NextColumn()
                        muteAllOtherTracks()
                        -- Change over to the new track
                        music.currentTrackKey = i
                        filename.track:play()
                    end
                end
            end
            imgui.EndChild()

            imgui.Separator()

            if imgui.Button("Previous") then
                muteAllOtherTracks()
                if music.tracks[music.currentTrackKey-1] ~= nil then
                    music.currentTrackKey = music.currentTrackKey - 1
                else
                    music.currentTrackKey = #music.tracks
                end
                music.tracks[music.currentTrackKey].track:play()
            end
            imgui.SameLine()
            if imgui.Button("Play") then
                music.tracks[music.currentTrackKey].track:play()
            end
            imgui.SameLine()
            if imgui.Button("Pause") then
                music.tracks[music.currentTrackKey].track:pause()
            end
            imgui.SameLine()
            if imgui.Button("Next") then
                muteAllOtherTracks()
                if music.tracks[music.currentTrackKey+1] ~= nil then
                    music.currentTrackKey = music.currentTrackKey + 1
                else
                    music.currentTrackKey = 1
                end
                music.tracks[music.currentTrackKey].track:play()
            end

            -- just strips the last 4 chars off the string
            imgui.Text("Currently playing: " .. string.sub(music.tracks[music.currentTrackKey][1], 1, string.len(music.tracks[music.currentTrackKey][1])-4))
            status, music.volume = imgui.SliderFloat("Volume", music.volume, 0, 1)
            if type(music.tracks[music.currentTrackKey].track) == "userdata" then
                music.tracks[music.currentTrackKey].track:setVolume( music.volume )
            end
            -- Get current and end time of currently playing track
            status, music.currentTime = imgui.SliderFloat(secondsToClock(music.tracks[music.currentTrackKey].track:tell("seconds")) .. "-" .. secondsToClock(music.tracks[music.currentTrackKey].track:getDuration("seconds")), music.tracks[music.currentTrackKey].track:tell("seconds"), 0, music.tracks[music.currentTrackKey].track:getDuration("seconds"))
        imgui.End()
    else
        --muteAllOtherTracks()
    end
end
]]

