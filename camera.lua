Vector = require("vector")

local camera = {}

camera.position = Vector.new()
camera.rotation = 0

camera.delayed_position = Vector.new()
camera.delayed_rotation = 0

function camera:apply_transform()
   -- finally, move the world one screen half-width, so we center the viewport
   love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

   -- then, rotate the world based on the camera's direction
   love.graphics.rotate(camera.delayed_rotation * -1 * math.pi)

   -- first, move to the camera's position in the world
   love.graphics.translate(camera.delayed_position.x * -1, camera.delayed_position.y * -1)
end

local camera_drag = 0.05
function camera:update()
   camera.delayed_position = camera.delayed_position * (1.0 - camera_drag) + camera.position * camera_drag
   camera.delayed_rotation = camera.delayed_rotation * (1.0 - camera_drag) + camera.rotation * camera_drag
end

return camera
