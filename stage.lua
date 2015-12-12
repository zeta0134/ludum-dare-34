local stage = {}
local camera = require("camera")
local sprites = require("sprites")

local seed_scale = 8

function stage:generate_noise_table()
   self.noise_table = {}
   for x = 0, 511 do
      self.noise_table[x] = {}
      for y = 0, 511 do
         local x_offset = math.random(-4, 4)
         local y_offset = math.random(-4, 4)
         self.noise_table[x][y] = {x=x_offset,y=y_offset}
      end
   end
end

function stage:load(background_filename)
   self.image = love.graphics.newImage(background_filename)
   -- create a seed map based on this image
   self.growth_map = love.graphics.newCanvas(512, 512, "rgba8")
   self.seed_map = love.image.newImageData(512, 512)
   self.seed_map_image = love.graphics.newImage(self.seed_map)

   self.flower_sprite = sprites.new("bad-flowers")
   self.flower_batch = love.graphics.newSpriteBatch(self.flower_sprite.sheet.image, 256*256, "stream")
   self:generate_noise_table()
end

function stage:seed_planted_at(x, y)
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return nil-- seed cannot be planted outside the map
   end
   local r, g, b = self.seed_map:getPixel(math.floor(x / seed_scale), math.floor(y / seed_scale))
   if r + g + b > 0 then
      return r, g, b
   end
   return nil
end

function stage:plant_seed(x, y, growth_rate, flower_type)
   flower_type = flower_type or 2
   growth_rate = growth_rate or 1
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return -- seed cannot be planted outside the map
   end
   if self:seed_planted_at(x, y) then
      return
   end
   local x = math.floor(x / seed_scale)
   local y = math.floor(y / seed_scale)

   local r = 0
   local g = 0
   local b = 0
   if bit.band(flower_type, 0x4) ~= 0 then
      r = growth_rate
   end
   if bit.band(flower_type, 0x2) ~= 0 then
      g = growth_rate
   end
   if bit.band(flower_type, 0x1) ~= 0 then
      b = growth_rate
   end

   self.seed_map:setPixel(x, y, r, g, b, 255)
end

function stage:grow_seeds()
   love.graphics.setCanvas(self.growth_map)
   local old_blend_mode = love.graphics.getBlendMode()
   love.graphics.setBlendMode("additive")
   love.graphics.setColor(255, 255, 255)
   self.seed_map_image:refresh()
   love.graphics.draw(self.seed_map_image)
   love.graphics.setBlendMode(old_blend_mode)
   love.graphics.setCanvas()
end

function flower_properties(r, g, b)
   --given a flower's raw color data, return the growth stage and type
   local growth_value = math.max(r, g, b)
   local growth_stage = math.floor(growth_value / 64)
   local flower_type = 0
   if r > 0 then
      flower_type = flower_type + 4
   end
   if g > 0 then
      flower_type = flower_type + 2
   end
   if b > 0 then
      flower_type = flower_type + 1
   end
   return growth_stage, flower_type
end

function stage:flower_at(x, y)
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return false-- seed cannot be planted outside the map
   end
   local r, g, b = self.image_data:getPixel(math.floor(x / seed_scale), math.floor(y / seed_scale))
   local growth_stage, flower_type = flower_properties(r, g, b)
   return true, growth_stage, flower_type
end

function stage:update_flowers()
   self.image_data = self.growth_map:getImageData()

   -- This is bad, but I don't mind so much
   self.flower_batch:clear()
   for x = 0, math.floor(self.image:getWidth() / seed_scale) do
      for y = 0, math.floor(self.image:getHeight() / seed_scale) do
         local r,g,b = self.image_data:getPixel(x, y)
         if r + g + b > 0 then
            local growth_stage, flower_type = flower_properties(r, g, b)
            self.flower_sprite:set_frame(flower_type - 1, growth_stage)
            local x_offset = self.noise_table[x][y].x
            local y_offset = self.noise_table[x][y].y
            self.flower_batch:add(self.flower_sprite.quad, x * seed_scale + x_offset, y * seed_scale + y_offset, camera.rotation * math.pi, 2, 2, 4, 4)
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
   if true then
      local old_blend_mode = love.graphics.getBlendMode()
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
