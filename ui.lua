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
   love.graphics.print("LAP: " .. player.lap, 40, 10)
   love.graphics.print("CHECKPOINT: " .. player.checkpoint, 40, 30)
end

return ui
