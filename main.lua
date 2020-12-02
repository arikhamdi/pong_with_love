Class = require 'class'
push = require 'push'

require 'Ball'
require 'Paddle'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

FONT = '04B_03__.TTF'


function love.load()
    math.randomseed(os.time())

    love.window.setTitle('Pong')

    love.graphics.setDefaultFilter('nearest', 'nearest')

    smallFont = love.graphics.newFont(FONT, 8)

    scoreFont = love.graphics.newFont(FONT, 32)

    victoryFont = love.graphics.newFont(FONT, 24)

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })    

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['point_scored'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }
    servingPlayer = math.random(2) == 1 and 2 or 1
    winner = 0

    paddle1 = Paddle(5, 10, 5, 20)
    paddle2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    if servingPlayer == 1 then
        ball.dx = 100
    else
        ball.dx = -100
    end

    gameState = 'start'
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == "serve" then
            gameState = 'play'
        elseif gameState == "victory" then
            gameState = 'start'
            paddle1:reset()
            paddle2:reset()
        end
    end
end

function love.update(dt)

    
    paddle1:update(dt)
    paddle2:update(dt)

    if gameState == 'play' then
        ball:update(dt)

        if ball:collides(paddle1) then
            ball.dx = -ball.dx

            sounds['paddle_hit']:play()
        end

        if ball:collides(paddle2) then
            ball.dx = -ball.dx
            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.dy = -ball.dy
            ball.y = 0
            sounds['wall_hit']:play()
        end

        if ball.y + ball.height >= VIRTUAL_HEIGHT then
            ball.dy = -ball.dy
            ball.y = VIRTUAL_HEIGHT - ball.height
            sounds['wall_hit']:play()
        end

        if ball.x  + ball.width < 0 then
            sounds['point_scored']:play()
            paddle2.score = paddle2.score + 1
            servingPlayer = 1
            ball:reset()
            ball.dx = 100
            if paddle2.score >= 10 then
                gameState = 'victory'
                winner = 2
            else
                gameState = 'serve'
            end
        end
                    
        if ball.x  > VIRTUAL_WIDTH then
            sounds['point_scored']:play()
            paddle1.score = paddle1.score + 1
            servingPlayer = 2
            ball:reset()
            ball.dx = -100
            if paddle1.score >= 10 then
                gameState = 'victory'
                winner = 1
            else
                gameState = 'serve'
            end
        end
    end
        
        if love.keyboard.isDown('z') then
            paddle1.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('s') then
            paddle1.dy = PADDLE_SPEED
        else
            paddle1.dy = 0
        end

        if love.keyboard.isDown('up') then
            paddle2.dy = -PADDLE_SPEED
        elseif love.keyboard.isDown('down')then
            paddle2.dy = PADDLE_SPEED
        else
            paddle2.dy = 0
        end
end

function love.draw()
    push:apply('start')
    
    love.graphics.clear(40 / 255, 45 / 255, 52 / 255, 255 / 255)

    ball:render()

    paddle1:render()
    paddle2:render()

    displayScore()

    love.graphics.setFont(smallFont)

    if gameState == "start" then
        love.graphics.printf("welcome to Pong!", 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Play!",0, 35, VIRTUAL_WIDTH, 'center')
    elseif gameState == "serve" then
        love.graphics.printf("Player " .. tostring(servingPlayer), 0, 20, VIRTUAL_WIDTH, 'center')
        love.graphics.printf("Press Enter to Serve!",0, 35, VIRTUAL_WIDTH, 'center')
    elseif gameState == "victory" then
        love.graphics.setFont(victoryFont)
        love.graphics.printf("Player " .. tostring(winner) .. " wins", 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.setFont(smallFont)
        love.graphics.printf("Press Enter to Play!",0, 42, VIRTUAL_WIDTH, 'center')
    end

    displayFPS()

    push:apply('end')
end

function displayFPS()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.setFont(smallFont)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 40,10)
    love.graphics.setColor(1, 1, 1, 1)
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(paddle1.score, VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(paddle2.score, VIRTUAL_WIDTH / 2 + 32, VIRTUAL_HEIGHT / 3)
end
