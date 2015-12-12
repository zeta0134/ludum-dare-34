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

   self.rotational_damping = 0.1

   self.seed_spread = 15
   self.seed_rate = 1
end

function Racer:update()
   Object.update(self)

   local speed = 4.0
   local flower_here, growth_state, flower_type = stage:flower_at(self.position.x, self.position.y)
   if flower_here then
      if growth_state > 0 then
         speed = 3.0
      end
   end

   self.velocity = vector_from_angle(self.rotation) * speed

   if key.state == "left" or key.state == "slide-left" then
      self.rotational_velocity = -0.01
   end
   if key.state == "right" or key.state == "slide-right" then
      self.rotational_velocity = 0.01
   end

   for i = 1, self.seed_rate do
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 1, math.random(1,2))
   end

   camera.position = racer.position
   camera.rotation = racer.rotation + 0.5
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
