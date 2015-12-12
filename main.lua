-- Sound effects/music
-- Sprite sheets
-- Input
stage = require("stage")
Racer = require("racer")

player = Racer.new_racer()

require "key"

function love.load()
   stage:load("art/bad-track.png")
   player:load()

   key.register_handlers(love)
end

function love.draw()
   stage:draw()
   player:draw()
   
   love.graphics.print("state: " .. key.state, 350, 270)
end

frame = 0
function love.update(dt)
   require("lurker").update()
   player:update()
   frame = frame + 1
   key.update_driver_state()
   key.update()
end
