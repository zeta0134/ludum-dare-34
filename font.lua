sprites = require("sprites")
local Font = {}

function Font:load(sprite_name, characters)
   self.sprite = sprites.new(sprite_name)
   self.characters = characters
end

function Font:draw_text(text, x, y)
   for i = 1, #text do
      -- figure out if we can draw this character, and which sprite frame
      -- it is
      local char_frame = self.characters:find(text:sub(i, i))
      if char_frame then
         self.sprite:set_frame(char_frame - 1, 0)
         self.sprite:draw(x, y)
      end
      x = x + self.sprite.sheet.frame_width
   end
end

function Font.new()
   local font = {}
   setmetatable(font, {__index=Font})
   return font
end

return Font
