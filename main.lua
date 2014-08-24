HC = require 'libs/HardonCollider'
Camera = require "libs/camera"
lovebird = require("libs/lovebird")
require 'player'
require 'asteroid'
require 'bullet'
require 'objective'
require 'shaders/init'

love.filesystem.enumerate = love.filesystem.enumerate or love.filesystem.getDirectoryItems

function love.load()

  if not love.filesystem.exists( "highscore.txt" ) then
    love.filesystem.write( "highscore.txt", "0")
  end

  music = love.audio.newSource("music/song01.mp3")
  music:setVolume(0.8)
  music:play()

  love.graphics.setFont(love.graphics.newFont("fonts/PTM55FT.ttf",20))
  love.filesystem.setIdentity("Asteroid Rage")
  shaderlist = love.filesystem.enumerate( "shaders/" )

  local rem
	for i, v in pairs(shaderlist) do
		if v == "init.lua" then
			rem = i
		else
			shaderlist[i] = string.sub(v, 1, string.len(v)-5)
		end
	end
	table.remove(shaderlist, rem)
	table.insert(shaderlist, 1, "none")
	require "shaders"
  require "sha1"
	shaders:init()
  if love.math then love.math.setRandomSeed(os.time()) end
    Collider = HC(100, onCollision)

    numScaled = {0,0,0}
    asteroidScale = {1,1,1}

    entities = {}
    player = Player.create(200, 200)
    cam = Camera(player.x, player.y)
    table.insert(entities,player)

    objective = Objective.create(math.random(-1000,1000),math.random(-1000,1000))
    table.insert(entities,objective)
    for i = 1,100 do
      table.insert(entities,Asteroid.create(math.random(-2000,2000),math.random(-2000,2000),270))
    end

    spawnCount = 1
    shaders:set(2, shaderlist[2])
    shaders:refresh()
end

function love.update(dt)

  spawnCount = spawnCount - dt
  if spawnCount <= 0 then
  table.insert(entities,Asteroid.create(entities[1].x+400,entities[1].y+400,180))
  table.insert(entities,Asteroid.create(entities[1].x-400,entities[1].y-400,180))
  table.insert(entities,Asteroid.create(entities[1].x+400,entities[1].y-400,0))
  table.insert(entities,Asteroid.create(entities[1].x-400,entities[1].y+400,0))
  spawnCount = 2
  end

  Collider:update(dt)
  local dx,dy = entities[1].x - cam.x, entities[1].y - cam.y
  cam:move(dx/2, dy/2)
  lovebird.update()
    for i=1,table.getn(entities) do
      entities[i]:update(dt)
      entities[i].shape.no = i
      if entities[i].class == "Asteroid" then
        if entities[i].x < -2000 or entities[i].x > 2000 or entities[i].y < -2000 or entities[i].y > 2000 then
          Collider:remove(entities[i].shape)
          table.remove(entities, entities[i].shape.no)
        end
      end
    end

  if not entities[1].isAlive then
    if not love.filesystem.exists( "highscore.txt" ) then
      love.filesystem.write( "highscore.txt", entities[1].score)
    else
      highscore = love.filesystem.read("highscore.txt")
      if tonumber(highscore) < entities[1].score then
        love.filesystem.write( "highscore.txt", entities[1].score)
        highscore = entities[1].score
      end
    end
    if love.keyboard.isDown(" ") then
    music:stop()
    love.load()
    end
  end
end


function love.draw()
    shaders:predraw()
    cam:attach()

    love.graphics.draw(love.graphics.newImage("images/bg.png"),math.floor(entities[1].x-500),math.floor(entities[1].y-500))
    for i=1,table.getn(entities) do
      entities[i]:draw()
    end
    cam:detach()

    love.graphics.draw(love.graphics.newImage("images/hudtop.png"),0,10)
    love.graphics.draw(love.graphics.newImage("images/hud.png"),800/2-32,600-64)
    love.graphics.draw(love.graphics.newImage("images/arrow.png"),800/2,600-30,math.atan2(objective.y-entities[1].y, objective.x-entities[1].x)+90,1,1,22.5,22.5)
    love.graphics.print("Rescues: " .. entities[1].score,7,22)
    if not entities[1].isAlive then
      if not highscore then
        highscore = 0
      end
      love.graphics.print("Highscore: " .. highscore,620,22)
    end

    if not entities[1].isAlive then
      love.graphics.draw(love.graphics.newImage("images/gameover.png"),150,100)
    end
    shaders:postdraw()
end

function onCollision(dt, shapeA, shapeB, mtvX, mtvY)
  if (shapeA.class == "Player" and shapeB.class == "Asteroid") or (shapeA.class == "Asteroid" and shapeB.class == "Player") then
    entities[1].isAlive =  false
  end

  if (shapeA.class == "Player" and shapeB.class == "Objective") then
    entities[1].score = entities[1].score + 1
    table.remove(entities,shapeB.no)
    Collider:remove(shapeB)
    objective = Objective.create(math.random(-1000,1000),math.random(-1000,1000))
    table.insert(entities,objective)
  end
  if (shapeA.class == "Objective" and shapeB.class == "Player") then
    entities[1].score = entities[1].score + 1
    table.remove(entities,shapeA.no)
    Collider:remove(shapeA)
    objective = Objective.create(math.random(-1000,1000),math.random(-1000,1000))
    table.insert(entities,objective)
  end


  if (shapeA.class == "Asteroid" and shapeB.class == "Asteroid") or (shapeA.class == "Asteroid" and shapeB.class == "Asteroid") then
    shapeA.velocity_x = shapeA.velocity_x * -1
    --shapeB.velocity_x = shapeB.velocity_x * -1
    --shapeA.velocity_y = shapeA.velocity_y * -1
    shapeB.velocity_y = shapeB.velocity_y * -1
  end

  if (shapeA.class == "Bullet" and shapeB.class == "Asteroid") or (shapeA.class == "Asteroid" and shapeB.class == "Bullet") then
    Collider:remove(shapeA)
    Collider:remove(shapeB)
    if shapeB.class == "Bullet" then
    table.remove(entities,shapeB.no)
    table.remove(entities,shapeA.no)

    asteroidScale[shapeA.type] = asteroidScale[shapeA.type] * 1.1
    numScaled[shapeA.type] = numScaled[shapeA.type] + 1
    for i=1,#entities do
      if entities[i].shape.class == "Asteroid" and entities[i].shape.type == shapeA.type then
        entities[i].shape:scale(1.1)
      end
    end
    elseif shapeA.class == "Bullet" then
    table.remove(entities,shapeA.no)
    table.remove(entities,shapeB.no)

    asteroidScale[shapeB.type] = asteroidScale[shapeB.type] * 1.1
    numScaled[shapeB.type] = numScaled[shapeB.type] + 1
    for i=1,#entities do
      if entities[i].shape.class == "Asteroid" and entities[i].shape.type == shapeB.type then
        entities[i].shape:scale(1.1)
      end
    end
    end

  end
end

function love.keypressed(key)
end

function love.keyreleased(key)
end

function love.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
end

function love.gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
end

function love.gamepadaxis(joystick, axis, newvalue)
end
