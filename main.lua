-- Sound effects/music
-- Sprite sheets
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
   love.graphics.print("frame: " .. frame, 350, 290)
end

frame = 0
function love.update(dt)
   require("lurker").update()
   -- love.audio.stop()
   -- if frame == 0 then
   --    music = love.audio.newSource('doopadoo.ogg')
   --    music:setLooping(true)
   --    music:play()
   -- end
   -- if frame % 180 == 0 then
   --    love.audio.play(love.audio.newSource('woosh.ogg'), 'static')
   -- end
   player:update()
   key.update_driver_state()
   key.update()
   frame = frame + 1
end
