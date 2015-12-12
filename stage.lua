local stage = {}

function stage:load(background_filename)
   self.image = love.graphics.newImage(background_filename)
   -- create a seed map based on this image
   self.growth_map = love.graphics.newCanvas(1024, 1024, "rgba8")
   self.seed_map = love.graphics.newCanvas(1024, 1024, "rgba8")
end

function stage:plant_seed(x, y, r, g, b, growth_rate)
   print("Called plant seed")
   if x < 0 or x >= self.seed_map:getHeight() or y < 0 or y >= self.seed_map:getWidth() then
      return -- seed cannot be planted outside the map
   end
   local r, g, b = self.seed_map:getPixel(x, y)
   print("Current pixel: ", r, g, b)
   if r + g + b > 0 then
      return -- can't plant a seed here
   end
   love.graphics.setCanvas(self.seed_map)
   love.graphics.setColor(1, 1, 1)
   love.graphics.setPointStyle("rough")
   love.graphics.point(x, y)
   --reset the color, because I'm sure I'll forget to do this
   love.graphics.setColor(255, 255, 255)
   print("Seed SET")
end

function stage:grow_seeds()
   love.graphics.setCanvas(self.growth_map)
   local old_blend_mode = love.graphics.getBlendMode()
   love.graphics.setBlendMode("additive")
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.seed_map)
   love.graphics.setBlendMode(old_blend_mode)
   love.graphics.setCanvas()
end

function stage:update()
   self:grow_seeds()
end

function stage:draw()
   love.graphics.draw(self.image)
   local old_blend_mode = love.graphics.getBlendMode()
   love.graphics.setBlendMode("additive")
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.growth_map)
   love.graphics.setBlendMode(old_blend_mode)
end

return stage
