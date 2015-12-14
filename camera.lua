Vector = require("vector")

local camera = {}

camera.position = Vector.new()
camera.rotation = 0
camera.zoom = 1

camera.delayed_position = Vector.new()
camera.delayed_rotation = 0
camera.delayed_zoom = 1

function camera:apply_transform()
   -- finally, move the world one screen half-width, so we center the viewport
   love.graphics.translate(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)

   love.graphics.scale(camera.delayed_zoom, camera.delayed_zoom)

   -- then, rotate the world based on the camera's direction
   love.graphics.rotate(camera.delayed_rotation * -1 * math.pi)

   -- first, move to the camera's position in the world
   love.graphics.translate(camera.delayed_position.x * -1, camera.delayed_position.y * -1)
end

camera.drag = 0.04
function camera:update()
   camera.delayed_position = camera.delayed_position * (1.0 - camera.drag) + camera.position * camera.drag
   camera.delayed_rotation = camera.delayed_rotation * (1.0 - camera.drag) + camera.rotation * camera.drag
   camera.delayed_zoom = camera.delayed_zoom * (1.0 - camera.drag) + camera.zoom * camera.drag
end

function camera:set(x, y, r)
   camera.position.x = x
   camera.position.y = y
   camera.rotation = r
   camera.delayed_position.x = x
   camera.delayed_position.y = y
   camera.delayed_rotation = r
end

return camera
