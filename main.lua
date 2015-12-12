-- Sprite sheets
stage = require("stage")
Racer = require("racer")

player = Racer.new_racer()

lurker = require "lurker"
require "key"
require "sounds"
require "sprites"

function load(f)
   stage:load("art/bad-track.png")
   player:load()

   key.register_handlers(love)
   sounds.load()
   sounds.stop_all()
   sprites.load()
   s = sprites.new("sprite-test2")
end

function love.load()
   load(nil)
end

lurker.postswap = load

function love.draw()
   stage:draw()
   player:draw()
   
   love.graphics.print("state: " .. key.state, 350, 270)
   love.graphics.print("frame: " .. frame, 350, 290)
   s:draw(0, 0)
end

frame = 0
function love.update(dt)
   require("lurker").update()

   s:set_frame(frame / 15 % 2, frame / 30 % 4)
   -- sounds.play "doopadoo"
   if frame % 180 == 0 then
      -- sounds.play "woosh"
   end
   -- sounds.stop_all()
   player:update()
   key.update_driver_state()
   key.update()
   frame = frame + 1
end
