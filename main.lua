local camera = require("camera")
local key = require("key")
local leaf_types = require("leaf_types")
local lurker = require("lurker")
local Racer = require("racer")
local sounds = require("sounds")
local sprites = require("sprites")
local stage = require("stage")
local ui = require("ui")

function load(f)
   love.window.setTitle("Tailwind")
   player = Racer.new_racer()

   -- load and initialize resources
   sprites.load()
   sounds.load()
   sounds.stop_all()
   key.register_handlers(love)

   -- setup game stage and state
   stage:load("art/really-bad-track.png", "art/really-bad-track-control.png")
   player:load(leaf_types["Oak"])
   player.position = Vector.new(351,888)
   player.rotation = -0.5

   title_logo = sprites.new "title-logo"
   stage_select = {}
   stage_select.plains = sprites.new "stage-select-plains"
   stage_select.desert = sprites.new "stage-select-desert"
   stage_select.volcano = sprites.new "stage-select-volcano"
   stage_select.exit = sprites.new "exit"
   left_button = sprites.new "buttons"
   right_button = sprites.new "buttons"
   both_buttons = sprites.new "buttons"
   love.window.setIcon(sprites.sheets["icon"].image:getData())
   love.window.setMode(800, 600, {resizable = true})
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
   local background = stage_select[key.title_state]
   background:draw(x_center, y_center, nil, nil, nil, background:getWidth() / 2, background:getHeight() / 2)
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
   love.graphics.print("state: " .. key.title_state, 350, 290)
end

function button_update()
   local period = 40
   left_button:set_frame(0, math.floor(frame / period) % 2 + 2)
   right_button:set_frame(0, math.floor(frame / period) % 2 * 2 + 1)
   both_buttons:set_frame(0, math.floor(frame / period) % 2 * 3)
end

game_state = 'title'
function game_update()
   if game_state == 'title' and key.title_state:find("-selected") then
      key.title_state = key.title_state:gsub("(.+)-selected", "%1")
      if key.title_state == 'exit' then
	 love.event.push('quit')
      end
      game_state = 'playing'
   end
end

function love.draw()
   if game_state == 'title' then
      title_draw()
   elseif game_state == 'playing' then
      game_draw()
      ui.draw()
   end
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
   if game_state == 'title' then
      key.update_title_state()
   elseif game_state == 'playing' then
      stage:update()
      player:update()
      camera:update()
      key.update_driver_state()
   end
   button_update()
   game_update()
   key.update()
   frame = frame + 1
end
