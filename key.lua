local key = {}

local map = {lctrl='left', rctrl='right'}
local keys_down = {left=false, right=false}
function key.down()
   if keys_down.left and keys_down.right then return 'both'
   elseif keys_down.left then return 'left'
   elseif keys_down.right then return 'right'
   else return nil end
end

local last_keys_down = nil
function key.hit()
   if key.down() ~= last_keys_down then
      return key.down()
   end
   return nil
end

function key.update()
   last_keys_down = key.down()
end

function key.keypressed(key, is_repeat)
   for physical_key, virtual_key in pairs(map) do
      if key == physical_key then
	 keys_down[virtual_key] = true
      end
   end
end

function key.keyreleased(key, is_repeat)
   for physical_key, virtual_key in pairs(map) do
      if key == physical_key then
	 keys_down[virtual_key] = false
      end
   end
end

function key.register_handlers(l)
   l.keypressed = key.keypressed
   l.keyreleased = key.keyreleased
end

key.state = 'straight'
function key.update_driver_state()
   if key.state == 'straight' then
      if key.down() == 'left' then key.state = 'left'
      elseif key.down() == 'right' then key.state = 'right'
      end
   elseif key.state == 'left' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'slide-left'
      end
   elseif key.state == 'right' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'slide-right'
      end
   elseif key.state == 'slide-left' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'straight'
      end
   elseif key.state == 'slide-right' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'straight'
      end
   end
end

return key
