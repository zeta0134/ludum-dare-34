local Font = require("font")
local stage = require("stage")
local sprites = require("sprites")

local ui = {}
ui.speed_multiplier = 3.14159265358979

function ui.lap_time_to_string(time_in_frames)
   local minutes = math.floor(time_in_frames / (60 * 60))
   local seconds = math.floor(time_in_frames / 60) - (minutes * 60)
   local hundredths = math.floor((time_in_frames % 60) * 100 / 60)

   return string.format("%02d:%02d:%02d", minutes, seconds, hundredths)
end

function ui.init()
   ui.minimap_icon = love.graphics.newImage("art/minimap-icon.png")
   ui.frame = 0

   ui.bad_font = Font.new()
   ui.bad_font:load("reallybad_font", "0123456789")
   ui.font = Font.new()
   ui.font:load("font", "0123456789:/.")

   ui.charge_meter = love.graphics.newImage("art/charge_meter_empty.png")
   ui.charge_meter_filled = love.graphics.newImage("art/charge_meter_full.png")

   ui.wrong_way_sprite = sprites.new("wrong-way")
end

function ui.draw()
   ui.frame = ui.frame + 1
   -- draw a boost meter!
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(ui.charge_meter, love.graphics.getWidth() - 54 - 10, love.graphics.getHeight() - 128 - 10)
   local height = (math.max(player.boost_timer, player.drag) / player.max_drag) * 128
   if height > 0 then
      if player.boost_timer > player.drag then
         love.graphics.setColor(0, 255, 255)
      else
         love.graphics.setColor(192, 0, 0)
      end
      local quad = love.graphics.newQuad(0, 128 - height, 54, height, 54, 128)
      love.graphics.draw(ui.charge_meter_filled, quad, love.graphics.getWidth() - 54 - 10, love.graphics.getHeight() - height - 10)
   end

   -- draw speed!
   love.graphics.setColor(255, 255, 255)
   local display_speed = string.format("%.1f", ui.speed_multiplier * player.velocity:length())
   display_speed = string.rep(" ", 5 - display_speed:len()) .. display_speed
   ui.font:draw_text(display_speed, love.graphics.getWidth() - 120, love.graphics.getHeight() - 50)

   -- draw lap and checkpoint data
   love.graphics.setColor(255, 255, 255)
   ui.font:draw_text(tostring(player.lap) .. "/" .. stage.properties.laps, 40, 10)
   love.graphics.print("CHECKPOINT: " .. player.checkpoint, 40, 30)

   -- draw timers
   ui.font:draw_text(ui.lap_time_to_string(player.race_timer), 40, 70)
   for i = 1, #player.lap_times do
      ui.font:draw_text(tostring(i) ..": " .. ui.lap_time_to_string(player.lap_times[i]), 40, 120 + i * 28)
   end

   -- minimap!
   love.graphics.setColor(255, 255, 255)
   local minimap_scale = 2048 / 100
   local minimap_x = love.graphics.getWidth() - stage.minimap_image:getWidth() - 10
   local minimap_y = 10
   love.graphics.draw(stage.minimap_image, minimap_x, minimap_y)
   local icon_x = (player.position.x / minimap_scale) + minimap_x
   local icon_y = (player.position.y / minimap_scale) + minimap_y
   love.graphics.setColor(64, 255, 64)
   love.graphics.draw(ui.minimap_icon, icon_x, icon_y, nil, nil, nil, 8, 8)
   love.graphics.setColor(255, 255, 255)


   -- handle race pre-fade happiness
   if stage.race_stages[stage.race_stage].name == "prefade" then
      love.graphics.setColor(0, 0, 0, 255)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   end
   if stage.race_stages[stage.race_stage].name == "fadein" then
      local fade_duration = stage.race_stages[stage.race_stage].duration
      local fade_progress = stage.stage_timer
      local alpha = ((fade_duration - fade_progress) / fade_duration) * 255
      love.graphics.setColor(0, 0, 0, alpha)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   end
   if stage.race_stages[stage.race_stage].name == "postfade" then
      local fade_duration = stage.race_stages[stage.race_stage].duration
      local fade_progress = stage.stage_timer
      local alpha = ((fade_progress) / fade_duration) * 255
      love.graphics.setColor(0, 0, 0, alpha)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   end

   if player.warp_timer > 0 then
      local fade_amount = math.abs(player.warp_timer - 30)
      love.graphics.setColor(0, 0, 0, (30 - fade_amount) * 255 / 30)
      love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
   end

   if player.wrong_way then
      if math.floor((ui.frame % 60) / 30) == 0 then
	 ui.wrong_way_sprite:draw(love.graphics.getWidth() / 2, 0.25 * love.graphics.getHeight(), nil, nil, nil, ui.wrong_way_sprite:getWidth() / 2, ui.wrong_way_sprite:getHeight() / 2)
      end
   end

   love.graphics.setColor(255, 255, 255)
   love.graphics.print("Stage: " .. stage.race_stages[stage.race_stage].name, 300, 10)

   ui.font:draw_text("42-100", 100, 100)
end

return ui
