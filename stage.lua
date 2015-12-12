local stage = {}

function stage:load(background_filename)
   self.image = love.graphics.newImage(background_filename)
end

function stage:draw()
   love.graphics.draw(self.image)
end

return stage
