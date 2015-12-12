-- Sound effects/music
-- Sprite sheets
-- Input

require "key"

function love.load()
   key.register_handlers(love)
end

function love.draw()
   love.graphics.print("state: " .. key.state, 350, 270)
end

frame = 0
function love.update(dt)
   require("lurker").update()
   frame = frame + 1
   key.update_driver_state()
   key.update()
end
