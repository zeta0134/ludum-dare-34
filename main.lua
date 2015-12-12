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

   title_logo = sprites.new "title-logo"
end

function love.load()
   load(nil)
end

lurker.postswap = load

function game_draw()
   love.graphics.setCanvas()
   love.graphics.push()
   camera:apply_transform()
   stage:draw()
   player:draw()
   love.graphics.pop()

   love.graphics.print("state: " .. key.state, 350, 270)
end

function title_draw()
   title_logo:draw(love.window.getWidth() / 2, love.window.getHeight() / 4, nil, nil, nil, title_logo.sheet.image:getWidth() / 2, title_logo.sheet.image:getHeight() / 2)
end

function love.draw()
   game_draw()
   title_draw()
   love.graphics.print("frame: " .. frame, 20, 570)
end

frame = 0
function love.update(dt)
   require("lurker").update()

   -- sounds.play "doopadoo"
   if frame % 180 == 0 then
      -- sounds.play "woosh"
   end
   -- sounds.stop_all()
   player:update()
   stage:update()
   key.update_driver_state()
   key.update()
   frame = frame + 1
end
