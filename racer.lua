local camera = require("camera")
local key = require("key")
local Object = require("object")
local stage = require("stage")
local Vector = require("vector")

local Racer = {}
setmetatable(Racer, {__index=Object})

function vector_from_angle(angle)
   --note: angle here is in R * pi format
   local x = math.cos(angle * math.pi)
   local y = math.sin(angle * math.pi)
   return Vector.new(x, y)
end

function Racer:load(options)
   Object.load(self)

   self:set_sprite("bad-racer", true)

   self.position.x = 0
   self.position.y = 0

   self.rotational_damping = 0.2

   self.seed_spread = 15
   self.seed_rate = 1

   self.drag = 0
   self.max_drag = 80
   self.boost_timer = 0

   self.previous_state = nil

   self.normal_speed = 5.0
   self.boost_speed = 3.0
   self.plant_drag = 0.75 -- percent, applied to current speed.

   self.slide_vector = 0.25
   self.normal_turn_rate = 0.006
   self.slide_turn_rate = 0.009

   self.spray_direction = 1.0
   self.spray_offset = 5.0

   self.lap = 1
   self.checkpoint = 1

   options = options or {}
   for k,v in pairs(options) do
      self[k] = v
   end
end

function Racer:update()
   Object.update(self)

   local speed = self.normal_speed
   if self.boost_timer > 0 then
      -- give about a 25% falloff toward the end of the boost
      boost_speed = math.min(self.boost_speed, (self.boost_speed * self.boost_timer * 4 / self.max_drag))
      speed = speed + boost_speed
      self.seed_spread = 5
   else
      self.seed_spread = 15
   end
   local flower_here, growth_state, flower_type = stage:flower_at(self.position.x, self.position.y)
   if flower_here then
      if growth_state > 0 then
         speed = speed * self.plant_drag
      end
   end

   local thrust = vector_from_angle(self.rotation)
   if key.state == "slide-left" then
      thrust = vector_from_angle(self.rotation + self.slide_vector)
      self.spray_direction = 1.0 - 0.5
      self.spray_offset = 50.0
      self.drag = self.drag + 1
   elseif key.state == "slide-right" then
      thrust = vector_from_angle(self.rotation - self.slide_vector)
      self.spray_direction = -1.0 + 0.5
      self.spray_offset = 50.0
      self.drag = self.drag + 1
   else
      if self.drag > 0 then
         self.boost_timer = self.drag
      end
      self.drag = 0
      self.spray_direction = 1.0
      self.spray_offset = 5.0
   end
   if self.drag > self.max_drag then
      self.drag = self.max_drag
   end

   -- Account for drag
   speed = math.max(speed - self.drag * (self.normal_speed / self.max_drag), 0)
   self.velocity = thrust * speed

   if key.state == "left" then
      self.rotational_velocity = self.normal_turn_rate * -1
   end
   if key.state == "right" then
      self.rotational_velocity = self.normal_turn_rate
   end
   if key.state == "slide-left" then
      self.rotational_velocity = self.slide_turn_rate * -1
   end
   if key.state == "slide-right" then
      self.rotational_velocity = self.slide_turn_rate
   end

   for i = 1, self.seed_rate do
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_throw = vector_from_angle(self.rotation + self.spray_direction)
      seed_x = seed_x + self.spray_offset * seed_throw.x
      seed_y = seed_y + self.spray_offset * seed_throw.y
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 1, math.random(1,2))
   end

   camera.position = racer.position + vector_from_angle(racer.rotation) * 250.0
   camera.rotation = racer.rotation + 0.5
   self.boost_timer = math.max(self.boost_timer - 1, 0)

   -- deal with checkpoints and lap counters
   local pixel_properties = stage:properties_at(self.position.x, self.position.y)
   if pixel_properties.checkpoint then
      if pixel_properties.checkpoint > self.checkpoint and pixel_properties.checkpoint <= self.checkpoint + 2 then
         self.checkpoint = pixel_properties.checkpoint
      end
   end
   if pixel_properties.finish_line and self.checkpoint >= stage.num_checkpoints then
      self.lap = self.lap + 1
      self.checkpoint = 1
   end
end

function Racer:draw()
   Object.draw(self)
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
