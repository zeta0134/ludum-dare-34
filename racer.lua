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

function Racer:load()
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

   self.top_speed = 5.0
   self.boost_speed = 8.0
   self.plant_drag = 0.75 -- percent, applied to current speed.

   self.slide_vector = 0.25
   self.turning_speed = 0.006
end

function Racer:update()
   Object.update(self)

   local speed = self.top_speed
   if self.boost_timer > 0 then
      speed = self.boost_speed
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
      self.drag = self.drag + 1
   elseif key.state == "slide-right" then
      thrust = vector_from_angle(self.rotation - self.slide_vector)
      self.drag = self.drag + 1
   else
      if self.drag > 5 then
         self.boost_timer = self.drag
      end
      self.drag = 0
   end
   if self.drag > self.max_drag then
      self.drag = self.max_drag
   end

   speed = math.max(speed - self.drag * (self.top_speed / self.max_drag), 0)
   self.velocity = thrust * speed

   if key.state == "left" or key.state == "slide-left" then
      self.rotational_velocity = self.turning_speed * -1
   end
   if key.state == "right" or key.state == "slide-right" then
      self.rotational_velocity = self.turning_speed
   end
   if key.state == "slide-left" or key.state == "slide-right" then
      self.rotational_velocity = self.rotational_velocity * 1.5
   end

   for i = 1, self.seed_rate do
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 1, math.random(1,2))
   end

   camera.position = racer.position + vector_from_angle(racer.rotation) * 100.0
   camera.rotation = racer.rotation + 0.5
   self.boost_timer = self.boost_timer - 1
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
