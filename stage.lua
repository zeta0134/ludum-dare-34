local stage = {}
local camera = require("camera")
local sounds = require("sounds")
local sprites = require("sprites")

--Size of the seed grid, in map pixels
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

stage.race_stages = {
   {name="prefade", duration=20},
   {name="fadein", duration=30},
   {name="warmup", duration=30},
   {name="3", duration=60, sound="3"},
   {name="2", duration=60, sound="2"},
   {name="1", duration=60, sound="1"},
   {name="GO", active=true, duration=10, sound="go"},
   {name="results", duration=60*5, sound="time"},
   {name="postfade", duration=30},
   {name="returntotitle", exit=true}
}

function stage:load(level_properties)
   self.properties = level_properties
   self.image = love.graphics.newImage("levels/".. level_properties.image_name ..".png")
   self.image_data = love.image.newImageData("levels/".. level_properties.image_name ..".png")

   self.flower_sprite = sprites.new("brush")
   self.flower_batch = love.graphics.newSpriteBatch(self.flower_sprite.sheet.image, 1024*1024)
   self.flower_sprite.sheet.image:setFilter("nearest", "nearest")
   self:generate_noise_table()

   --attempt to load a control layer
   self.control_map = love.image.newImageData("levels/".. level_properties.image_name ..".control.png")
   self.num_checkpoints = level_properties.checkpoints

   -- debug
   self.debug_control_map = love.graphics.newImage(self.control_map)

   -- reset camera
   camera:set(self.properties.starting_position.x, self.properties.starting_position.y, self.properties.starting_rotation)

   -- minimap!
   self.minimap_image = love.graphics.newImage("levels/" .. level_properties.image_name .. ".minimap.png")

   --create a seed map
   self.seed_map = {}
   self.active_seeds = {}

   self.seed_sound_delay = 0

   -- relocate the player (later: players?) to the start of the level
   player.position.x = level_properties.starting_position.x
   player.position.y = level_properties.starting_position.y
   player.rotation = level_properties.starting_rotation

   -- reset the player's lap timers
   player.race_timer = 0
   player.lap_timer = 0
   player.lap_times = {}

   -- setup the start of race timing
   self.race_stage = 1
   self.race_active = false
   self.stage_timer = 0

   if level_properties.clear_color then
      love.graphics.setBackgroundColor(level_properties.clear_color.r, level_properties.clear_color.g, level_properties.clear_color.b)
   end
end

function stage:properties_at(x, y)
   x = math.floor(x)
   y = math.floor(y)
   local properties = {}
   if x < 0 or x >= self.control_map:getWidth() or y < 0 or y >= self.control_map:getHeight() then
      return {out_of_bounds=true} -- outside the bounds of the map
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
      if b == 20 then
         properties.zipper = true
      end
      if b == 30 then
         properties.lava = true
      end
      if b == 40 then
         properties.water = true
      end
      if b == 50 then
         properties.out_of_bounds = true
      end
      --print(b)
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

function stage:plant_seed(x, y, flower_type)
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
   seed.flower_type = flower_type
   seed.age = 0
   seed.growth_stage = 0
   seed.growth_period = self.properties.growth_period + math.random(-10,10)
   seed.brightness = 255 - math.random(0,50)
   -- Add this new seed to the spritebatch, and set a reference to the new
   -- sprite into it for future modification during its growth stages
   self.flower_sprite:set_frame(seed.flower_type - 1, seed.growth_stage)
   seed.x_pos = x * seed_scale + self.noise_table[x][y].x
   seed.y_pos = y * seed_scale + self.noise_table[x][y].y
   self.flower_batch:setColor(seed.brightness, seed.brightness, seed.brightness)
   seed.sprite_id = self.flower_batch:add(self.flower_sprite.quad, seed.x_pos, seed.y_pos, nil, 2, 2, 4, 4)
   self.seed_map[x][y] = seed
   table.insert(self.active_seeds, self.seed_map[x][y])

   if self.seed_sound_delay == 0 then
      -- sounds.play "seeds-popping"
      self.seed_sound_delay = 30
   end
end

function stage:grow_seeds()
   local i = 1

   -- age, grow, and discard finished seeds
   while i < #self.active_seeds do
      local current_seed = self.active_seeds[i]
      current_seed.age = current_seed.age + 1
      if current_seed.age > (current_seed.growth_stage + 1) * current_seed.growth_period then
         current_seed.growth_stage = current_seed.growth_stage + 1
         self.flower_sprite:set_frame(current_seed.flower_type - 1, current_seed.growth_stage)
         self.flower_batch:setColor(current_seed.brightness, current_seed.brightness, current_seed.brightness)
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
   if self.race_active then
      self:grow_seeds()
      if self.seed_sound_delay > 0 then
         self.seed_sound_delay = self.seed_sound_delay - 1
      end
      self.stage_timer = self.stage_timer + 1
   else
      if stage.race_stages[self.race_stage].exit then
         game_state = "title"
      end
      if stage.race_stages[self.race_stage].duration then
         -- this is an auto-advancing race stage; handle its timer and promote
         -- if necessary
         if self.stage_timer >= stage.race_stages[self.race_stage].duration then
            self.race_stage = self.race_stage + 1
            self.stage_timer = 0
            if stage.race_stages[self.race_stage].active then
               self.race_active = true
            end
            if stage.race_stages[self.race_stage].sound then
               sounds.play(stage.race_stages[self.race_stage].sound)
            end
         else
            self.stage_timer = self.stage_timer + 1
         end
      end
   end
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
   -- debug!
   -- love.graphics.setColor(255, 255, 255, 128)
   -- love.graphics.draw(self.debug_control_map)

   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(self.flower_batch)
end

return stage
