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
   stage:load("art/really-bad-track.png")
   player:load()

   title_logo = sprites.new "title-logo"
   stage_select_plains = sprites.new "stage-select-plains"
   -- love.window.setMode(1920, 1080)
   -- love.window.setHeight(1080)
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
   x_center = love.window.getWidth() / 2
   y_center = love.window.getHeight() / 2
   stage_select_plains:draw(x_center, y_center, nil, nil, nil, stage_select_plains.sheet.image:getWidth() / 2, stage_select_plains.sheet.image:getHeight() / 2)
   title_logo:draw(x_center, y_center / 2, nil, nil, nil, title_logo.sheet.image:getWidth() / 2, title_logo.sheet.image:getHeight() / 2)
end

function love.draw()
   title_draw()
   game_draw()
   love.graphics.print("frame: " .. frame, 20, love.window.getHeight() - 30)
end

frame = 0
function love.update(dt)
   require("lurker").update()

   -- sounds.play "doopadoo"
   if frame % 180 == 0 then
      -- sounds.play "woosh"
   end
   -- sounds.stop_all()
   stage:update()
   player:update()
   camera:update()
   key.update_driver_state()
   key.update()
   frame = frame + 1
end
