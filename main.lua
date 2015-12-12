-- Sound effects/music
-- Sprite sheets
-- Input

key_map = {lctrl='left', rctrl='right'}
keys_down = {left=false, right=false}
function key_down()
   if keys_down.left and keys_down.right then return 'both'
   elseif keys_down.left then return 'left'
   elseif keys_down.right then return 'right'
   else return nil end
end

last_keys_down = nil
function key_hit()
   if key_down() ~= last_keys_down then
      return key_down()
   end
   return nil
end

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

state = 'straight'
function update_drive_state()
   if state == 'straight' then
      if key_down() == 'left' then state = 'left'
      elseif key_down() == 'right' then state = 'right'
      end
   elseif state == 'left' then
      if not key_down() then state = 'straight'
      elseif key_hit() == 'both' then state = 'slide-left'
      end
   elseif state == 'right' then
      if not key_down() then state = 'straight'
      elseif key_hit() == 'both' then state = 'slide-right'
      end
   elseif state == 'slide-left' then
      if not key_down() then state = 'straight'
      elseif key_hit() == 'both' then state = 'left'
      end
   elseif state == 'slide-right' then
      if not key_down() then state = 'straight'
      elseif key_hit() == 'both' then state = 'right'
      end
   end
end

function love.draw()
   love.graphics.print("state: " .. state, 350, 270)
end

frame = 0
function love.update(dt)
   require("lurker").update()
   frame = frame + 1
   update_drive_state()
   last_keys_down = key_down()
end
