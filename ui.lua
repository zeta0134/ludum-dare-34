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

   ui.font = Font.new()
   ui.font:load("font", "0123456789:/.!acdeghilnoprstvwxy")
   ui.countdown_font = Font.new()
   ui.countdown_font:load("countdown-font", "!123go")

   ui.charge_meter = love.graphics.newImage("art/charge_meter_empty.png")
   ui.charge_meter_filled = love.graphics.newImage("art/charge_meter_full.png")

   ui.wrong_way_sprite = sprites.new("wrong-way")
   ui.wrong_way_timer = 0
end

function ui.draw()
   ui.frame = ui.frame + 1
   -- draw a boost meter!
   love.graphics.setColor(255, 255, 255)
   love.graphics.draw(ui.charge_meter, love.graphics.getWidth() - ui.charge_meter:getWidth() - 10, love.graphics.getHeight() - ui.charge_meter:getHeight() - 10)
   local height = (math.max(player.boost_timer, player.drag) / player.max_drag) * 128
   if height > 0 then
      if player.boost_timer > player.drag then
         love.graphics.setColor(0, 255, 255)
      else
         love.graphics.setColor(192, 0, 0)
      end
      local quad = love.graphics.newQuad(0, 128 - height, ui.charge_meter_filled:getWidth(), height, 128, 128)
      love.graphics.setBlendMode('additive')
      love.graphics.draw(ui.charge_meter_filled, quad, love.graphics.getWidth() - ui.charge_meter_filled:getWidth() - 10, love.graphics.getHeight() - height - 10)
      love.graphics.setBlendMode('alpha')
   end

   -- draw speed!
   love.graphics.setColor(255, 255, 255)
   local display_speed = string.format("%.1f", ui.speed_multiplier * player.velocity:length())
   display_speed = string.rep(" ", 5 - display_speed:len()) .. display_speed
   ui.font:draw_text(display_speed, love.graphics.getWidth() - 95, love.graphics.getHeight() - 85, {centered=true})

   -- draw lap and checkpoint data
   love.graphics.setColor(255, 255, 255)
   ui.font:draw_text(tostring(player.lap) .. "/" .. stage.properties.laps, love.graphics.getWidth() - 80, 120)
   -- love.graphics.print("CHECKPOINT: " .. player.checkpoint, 40, 30)

   -- draw timers
   ui.font:draw_text(ui.lap_time_to_string(player.race_timer), love.graphics.getWidth() / 2, 30, {centered=true})
   -- lap times
   for i = 1, #player.lap_times do
      ui.font:draw_text(tostring(i) ..": " .. ui.lap_time_to_string(player.lap_times[i]), 20, love.graphics.getHeight() - (stage.properties.laps - i + 1) * 28 - 10)
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
      ui.wrong_way_timer = ui.wrong_way_timer + 1
   else
      ui.wrong_way_timer = 0
   end

   if ui.wrong_way_timer > 60 then
      if math.floor((ui.frame % 60) / 30) == 0 then
	 ui.wrong_way_sprite:draw(love.graphics.getWidth() / 2, 0.25 * love.graphics.getHeight(), nil, nil, nil, ui.wrong_way_sprite:getWidth() / 2, ui.wrong_way_sprite:getHeight() / 2)
      end
   end

   love.graphics.setColor(255, 255, 255)
   -- love.graphics.print("Stage: " .. stage.race_stages[stage.race_stage].name, 300, 10)
   local countdown_mapping = {
      ["1"] = "1",
      ["2"] = "2",
      ["3"] = "3",
      GO = "go!"
   }
   local mapping = countdown_mapping[stage.race_stages[stage.race_stage].name]
   -- this blinks because the countdown isn't always second aligned
   if mapping and stage.stage_timer < 50 then
      ui.countdown_font:draw_text(mapping, love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, {centered=true})
   end
end

return ui
