local stage = {}
local camera = require("camera")
local sprites = require("sprites")

local seed_scale = 8

function stage:load(background_filename)
   self.image = love.graphics.newImage(background_filename)
   -- create a seed map based on this image
   self.growth_map = love.graphics.newCanvas(256, 256, "rgba8")
   self.seed_map = love.graphics.newCanvas(256, 256, "rgba8")

   self.flower_sprite = sprites.new("bad-flowers")
   self.flower_batch = love.graphics.newSpriteBatch(self.flower_sprite.sheet.image, 256*256, "stream")
end

function stage:seed_planted_at(x, y)
   local r, g, b = self.seed_map:getPixel(x, y)
   if r + g + b > 0 then
      return true
   end
   return false
end

function stage:plant_seed(x, y, growth_rate, flower_type)
   flower_type = flower_type or 2
   growth_rate = growth_rate or 1
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return -- seed cannot be planted outside the map
   end
   local x = math.floor(x / seed_scale)
   local y = math.floor(y / seed_scale)
   if self:seed_planted_at(x, y) then
      return
   end
   love.graphics.setCanvas(self.seed_map)
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

   love.graphics.setColor(r, g, b)
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

function stage:update_flowers()
   local image_data = self.growth_map:getImageData()

   -- This is bad, but I don't mind so much
   self.flower_batch:clear()
   for x = 0, math.floor(self.image:getWidth() / seed_scale) do
      for y = 0, math.floor(self.image:getHeight() / seed_scale) do
         local r,g,b = image_data:getPixel(x, y)
         if r + g + b > 0 then
            local growth_stage, flower_type = flower_properties(r, g, b)
            self.flower_sprite:set_frame(flower_type - 1, growth_stage)
            math.randomseed(y * self.image:getWidth() + x)
            local x_offset = math.random(-4, 4)
            local y_offset = math.random(-4, 4)
            self.flower_batch:add(self.flower_sprite.quad, x * seed_scale + x_offset, y * seed_scale + y_offset, camera.rotation * math.pi, 2, 2)
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
   if true then
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
