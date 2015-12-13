local stage = require("stage")

local ui = {}

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
