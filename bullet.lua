Bullet = {}
Bullet.__index = Bullet

function Bullet.create(x, y, angle, velX, velY)
    local bulletMan = {}
    setmetatable(bulletMan, Bullet)
    bulletMan.img  = love.graphics.newImage("images/bullet.png")

    local radAngle = math.rad(angle)
    bulletMan.x = x + math.cos(radAngle) * 25
    bulletMan.y = y + math.sin(radAngle) * 25
    bulletMan.angle = angle
    bulletMan.velocity_x = velX + math.cos(radAngle) * 700
    bulletMan.velocity_y = velY + math.sin(radAngle) * 700

    bulletMan.shape = Collider:addRectangle(x,y,3,6)
    bulletMan.shape.class = "Bullet"
    return bulletMan
end


function Bullet:update(dt)
  self.x = self.x + self.velocity_x * dt
  self.y = self.y + self.velocity_y * dt

  self.shape:moveTo(self.x,self.y)
end

function Bullet:draw()
  self.shape:draw('fill')
  love.graphics.draw(self.img, self.x,self.y,math.rad(self.angle),1,1,self.img:getWidth()/2,self.img:getHeight()/2 )
end
