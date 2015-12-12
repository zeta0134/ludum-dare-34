local Vector = require("vector")
local Object = require("object")
local camera = require("camera")

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

   self:set_image("art/bad-racer.png", true)

   self.position.x = 0
   self.position.y = 0

   self.rotational_damping = 0.1

   self.seed_spread = 20
   self.seed_rate = 10
end

function Racer:update()
   Object.update(self)

   self.velocity = vector_from_angle(self.rotation) * 0.5

   if key.state == "left" or key.state == "slide-left" then
      self.rotational_velocity = -0.01
   end
   if key.state == "right" or key.state == "slide-right" then
      self.rotational_velocity = 0.01
   end

   for i = 1, self.seed_rate do
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 255, 255, 255)
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
