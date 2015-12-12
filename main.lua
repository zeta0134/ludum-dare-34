-- Sound effects/music
-- Sprite sheets
-- Input

key_map = {lctrl='left', rctrl='right'}
keys_down = {left=false, right=false}
function love.keypressed(key, is_repeat)
   for input, output in pairs(key_map) do
      if key == input then
	 keys_down[output] = true
      end
   end
end

function love.keyreleased(key, is_repeat)
   for input, output in pairs(key_map) do
      if key == input then
	 keys_down[output] = false
      end
   end
end

function love.draw()
   if keys_down.left then
      love.graphics.print("left", 300, 300)
   end
   if keys_down.right then
      love.graphics.print("right", 400, 300)
   end
   if keys_down.left and keys_down.right then
      love.graphics.print("both", 350, 300)
   end
end

function love.update()
   require("lurker").update()
end
