local sprites = require("sprites")
local Vector = require("vector")

local Object = {}

Object.position = Vector.new()
Object.velocity = Vector.new()
Object.acceleration = Vector.new()
Object.origin = Vector.new()

Object.rotation = 0 -- in R * pi
Object.rotational_velocity = 0
Object.rotational_acceleration = 0

Object.rotational_damping = 0 -- percentage

function Object:set_sprite(sprite_name, centered)
   self.sprite = sprites.new(sprite_name)
   if centered then
      Object.origin.x = self.sprite.sheet.frame_width / 2
      Object.origin.y = self.sprite.sheet.frame_height / 2
   end
end

function Object:load()
   -- STUB
end

function Object:update()
   self.position = self.position + self.velocity
   self.velocity = self.velocity + self.acceleration

   self.rotation = self.rotation + self.rotational_velocity
   self.rotational_velocity = self.rotational_velocity + self.rotational_acceleration
   if self.rotational_damping > 0 then
      self.rotational_velocity = (1 - self.rotational_damping) * self.rotational_velocity
   end
   if self.rotation > 1 then
      self.rotation = self.rotation % 2
      self.rotation = self.rotation - 2
   end
   if self.rotation < -1 then
      self.rotation = self.rotation % -2
      self.rotation = self.rotation + 2
   end
end

function Object:draw()
   love.graphics.push()
   self.sprite:draw(self.position.x, self.position.y, self.rotation * math.pi, nil, nil, self.origin.x, self.origin.y)
   love.graphics.pop()
end

return Object
