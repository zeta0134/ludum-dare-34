local camera = require("camera")
local key = require("key")
local lurker = require("lurker")
local Racer = require("racer")
local sounds = require("sounds")
local sprites = require("sprites")
local stage = require("stage")

player = Racer.new_racer()

function load(f)
   love.window.setTitle("Tailwind")

   -- load and initialize resources
   sprites.load()
   sounds.load()
   sounds.stop_all()
   key.register_handlers(love)

   -- setup game stage and state
   stage:load("art/bad-track.png")
   player:load()

   --debug
   s = sprites.new("sprite-test2")
end

function love.load()
   load(nil)
end

lurker.postswap = load

function love.draw()
   love.graphics.setCanvas()
   love.graphics.push()
   camera:apply_transform()
   stage:draw()
   player:draw()
   love.graphics.pop()

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
   stage:update()
   player:update()
   key.update_driver_state()
   key.update()
   frame = frame + 1
end
