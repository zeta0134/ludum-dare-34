local stage = {}

local seed_scale = 8

function stage:load(background_filename)
   self.image = love.graphics.newImage(background_filename)
   -- create a seed map based on this image
   self.growth_map = love.graphics.newCanvas(256, 256, "rgba8")
   self.seed_map = love.graphics.newCanvas(256, 256, "rgba8")

   self.flower_sprite = sprites.new("bad-flowers")
   self.flower_batch = love.graphics.newSpriteBatch(self.flower_sprite.sheet.image, 256*256, "stream")
end

function stage:plant_seed(x, y, r, g, b, growth_rate)
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return -- seed cannot be planted outside the map
   end
   x = math.floor(x / seed_scale)
   y = math.floor(y / seed_scale)
   local r, g, b = self.seed_map:getPixel(x, y)
   if r + g + b > 0 then
      return -- can't plant a seed here
   end
   love.graphics.setCanvas(self.seed_map)
   love.graphics.setColor(1, 1, 1)
   love.graphics.setPointStyle("rough")
   love.graphics.point(x, y)
   --reset the color, because I'm sure I'll forget to do this
   love.graphics.setColor(255, 255, 255)
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

function stage:update_flowers()
   local image_data = self.growth_map:getImageData()

   -- This is bad, but I don't mind so much
   self.flower_batch:clear()
   for x = 0, math.floor(self.image:getWidth() / seed_scale) do
      for y = 0, math.floor(self.image:getHeight() / seed_scale) do
         local r,g,b = image_data:getPixel(x, y)
         local average = (r + g + b) / 3
         --local average = 1
         if average > 0 then
            local growth_stage = math.floor(average / 64)
            self.flower_sprite:set_frame(0, growth_stage)
            math.randomseed(y * self.image:getWidth() + x)
            local x_offset = math.random(-4, 4)
            local y_offset = math.random(-4, 4)
            self.flower_batch:add(self.flower_sprite.quad, x * seed_scale + x_offset, y * seed_scale + y_offset)
         end
      end
   end
end

function stage:update()
   self:grow_seeds()
   self:update_flowers()
end

function stage:draw()
   love.graphics.draw(self.image)
   local old_blend_mode = love.graphics.getBlendMode()
   if false then
      love.graphics.setBlendMode("additive")
      love.graphics.setColor(255, 255, 255)
      love.graphics.push()
      love.graphics.scale(seed_scale)
      love.graphics.draw(self.growth_map)
      love.graphics.pop()
      love.graphics.setBlendMode(old_blend_mode)
   end
   love.graphics.draw(self.flower_batch)
end

return stage
