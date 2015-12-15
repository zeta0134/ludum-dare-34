local key = {}

local map = {
   lctrl='left', rctrl='right',
   lshift='left', rshift='right',
   a='left', d='right',
   left='left', right='right',
   h='left', l='right',
   f='right', b='left'
}
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
end

function key.release()
   if key.down() ~= last_keys_down then
      if last_keys_down == 'both' then
	 if key.down() == 'left' then return 'right'
	 elseif key.down() == 'right' then return 'left'
	 else return 'both'
	 end
      elseif key.down() ~= 'both' then
	 return last_keys_down
      end
   end
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
      elseif key.down() == 'both' then key.state = 'slide-right'
      end
   elseif key.state == 'left' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'slide-left'
      end
   elseif key.state == 'right' then
      if not key.down() then key.state = 'straight'
      elseif key.hit() == 'both' then key.state = 'slide-right'
      end
   elseif key.state == 'slide-left' or key.state == 'slide-right' then
      if key.down() ~= 'both' then key.state = 'straight'
      end
   end
end

key.title_state = 'plains'
key.help_frame = 0
-- TODO: load in the list of stages from somewhere else
key.title_stages = {'plains', 'desert', 'volcano'}
function key.update_title_state(dt)
   if key.hit() == 'both' and key.title_state ~= 'help' then
      key.title_state = key.title_state .. '-selected'
      return
   end

   if key.title_state == 'help' and last_keys_down ~= 'both' and key.release() == 'right' then
      key.title_state = key.title_stages[1]
      return
   end
   if key.title_state == 'exit' and key.release() == 'left' then
      key.title_state = key.title_stages[#key.title_stages]
      return
   end

   local current_stage, i, stage
   for i, stage in ipairs(key.title_stages) do
      if key.title_state == stage then current_stage = i end
   end
   if not current_stage then return end
   if current_stage == 1 and key.release() == 'left' then
      key.title_state = 'help'
      key.help_frame = 0
      return
   end
   if current_stage == #key.title_stages and key.release() == 'right' then
      key.title_state = 'exit'
      return
   end

   if key.release() == 'left' then key.title_state = key.title_stages[current_stage - 1]
   elseif key.release() == 'right' then key.title_state = key.title_stages[current_stage + 1]
   end
end

return key