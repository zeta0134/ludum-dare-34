Vector = require("vector")

local camera = {}

camera.position = Vector.new()
camera.rotation = 0

function camera:apply_transform()
   -- finally, move the world one screen half-width, so we center the viewport
   love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

   -- then, rotate the world based on the camera's direction
   love.graphics.rotate(camera.rotation * -1 * math.pi)

   -- first, move to the camera's position in the world
   love.graphics.translate(camera.position.x * -1, camera.position.y * -1)
end

return camera
