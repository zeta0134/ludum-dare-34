local sounds = {}

local music_dir = "sounds/music/"
local sfx_dir = "sounds/sfx/"

sounds.music = {}
sounds.sfx = {}

local function streaming(f)
   return love.audio.newSource(f)
end

local function static(f)
   return love.audio.newSource(f, 'static')
end

local function load_into(dir, t)
   local files = love.filesystem.getDirectoryItems(dir)
   local filename
   for _, filename in ipairs(files) do
      local title = filename:gsub("(.+)%..+", "%1")
      t[title] = streaming(dir .. filename)      
   end
end

local function load_music()
   load_into(music_dir, sounds.music)

   local title
   local source
   for title, source in pairs(sounds.music) do
      source:setLooping(true)
   end
end

local function load_sfx()
   load_into(sfx_dir, sounds.sfx)
end

function sounds.load()
   load_music()
   load_sfx()
end

function sounds.stop_all()
   love.audio.stop()
end

function sounds.play(source)
   local title
   local sound
   for title, sound in pairs(sounds.sfx) do
      if source == title then
	 sound:clone():play()
	 return
      end
   end

   local currently_playing
   local next_playing
   for title, sound in pairs(sounds.music) do
      if sound:isPlaying() then currently_playing = title end
      if source == title then
	 next_playing = title
	 break
      end
   end
   if next_playing == currently_playing then return end
   if next_playing then
      if currently_playing then music[currently_playing]:stop() end
      sounds.music[next_playing]:play()
   end
end

return sounds
