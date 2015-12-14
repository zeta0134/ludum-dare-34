local camera = require("camera")
local Font = require("font")
local highscores = require("highscores")
local key = require("key")
local leaf_types = require("leaf_types")
local levels = require("levels")
local lurker = require("lurker")
local Racer = require("racer")
local sounds = require("sounds")
local sprites = require("sprites")
local stage = require("stage")
local ui = require("ui")

fps = 60
min_dt = 1 / fps
next_frame = love.timer.getTime()

function init_stage(stage_name, leaf_type)
   player = Racer.new_racer()
   player:load(leaf_types[leaf_type])
   stage:load(levels[stage_name])
end

function load(f)
   love.window.setTitle("Tailwind")

   -- load and initialize resources
   sprites.load()
   sounds.load()
   sounds.stop_all()
   key.register_handlers(love)

   title_logo = sprites.new "title-logo"
   stage_select = {}
   stage_select.help = sprites.new "help"
   stage_select.plains = sprites.new "stage-select-plains"
   stage_select.desert = sprites.new "stage-select-desert"
   stage_select.volcano = sprites.new "stage-select-volcano"
   stage_select.exit = sprites.new "exit"
   left_button = sprites.new "buttons"
   right_button = sprites.new "buttons"
   both_buttons = sprites.new "buttons"

   help_state = 'straight'
   help_buttons = sprites.new "buttons"
   help_animation = sprites.new "oak-player"

   love.window.setIcon(sprites.sheets["icon"].image:getData())
   love.window.setMode(800, 600, {resizable = true})
end

function love.load()
   load(nil)
   ui.init()
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
   if key.title_state == 'help' then
      help_buttons:draw(x_center - 100, y_center + 80, nil, nil, nil, both_buttons:getWidth() / 2, both_buttons:getHeight() / 2)
      help_animation:draw(x_center + 50, y_center + 80, -3.1415 / 2, nil, nil, help_animation:getWidth() / 2, help_animation:getHeight() / 2)
   end

   --love.graphics.print("state: " .. key.title_state, 350, 290)

   if highscores.courses[key.title_state] then
      highscores_draw(key.title_state)
   end
end

function highscores_draw(title_name)
   local x_center = love.window.getWidth() / 2
   local y_center = love.window.getHeight() / 2
   local y = y_center / 2 + (title_logo:getHeight() / 2)
   ui.font:draw_text("record race:", x_center, y, {centered=true}); y = y + 35
   ui.font:draw_text(ui.lap_time_to_string(highscores:bestRaceTime(title_name)), x_center, y, {centered=true}); y = y + 35
   ui.font:draw_text("record lap:", x_center, y, {centered=true}); y = y + 35
   ui.font:draw_text(ui.lap_time_to_string(highscores:bestLapTime(title_name)), x_center, y, {centered=true})
end

function button_update()
   local period = 40
   left_button:set_frame(0, math.floor(frame / period) % 2 + 2)
   right_button:set_frame(0, math.floor(frame / period) % 2 * 2 + 1)
   both_buttons:set_frame(0, math.floor(frame / period) % 2 * 3)
end

help_keyframes = {
   {0, 'straight'},
   {30, 'left'},
   {60, 'straight'},
   {90, 'left'},
   {120, 'straight'},
   {150, 'right'},
   {180, 'straight'},
   {210, 'right'},
   {240, 'straight'},
   {270, 'left'},
   {285, 'left-slide'},
   {325, 'boost'},
   {370, 'straight'},
   {400, 'right'},
   {415, 'right-slide'},
   {455, 'boost'},
   {485, 'loop'}
}

help_frame_map = {
   straight = {0, 0, 3},
   left = {1, 1, 2},
   right = {1, 0, 1},
   ['left-slide'] = {2, 1, 0},
   ['right-slide'] = {2, 0, 0},
   boost = {0, 1, 3}
}

function help_update()
   local frame = 'straight'
   local i
   for i = 1, #help_keyframes do
      if help_keyframes[i][1] <= key.help_frame then
	 frame = help_keyframes[i][2]
      end
   end

   if frame == 'loop' then
      key.help_frame = 0
      frame = help_keyframes[1][2]
   end

   local mapping = help_frame_map[frame]
   help_animation:set_frame(mapping[1], mapping[2])
   help_buttons:set_frame(0, mapping[3])
end

game_state = 'title'
function game_update()
   if game_state == 'title' and key.title_state:find("-selected") then
      key.title_state = key.title_state:gsub("(.+)-selected", "%1")
      if key.title_state == 'exit' then
	      love.event.push('quit')
         return
      end
      init_stage(key.title_state, "Oak")
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
   love.graphics.print("frame: " .. frame, 20, love.window.getHeight() - 50)
   love.graphics.print("fps: " .. love.timer.getFPS(), 20, love.window.getHeight() - 30)
end

frame = 0
function love.update(dt)
   require("lurker").update()
   next_frame = next_frame + min_dt
   local current_time = love.timer.getTime()
   if next_frame <= current_time then
      next_frame = current_time
      return
   end
   love.timer.sleep(next_frame - current_time)

   -- sounds.play "doopadoo"
   if frame % 180 == 0 then
      -- sounds.play "woosh"
   end
   -- sounds.stop_all()
   if game_state == 'title' then
      key.update_title_state()
      key.help_frame = key.help_frame + 1
      help_update()
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
