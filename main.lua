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
   player:load({normal_speed=10, boost_speed=10, max_drag=1, normal_turn_rate=0, slide_turn_rate=0.012})

   title_logo = sprites.new "title-logo"
   stage_select_plains = sprites.new "stage-select-plains"
   left_button = sprites.new "buttons"
   right_button = sprites.new "buttons"
   both_buttons = sprites.new "buttons"
   -- love.window.setMode(800, 600, {resizable = true})
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
   love.graphics.print("state: " .. key.title_state, 350, 290)
end

function title_draw()
   x_center = love.window.getWidth() / 2
   y_center = love.window.getHeight() / 2
   stage_select_plains:draw(x_center, y_center, nil, nil, nil, stage_select_plains:getWidth() / 2, stage_select_plains:getHeight() / 2)
   title_logo:draw(x_center, y_center / 2, nil, nil, nil, title_logo:getWidth() / 2, title_logo:getHeight() / 2)
   if key.title_state ~= 'help' then
      left_button:draw(20, y_center * 1.5, nil, nil, nil, nil, left_button:getHeight() / 2)
   end
   if key.title_state ~= 'exit' then
      right_button:draw(love.window.getWidth() - 20, y_center * 1.5, nil, nil, nil, right_button:getWidth(), left_button:getHeight() / 2)
   end
   if key.title_state ~= 'help' then
      both_buttons:draw(x_center, y_center / 4 * 7, nil, nil, nil, both_buttons:getWidth() / 2, both_buttons:getHeight() / 2)
   end
end

function button_update()
   local period = 40
   left_button:set_frame(0, math.floor(frame / period) % 2 + 2)
   right_button:set_frame(0, math.floor(frame / period) % 2 * 2 + 1)
   both_buttons:set_frame(0, math.floor(frame / period) % 2 * 3)
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
   key.update_title_state()
   button_update()
   key.update()
   frame = frame + 1
end
