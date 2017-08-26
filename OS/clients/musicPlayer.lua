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
        music.tracks[#music.tracks+1] = {filename, track=love.audio.newSource("music/" .. filename)}
    end
end

function musicPlayer_DRAW()
    setFullscreen()
    if clients.musicPlayer then
        status, clients.musicPlayer = imgui.Begin("Music", true, {"AlwaysAutoResize"})

            --[[
            status, music.searchQuery = imgui.InputText("", music.searchQuery, 100, 100)
            imgui.SameLine()
            if imgui.Button("Search") then
            end

            imgui.Text("Directory: music/")
            imgui.Separator()
            ]]

            imgui.BeginChild("one", imgui.GetWindowContentRegionWidth(), 110, false, {"HorizontalScrollbar", "NoBorder"})
            --imgui.SetScrollHere();
            for i, filename in ipairs(music.tracks) do
                if imgui.Selectable(filename[1], music.test, {"SpanAllColumns"}) then
                    -- Stop the other tracks if one is playing
                    imgui.NextColumn()
                    muteAllOtherTracks()
                    -- Change over to the new track
                    music.currentTrackKey = i
                    filename.track:play()
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

function muteAllOtherTracks() -- music.tracks[1].track
    if type(music.tracks[music.currentTrackKey].track) == "userdata" then
        music.tracks[music.currentTrackKey].track:stop()
    end
end

--I'm lazy
--https://gist.github.com/jesseadams/791673
function secondsToClock(seconds)
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