module(..., package.seeall)

local map = {lctrl='left', rctrl='right'}
local keys_down = {left=false, right=false}
function down()
   if keys_down.left and keys_down.right then return 'both'
   elseif keys_down.left then return 'left'
   elseif keys_down.right then return 'right'
   else return nil end
end

local last_keys_down = nil
function hit()
   if down() ~= last_keys_down then
      return down()
   end
   return nil
end

function update()
   last_keys_down = down()
end

local function keypressed(key, is_repeat)
   for physical_key, virtual_key in pairs(map) do
      if key == physical_key then
	 keys_down[virtual_key] = true
      end
   end
end

local function keyreleased(key, is_repeat)
   for physical_key, virtual_key in pairs(map) do
      if key == physical_key then
	 keys_down[virtual_key] = false
      end
   end
end

function register_handlers(l)
   l.keypressed = keypressed
   l.keyreleased = keyreleased
end

state = 'straight'
function update_driver_state()
   if state == 'straight' then
      if down() == 'left' then state = 'left'
      elseif down() == 'right' then state = 'right'
      end
   elseif state == 'left' then
      if not down() then state = 'straight'
      elseif hit() == 'both' then state = 'slide-left'
      end
   elseif state == 'right' then
      if not down() then state = 'straight'
      elseif hit() == 'both' then state = 'slide-right'
      end
   elseif state == 'slide-left' then
      if not down() then state = 'straight'
      elseif hit() == 'both' then state = 'straight'
      end
   elseif state == 'slide-right' then
      if not down() then state = 'straight'
      elseif hit() == 'both' then state = 'straight'
      end
   end
end