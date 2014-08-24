Asteroid = {}
Asteroid.__index = Asteroid
asteroidTypes = {0,0,0}
asteroidImages = {love.graphics.newImage("images/american_asteroid.png"),love.graphics.newImage("images/germany_asteroid.png"),love.graphics.newImage("images/russian_asteroid.png")}

function Asteroid.create(x, y, angle)
    local asteroidMan = {}
    setmetatable(asteroidMan, Asteroid)

    local min = math.min(unpack(asteroidTypes))

    for i=1,#asteroidTypes do
      if asteroidTypes[i] == min then
        min = i
        asteroidTypes[i] = asteroidTypes[i] + 1
      end
    end



    asteroidMan.x = x
    asteroidMan.y = y
    asteroidMan.forwardSpeed = 350
    asteroidMan.angle = 0
    asteroidMan.speed = math.random(25,100)
    asteroidMan.scale = 1

    local radAngle = math.rad(math.random(0,90))
    asteroidMan.x = x + math.cos(radAngle) * 25
    asteroidMan.y = y + math.sin(radAngle) * 25


    asteroidMan.shape = Collider:addCircle(x,y, 40)
    asteroidMan.shape.class = "Asteroid"

    asteroidMan.shape.type = min
    asteroidMan.img  = asteroidImages[min]

    for i=1,numScaled[min] do
      asteroidMan.shape:scale(1.1)
    end


    asteroidMan.shape.velocity_x = math.cos(radAngle) * math.random(-1,1) * 80
    asteroidMan.shape.velocity_y = math.sin(radAngle) * math.random(-1,1) * 80
    return asteroidMan
end


function Asteroid:update(dt)
  self.angle = self.angle + self.speed * dt
  self.x = self.x + self.shape.velocity_x * dt
  self.y = self.y + self.shape.velocity_y * dt


  self.shape:moveTo(self.x,self.y)

end

function Asteroid:draw()
  --self.shape:draw('fill')
  love.graphics.draw(self.img, self.x,self.y,math.rad(self.angle),asteroidScale[self.shape.type],asteroidScale[self.shape.type],self.img:getWidth()/2,self.img:getHeight()/2 )
end
