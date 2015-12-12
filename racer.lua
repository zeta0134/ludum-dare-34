local Vector = require("vector")
local Object = require("object")

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

   self.position.x = 320
   self.position.y = 240

   self.rotational_velocity = 0.01
   --self.rotational_damping = 0.01
end

function Racer:update()
   Object.update(self)

   self.velocity = vector_from_angle(self.rotation) * 3
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
