module(..., package.seeall)

local music_dir = "sounds/music/"
local sfx_dir = "sounds/sfx/"

music = {}
sfx = {}

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
   load_into(music_dir, music)

   local title
   local source
   for title, source in pairs(music) do
      source:setLooping(true)
   end
end

local function load_sfx()
   load_into(sfx_dir, sfx)
end

function load()
   load_music()
   load_sfx()
end

function stop_all()
   love.audio.stop()
end

function play(source)
   local title
   local sound
   for title, sound in pairs(sfx) do
      if source == title then
	 sound:clone():play()
	 return
      end
   end

   local currently_playing
   local next_playing
   for title, sound in pairs(music) do
      if sound:isPlaying() then currently_playing = title end
      if source == title then
	 next_playing = title
	 break
      end
   end
   if next_playing == currently_playing then return end
   if next_playing then
      if currently_playing then music[currently_playing]:stop() end
      music[next_playing]:play()
   end
end