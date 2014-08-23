Objective = {}
Objective.__index = Objective

function Objective.create(x, y)
    local objectiveMan = {}
    setmetatable(objectiveMan, Objective)
    objectiveMan.img  = love.graphics.newImage("images/objective.png")


    frame1 = love.graphics.newQuad(0, 0, 50, 50, objectiveMan.img:getDimensions())
    frame2 = love.graphics.newQuad(50, 0, 50, 50, objectiveMan.img:getDimensions())
    frame3 = love.graphics.newQuad(100, 0, 50, 50, objectiveMan.img:getDimensions())

    objectiveMan.frames = {}
    table.insert(objectiveMan.frames,frame1)
    table.insert(objectiveMan.frames,frame1)
    table.insert(objectiveMan.frames,frame1)
    table.insert(objectiveMan.frames,frame2)
    table.insert(objectiveMan.frames,frame2)
    table.insert(objectiveMan.frames,frame2)
    table.insert(objectiveMan.frames,frame3)
    table.insert(objectiveMan.frames,frame3)
    table.insert(objectiveMan.frames,frame3)
    objectiveMan.currentframe = 1

    objectiveMan.x = x
    objectiveMan.y = y

    objectiveMan.shape = Collider:addRectangle(x-25,y-25,50,50)
    objectiveMan.shape.class = "Objective"

    return objectiveMan
end


function Objective:update(dt)
end

function Objective:draw()
  --self.shape:draw('fill')
  love.graphics.draw(self.img, self.frames[self.currentframe],self.x,self.y,0,1,1,25,25)
  if self.currentframe+1 <= #self.frames then
    self.currentframe =  self.currentframe + 1
  else
    self.currentframe = 1
  end
end
