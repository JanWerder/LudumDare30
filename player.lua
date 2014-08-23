Player = {}
Player.__index = Player

function Player.create(x, y)
    local playerMan = {}
    setmetatable(playerMan, Player)
    playerMan.img  = love.graphics.newImage("images/spaceship.png")


    frame1 = love.graphics.newQuad(0, 0, 50, 50, playerMan.img:getDimensions())
    frame2 = love.graphics.newQuad(50, 0, 50, 50, playerMan.img:getDimensions())
    frame3 = love.graphics.newQuad(100, 0, 50, 50, playerMan.img:getDimensions())

    playerMan.frames = {}
    table.insert(playerMan.frames,frame1)
    table.insert(playerMan.frames,frame1)
    table.insert(playerMan.frames,frame1)
    table.insert(playerMan.frames,frame2)
    table.insert(playerMan.frames,frame2)
    table.insert(playerMan.frames,frame2)
    table.insert(playerMan.frames,frame3)
    table.insert(playerMan.frames,frame3)
    table.insert(playerMan.frames,frame3)
    playerMan.currentframe = 1

    playerMan.x = x
    playerMan.y = y
    playerMan.forwardSpeed = 350

    playerMan.score = 0

    playerMan.velocity_x = 0
playerMan.velocity_y = 0
playerMan.thrust = 300
playerMan.rotate_speed = 200
playerMan.angle = 0
playerMan.coolDown = 1

    playerMan.shape = Collider:addRectangle(x,y,30,30)
    playerMan.shape:moveTo(x,y)
    playerMan.shape.class = "Player"

  playerMan.isAlive = true
    return playerMan
end


function Player:update(dt)
    if self.isAlive then
      if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
          self.angle = self.angle - self.rotate_speed * dt
      end
      if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
          self.angle = self.angle + self.rotate_speed * dt
      end

      if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
          angle_radians = math.rad(self.angle)
          force_x = math.cos(angle_radians) * self.thrust * dt
          force_y = math.sin(angle_radians) * self.thrust * dt
          self.velocity_x = self.velocity_x + force_x
          self.velocity_y = self.velocity_y + force_y
      end
    end

    self.x = self.x + self.velocity_x * dt
    self.y = self.y + self.velocity_y * dt

       self.shape:moveTo(self.x,self.y)

    if self.coolDown > 0 then
      self.coolDown = self.coolDown - dt
    end
    if love.keyboard.isDown(" ") and self.coolDown <= 0 then
      local bullet = Bullet.create(self.x,self.y,self.angle,self.velocity_x,self.velocity_y)
      table.insert(entities,bullet)
      self.coolDown = 1
    end
end

function Player:draw()
  --self.shape:draw('fill')
  love.graphics.draw(self.img, self.frames[self.currentframe],self.x,self.y,math.rad(self.angle+90),1,1,25,25)
  if self.currentframe+1 <= #self.frames then
    self.currentframe =  self.currentframe + 1
  else
    self.currentframe = 1
  end
end
