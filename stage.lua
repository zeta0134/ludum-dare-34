local stage = {}
local camera = require("camera")
local sprites = require("sprites")

local seed_scale = 8

function stage:generate_noise_table()
   self.noise_table = {}
   for x = 0, 1023 do
      self.noise_table[x] = {}
      for y = 0, 1023 do
         local x_offset = math.random(-4, 4)
         local y_offset = math.random(-4, 4)
         self.noise_table[x][y] = {x=x_offset,y=y_offset}
      end
   end
end

function stage:load(background_filename, control_filename)
   self.image = love.graphics.newImage(background_filename)

   self.flower_sprite = sprites.new("brush")
   self.flower_batch = love.graphics.newSpriteBatch(self.flower_sprite.sheet.image, 1024*1024)
   self.flower_sprite.sheet.image:setFilter("nearest", "nearest")
   self:generate_noise_table()

   --attempt to load a control layer
   self.control_map = love.image.newImageData(control_filename)
   self.num_checkpoints = 18

   --create a seed map
   self.seed_map = {}
   self.active_seeds = {}
end

function stage:properties_at(x, y)
   x = math.floor(x)
   y = math.floor(y)
   local properties = {}
   if x < 0 or x >= self.control_map:getWidth() or y < 0 or y >= self.control_map:getHeight() then
      return {} -- outside the bounds of the map
   end
   local r, g, b = stage.control_map:getPixel(x, y)
   if r > 0 then
      properties.checkpoint = math.floor(r / 10)
   end
   properties.plantable = true
   if b > 0 then
      properties.plantable = false
      if b == 255 then
         properties.finish_line = true
      end
      properties.offroad = false
      if b == 10 then
         properties.offroad = true
      end
   end
   return properties
end

function stage:seed_planted_at(x, y)
   local x = math.floor(x / seed_scale)
   local y = math.floor(y / seed_scale)
   if self.seed_map[x] then
      if self.seed_map[x][y] then
         return true
      end
   end
   return false
end

function stage:plant_seed(x, y, growth_rate, flower_type)
   if x < 0 or x >= self.image:getWidth() or y < 0 or y >= self.image:getHeight() then
      return -- outside the bounds of the map
   end
   local x = math.floor(x / seed_scale)
   local y = math.floor(y / seed_scale)
   local pixel_properties = self:properties_at(x * seed_scale, y * seed_scale)
   if not pixel_properties.plantable then
      return -- map does not support planting seeds at this location
   end
   if not self.seed_map[x] then
      self.seed_map[x] = {}
   end
   if self.seed_map[x][y] then
      return --already a seed here!
   end
   local seed = {}
   seed.growth_rate = 64
   seed.flower_type = flower_type
   seed.age = 0
   seed.growth_stage = 0
   -- Add this new seed to the spritebatch, and set a reference to the new
   -- sprite into it for future modification during its growth stages
   self.flower_sprite:set_frame(seed.flower_type - 1, seed.growth_stage)
   seed.x_pos = x * seed_scale + self.noise_table[x][y].x
   seed.y_pos = y * seed_scale + self.noise_table[x][y].y
   seed.sprite_id = self.flower_batch:add(self.flower_sprite.quad, seed.x_pos, seed.y_pos, nil, 2, 2, 4, 4)
   self.seed_map[x][y] = seed
   table.insert(self.active_seeds, self.seed_map[x][y])
end

function stage:grow_seeds()
   local i = 1

   -- age, grow, and discard finished seeds
   while i < #self.active_seeds do
      local current_seed = self.active_seeds[i]
      current_seed.age = current_seed.age + 1
      if current_seed.age > (current_seed.growth_stage + 1) * current_seed.growth_rate then
         current_seed.growth_stage = current_seed.growth_stage + 1
         self.flower_sprite:set_frame(current_seed.flower_type - 1, current_seed.growth_stage)
         self.flower_batch:set(current_seed.sprite_id, self.flower_sprite.quad, current_seed.x_pos, current_seed.y_pos, nil, 2, 2, 4, 4)
      end
      -- if we are done updating this sprite forever, rejoice! remove it from the list
      if current_seed.growth_stage >= 3 then
         table.remove(self.active_seeds, i)
      else
         i = i + 1
      end
   end
end

function stage:flower_at(x, y)
   local x = math.floor(x / seed_scale)
   local y = math.floor(y / seed_scale)
   if self.seed_map[x] then
      if self.seed_map[x][y] then
         return true, self.seed_map[x][y].growth_stage, self.seed_map[x][y].flower_type
      end
   end
   return false
end

function stage:update_flowers()
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
            self.flower_batch:add(self.flower_sprite.quad, x * seed_scale + x_offset, y * seed_scale + y_offset, camera.rotation * math.pi, 4, 4, 4, 4)
         end
      end
   end
end

function stage:update()
   self:grow_seeds()
end

function stage:draw()
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.image)
   if true then
      local old_blend_mode = love.graphics.getBlendMode()
      love.graphics.setBlendMode("additive")
      love.graphics.setColor(255, 255, 255)
      love.graphics.push()
      love.graphics.scale(seed_scale)
      --self.growth_map:setFilter("nearest", "nearest")
      --love.graphics.draw(self.growth_map)
      love.graphics.pop()
      love.graphics.setBlendMode(old_blend_mode)
   end
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.flower_batch)
end

return stage
