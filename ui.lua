local stage = require("stage")

local ui = {}

local function lap_time_to_string(time_in_frames)
   local minutes = math.floor(time_in_frames / (60 * 60))
   local seconds = math.floor(time_in_frames / 60) - (minutes * 60)
   local hundredths = math.floor((time_in_frames % 60) * 100 / 60)

   return string.format("%02d:%02d:%02d", minutes, seconds, hundredths)
end

function ui.draw()
   -- draw a boost meter!
   love.graphics.setColor(32, 32, 32)
   love.graphics.rectangle("fill", 10,10,20,200)
   local height = (math.max(player.boost_timer, player.drag) / player.max_drag) * 200
   if height > 0 then
      if player.boost_timer > player.drag then
         love.graphics.setColor(0, 255, 255)
      else
         love.graphics.setColor(192, 0, 0)
      end
      love.graphics.rectangle("fill", 10, 10 + 200 - height, 20, height)
   end

   -- draw lap and checkpoint data
   love.graphics.setColor(255, 255, 255)
   love.graphics.print("LAP: " .. player.lap, 40, 10)
   love.graphics.print("CHECKPOINT: " .. player.checkpoint, 40, 30)

   -- draw timers
   love.graphics.print("RACE TIME: " .. lap_time_to_string(player.race_timer), 40, 70)
   for i = 1, #player.lap_times do
      love.graphics.print("LAP ".. i .." TIME: " .. lap_time_to_string(player.lap_times[i]), 40, 70 + i * 20)
   end

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

   love.graphics.setColor(255, 255, 255)
   love.graphics.print("Stage: " .. stage.race_stages[stage.race_stage].name, 300, 10)
end

return ui
