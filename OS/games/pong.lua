--[[=========================== Juicy Pong ===========================]]--
--[[         Created 24/10 - 28/10/16, github.com/twentytwoo          ]]--
--[[                        Using Lua & LOVE2D                        ]]--
--[[==================================================================]]--

Gamestate = require "libs.hump.gamestate"   -- Gamestate handling
Timer = require "libs.hump.timer"           -- Timed events
Camera = require "libs.hump.camera"         -- Camera controls
bump = require "libs.bump.bump"                  -- Collision handler
flux = require "libs.flux.flux"                  -- Tweening
shine = require "libs.shine"                -- Post-processing

--mainFont = love.graphics.newFont("pixel.ttf", 12)
--love.graphics.setFont(mainFont)

pong= {}
function pong:enter()
music = love.audio.newSource("music/pong-music.mp3")
music:play()
music:setLooping(true)
love.graphics.setBackgroundColor(135,206,250)
love.mouse.setVisible(false)

player = {
    x = 20,
    y = screen.H/2-50,
    w = 10,
    h = 50,
    yvel = 0,
    speed = 300,
    direction = 1,
    wins = false,
    name = "player",
        goal = {
            x = 0,
            y = 10,
            w = 10,
            h = screen.H-20
        }
}
ai = {
    x = screen.W-player.w-20,
    y = screen.H/2-player.h/2,
    w = player.w,
    h = player.h,
    yvel = 0,
    origspeed = 20, -- same as speed
    speed = 10,
    inMiddle = true,
    smoother = 30,
    CanMove = false,
    wins = false,
    name = "ai",
        goal = {
            x = screen.W-10,
            y = 10,
            w = 10,
            h = screen.H-20
        }
}
ball = {
    x = screen.W/2-5, -- 1/2 of radius,center
    y = screen.H/2,
    r = 5,
    xvel = 0,
    yvel = 0,
    origspeed = 300, -- same as speed
    speed = 300,
    accelerator = 0,
    maxvel = 10,
    direction = 1,
    xvel = 0,
    yvel = 0,
    rotation = math.rad(45),
    collided = false,
    name = "ball"
}
score = {
    player = 0,
    ai = 0,
    winCount = 10
}
top = {
    name="top",
    x = 0,
    y = 0,
    w = screen.W,
    h = 10
}
bottom = {
    name="bottom",
    x = 0,
    y = screen.H-10,
    w = screen.W,
    h = 10,
}
console = {
    displayed = false
}
text = {
    size = 1
}
angleAmp = 10 -- amplify reflection angle

-- Bump init
world = bump.newWorld()
world:add(player, player.x, player.y, player.w, player.h)
world:add(ai, ai.x, ai.y, ai.w, ai.h)
world:add(ball, ball.x, ball.y, ball.r, ball.r)
world:add(top, top.x, top.y, top.w, top.h)
world:add(bottom, bottom.x, bottom.y, bottom.w, bottom.h)

-- Trailing hypespeed
positions = {}
maxPositions = 100
-- Paddle particles
local particle = love.graphics.newImage('images/particle.png')

makeConfetti = love.graphics.newParticleSystem(particle, 32)
makeConfetti:setParticleLifetime(0.5, 1) -- Particles live at least 2s and at most 5s.
makeConfetti:setColors(255, 255, 255, 255, 255, 255, 255, 0) -- Fade to black.

-- Init
newRound()

-- Post processing effects
local crt = shine.crt()
local scanlines = shine.scanlines()
local trailer = shine.posterize()
trailer.parameters = { num_bands = 20 }
post_effect =  scanlines
trail_effect = trailer

camera = Camera(screen.W/2, screen.H/2)
end

function pong:update(dt)

-- Player controls
    if love.keyboard.isDown('w') or love.keyboard.isDown('up') then
        player.yvel = player.speed*dt
        player.direction = -1
    elseif love.keyboard.isDown('s') or love.keyboard.isDown('down') then
        player.yvel = player.speed*dt
        player.direction = 1
        else player.yvel = 0
    end
    -- Player direction (up/down)
    player.y = player.y + player.yvel * player.direction
    -- Limit paddle speed
    if player.yvel > player.speed then player.yvel = player.speed end
    -- Update player.x associated with bounding box
    world:move(player, player.x, player.y)
    -- Update the player associated bounding box in the world
    player.x, player.y, cols, len = world:move(player, player.x, player.y)

    -- Get impact angle of the ball relative to the center of the paddle
    function getAngle(paddle)
        local centerX, centerY = paddle.x+paddle.w/2, paddle.y+paddle.h/2
        local hypotenuse = math.floor(math.sqrt((ball.x-centerX)^2+(ball.y-centerY)^2))
        local opposite = ball.y - centerY
        local angle = math.floor(math.deg(math.sin(opposite/hypotenuse)))
        return hypotenuse, opposite, angle
    end -- return values below
    pH, pO, pA = getAngle(player)
    aH, aO, aA = getAngle(ai)

    -- Ball controls
    ball.xvel = (ball.speed * ball.direction) -- Ball direction on reset() / start
    ball.x = ball.x - ball.xvel * dt
    ball.y = ball.y - (ball.yvel) * dt

    -- Move ball
    local function bounce(item, other) return "bounce" end
    ball.x, ball.y, cols, len = world:move(ball, ball.x, ball.y, bounce)
    if len > 0 then ball.collided = true else ball.collided = false end
    if ball.collided == true then ball.direction = ball.direction*-1 end

    -- Limit x/y velocity of ball
    if ball.xvel > ball.speed then ball.xvel = ball.speed end
    if ball.yvel > ball.speed then ball.yvel = ball.speed end

    for i,v in ipairs (cols) do
        if cols[i].normal.y == -1 then -- Hit the bottom
            ball.yvel = -ball.yvel
            ball.direction = ball.direction * -1
        elseif cols[i].normal.y == 1 then -- Hit the top
            ball.yvel = -ball.yvel
            ball.direction = ball.direction * -1
        end
        if cols[i].normal.x ~= 0 then -- Hit player paddle
            if ball.direction == -1 then
                ball.yvel = ball.yvel - pA * angleAmp
                pushBack(player)
            elseif ball.direction == 1 then -- Hit AI paddle
                ball.yvel = ball.yvel - aA * angleAmp
                pushBack(ai)
            end
            makeConfetti:emit(32)
            playSound("hit")
            squashBall()
            if ball.yvel > 550 or ball.yvel < -550 then playSound("hyperspeed") shakeCam() end -- Because i'm lazy
        end
    end

    -- AI
    -- Control AI movement according to ball position if over 'CanMove' line
    if ball.direction == 1 then
         ai.CanMove = false
    elseif ball.x > screen.W/3 then
        ai.CanMove = true
    end

    -- Remain stationary if current ball trajectory within x bounds
    if ai.CanMove == true then
        moveToMiddle:stop() -- Stop tweening
        if ball.y > ai.y+ai.h-(ai.h/3) then
            inMiddle = false
        elseif ball.y > ai.y+(ai.h/3) then
            inMiddle = true
            else inMiddle = false
        end
        if inMiddle == true then
            ai.yvel = ai.yvel * (1 - math.min(dt*ai.smoother, 1))
        elseif inMiddle == false then
            if ball.y > ai.y then
                ai.yvel = ai.yvel + ai.speed * dt
            elseif ball.y < ai.y+ai.h then
                ai.yvel = ai.yvel - ai.speed * dt
            end
        end
    ai.y = ai.y + ai.yvel * (1 - math.min(dt*ai.smoother, 1))
    elseif ai.CanMove == false then -- Go back to the centre
            moveToMiddle = flux.to(ai, 0.5, { y = screen.H/2-ai.h/2  }):ease("linear")
    end

    -- Limit y velocity of ai
    if ai.yvel > ai.speed then ai.yvel = ai.speed end
    -- bump move ai
    ai.x, ai.y, cols, len = world:move(ai, ai.x, ai.y)

    -- Scoring
    if ball.x < 0 then
        score.ai = score.ai + 1
        playSound("lose")
        newRound()
    elseif ball.x > screen.W then
        score.player = score.player + 1
        playSound("win")
        newRound()
        increaseDifficulty()
    end

    if score.player == score.winCount or score.ai == score.winCount then
        if score.player == score.winCount then winner = "Player wins!"
        elseif score.ai == score.winCount then winner = "A.I. wins!"
        end
        winnerWidth = 10 --mainFont:getWidth(winner)
        winnerHeight = 10 --mainFont:getHeight(winner)
        endGame()
    end

    -- Bump updates
    world:update(player, player.x, player.y)
    world:update(ai, ai.x, ai.y)
    world:update(ball, ball.x, ball.y)

    -- HUMP timer
    Timer.update(dt)
    flux.update(dt)

    -- Particles
    makeConfetti:update(dt)
    positionActual = { x = ball.x, y = ball.y}
    speedTrail()
    table.insert(positions, positionActual)
    if #positions > maxPositions then
       table.remove(positions, 1)
    end

    imgui.NewFrame()
end

function pong:draw()
    post_effect:draw(function()
        camera:attach()
            -- Items
            love.graphics.setColor(255,64,64)
            love.graphics.rectangle("fill", player.x, player.y, player.w, player.h)
            love.graphics.rectangle("fill", ai.x, ai.y, ai.w, ai.h)
            love.graphics.setColor(255,255,255)
            love.graphics.rectangle("fill", ball.x, ball.y, ball.r, ball.r)

            -- Scores
            love.graphics.print(score.player, 20, 15, 0)
            love.graphics.print(score.ai, screen.W-30, 15)

            -- Borders
            love.graphics.rectangle("fill", top.x, top.y, top.w, top.h)
            love.graphics.rectangle("fill", bottom.x, bottom.y, bottom.w, bottom.h)
            love.graphics.print("|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|\n|", screen.W/2) -- lmao

            -- Draw ball direction on new round
            if drawBallDirection == true then showBallDirection() end

            -- Scoring alert
            if showWinner == true then
                love.graphics.setColor(255,64,64)
                love.graphics.rectangle("fill", screen.W/2-winnerWidth/2-10, screen.H/2-winnerHeight/2-10, winnerWidth+20, winnerHeight+20 )
                love.graphics.setColor(255,255,255)
                love.graphics.print(winner, screen.W/2-winnerWidth/2, screen.H/2-winnerHeight/2)
            end

            -- Particles
            drawConfetti()
            if ball.direction == 1 then
                makeConfetti:setLinearAcceleration(400, -400, 800, 400) -- Randomized movement towards the bottom of the screen.
            elseif ball.direction == -1 then
                makeConfetti:setLinearAcceleration(400, -400, -800, 400) -- Randomized movement towards the bottom of the screen.
            end
            if hyperspeed == true then
                for i = 1, #positions do
                    love.graphics.setColor(255, 255, 255, (40/#positions)*i)
                    love.graphics.rectangle("fill", positions[i].x, positions[i].y, ball.r, ball.r)
                end
            end
        camera:detach()

        -- Feedback
        if console.displayed == true then
        love.graphics.setColor(255,255,255,255)
        love.graphics.print(
            "player.y = " .. math.floor(player.y) .. "\n" ..
            "player.yvel = " .. math.floor(player.yvel) * player.direction .. "\n\n\n" ..
            "ai.y = " .. math.floor(ai.y) .. "\n" ..
            "ai.yvel = " .. math.floor(ai.yvel) .. "\n" ..
            "ai.speed = " .. ai.speed .. "\n" ..
            "ai.h = " .. ai.h .. "\n" ..
            "ai.CanMove = " .. tostring(ai.CanMove) .. "\n\n" ..
            "ball.x = " .. math.floor(ball.x) .. "\n" ..
            "ball.y = " .. math.floor(ball.y) .. "\n" ..
            "ball.yvel = " .. ball.yvel .. "\n" ..
            "ball.xvel = " .. ball.xvel .. "\n" ..
            "ball.collision = " .. tostring(ball.collided) .. "\n" ..
            "ball.speed = " .. ball.speed .. "\n" ..
            "ball.accelerator = " .. ball.accelerator .. "\n" ..
            "ball.direction = " .. ball.direction,
            80, 22)
        love.graphics.print(
            -- Angle feedback
            "player hyp. = " .. pH .. "\n" ..
            "player opp. = " .. math.floor(pO) .. "\n" ..
            "player ang. = " .. pA .. "\n\n" ..

            "ai hyp. = " .. aH .. "\n" ..
            "ai opp. = " .. math.floor(aO) .. "\n" ..
            "ai ang. = " .. aA .. "\n\n" ..
            "hyperspeed = " .. tostring(hyperspeed) .. "\n" ..
            "showBallDirection = " .. tostring(drawBallDirection) .. "\n" ..
             "inMiddle = " .. tostring(inMiddle) .. "\n",
            300, 20)
            -- Lines
            love.graphics.line(player.x+player.w/2, player.y+player.h/2, ball.x+ball.r/2, ball.y+ball.r/2)
            love.graphics.line(ai.x+ai.w/2, ai.y+ai.h/2, ball.x+ball.r/2, ball.y+ball.r/2)

            if inMiddle == true then
                love.graphics.setColor(51,255,51,100)
            else
                love.graphics.setColor(255,255,255,100)
            end
            love.graphics.rectangle("fill",ai.x, ai.y+(ai.h/3/2), -(screen.W/2), ai.h-(ai.h/3))
        end
    end) -- Of shader


    local status
    if clients.ReturnToPiSPMenu then
        imgui.SetNextWindowPos(10, 10)
        --imgui.SetNextWindowSize(screen.W/2, screen.H/4)
        imgui.Begin("Return to PiSP", false, {"NoTitleBar", "AlwaysAutoResize"})
            imgui.Text("Return to PiSP OS?")
            if imgui.Button("Yes") then
                Gamestate.switch(PiSPOS)
            end
            imgui.SameLine()
            if imgui.Button("No") then
                clients.ReturnToPiSPMenu = false
            end
        imgui.End()
    end
    imgui.Render()
end

function pong:leave()
    music:stop()
end

--[[ ===== Game functions =============================================================== ]] --

function squashBall()
    Timer.script(function(wait)
        local maxvel = math.abs(ball.yvel)
        if maxvel > 10 then maxvel = 10 end
        flux.to(ball, 0.5, { r = 10+maxvel }):ease("elasticout")
        wait(0.1)
        flux.to(ball, 0.6, { r = 10 }):ease("sinein")
    end)
end

function drawConfetti()
    if ball.direction == -1 then
        love.graphics.draw(makeConfetti, player.x+player.w/2, player.y+player.h/2)
    elseif ball.direction == 1 then
        love.graphics.draw(makeConfetti, ai.x+ai.w/2, ai.y+ai.h/2)
    end
end

function speedTrail()
    if ball.yvel > 550 or ball.yvel < -550 then
        hyperspeed = true
    else hyperspeed = false
    end
end

function shakeCam()
    local orig_x, orig_y = camera:position()
    Timer.during(0.2, function()
        camera:lookAt(orig_x + math.random(-10,10), orig_y + math.random(-10,10))
    end, function()
        -- reset camera position to screen.W/H incase of double hit offset
        camera:lookAt(screen.W/2, screen.H/2)
    end)
end

function pushBack(paddle) -- lazy code
    local flux_d = 10 -- distance to push back
    if paddle == player then
        local oldx = player.x
        Timer.script(function(wait)
            flux.to(player, 0.1, { x = oldx-flux_d }):ease("backout")
            wait(0.1)
            flux.to(player, 0.4, { x = oldx }):ease("backin")
        end)
    elseif paddle == ai then
        local oldax = ai.x
        Timer.script(function(wait)
            flux.to(ai, 0.1, { x = oldax+flux_d }):ease("backout")
            wait(0.1)
            flux.to(ai, 0.4, { x = oldax }):ease("backin")
        end)
    end
end

function playSound(sound)
    local blip1 = love.audio.newSource("games/audio/blip.wav", "static")
    local blip2 = love.audio.newSource("games/audio/blip2.wav", "static")
    local winSound = love.audio.newSource("games/audio/win.wav", "static")
    local loseSound = love.audio.newSource("games/audio/lose.wav", "static")
    local hyperSpeed = love.audio.newSource("games/audio/hyperspeed.wav", "static")
    blip1:setVolume(0.2)
    blip2:setVolume(0.2)
    winSound:setVolume(0.1)
    loseSound:setVolume(0.4)
    hyperSpeed:setVolume(0.1)
    local num = math.random(2)
    if sound == "hit" then
        if num == 1 then
            blip1:play()
        elseif num == 2 then
            blip2:play()
        end
    elseif sound == "win" then
            winSound:play()
    elseif sound == "lose" then
            loseSound:play()
    elseif sound == "hyperspeed" then
            hyperSpeed:play()
    end
end

function newRound()
    Timer.script(function(wait)
        ball.x = screen.W/2-ball.r/2
        ball.y = screen.H/2
        ball.yvel = 0
        ball.xvel = 0
        ball.speed = 0
        flux.to(player, 0.5, { y = screen.H/2-player.h/2 })
        flux.to(ai, 0.5, { y = screen.H/2-ai.h/2 })
        drawBallDirection = true
            wait(1)
        ball.speed = ball.origspeed + ball.accelerator
        drawBallDirection = false
        world:remove(ai)
        world:add(ai, ai.x, ai.y, ai.w, ai.h)
    end)
end

function endGame()
    showWinner = true
    Timer.after(5, function() restart() end)
end

function restart()
    Timer.script(function(wait)
    showWinner = false
    score.player = 0
    score.ai = 0
    ai.speed = ai.origspeed
    ball.speed = ball.origspeed
    ball.accelerator = 0
    ai.h = player.h
    world:remove(ai)
    world:add(ai, ai.x, ai.y, ai.w, ai.h)
    end)
end

function showBallDirection()
    local arrow = love.graphics.newImage("images/arrow.png")
    local arrowW = arrow:getWidth()
    local arrowH = arrow:getHeight()
    if ball.direction == 1 then
        love.graphics.draw(arrow, screen.W/2-50, screen.H/2+10, 0, 0.1, 0.1, arrowW/2, arrowH/2)
    elseif ball.direction == -1 then
        love.graphics.draw(arrow, screen.W/2+50, screen.H/2+10, math.rad(180), 0.1, 0.1, arrowW/2, arrowH/2)
    end
end

function increaseDifficulty()
    if drawBallDirection == true then -- really can't be bothered to make a new variable
        if score.player >= 2 then
            ai.speed = ai.speed + 2
            ball.accelerator = ball.accelerator + 10
            ai.h = ai.h + 10
        elseif score.player >= 4 then
            ai.speed = ai.speed + 2
            ball.accelerator = ball.accelerator + 10
            ai.h = ai.h + 10
        elseif score.player >= 6 then
            ai.speed = ai.speed + 2
            ball.accelerator = ball.accelerator + 10
            ai.h = ai.h + 10
        elseif score.player >= 8 then
            ai.speed = ai.speed + 2
            ball.accelerator = ball.accelerator + 10
            ai.h = ai.h + 10
        end
    end
end

--[[
function love.keyreleased(k)
    if k == '`' then -- Toggle console
        if console.displayed == true then console.displayed = false
        elseif console.displayed == false then console.displayed = true
        end
    end
    if k == 'escape' then os.exit() end
    if k == ' ' then restart() end
    --if k == 'p' then love.timer.sleep( 5 ) end
end
]]

--[[ old ai
    if ai.CanMove == true then
        if ball.y > aicenterY then
            ai.yvel = ai.yvel + ai.speed * dt -- (k)onstant in place of dt
        elseif ball.y < aicenterY then
            ai.yvel = ai.yvel - ai.speed * dt
        elseif ball.y == ai.y then
            ai.yvel = 0
        end
    elseif ai.CanMove == false then
        ai.yvel = 0
    end
]]-- Forgive my spaghetti-ness...