local highscores = {}

highscores.courses = {
   plains={
      race_times={
         [1]={
            time=999999,
            staff=true
         }
      },
      lap_times={
         [1]={
            time=999999,
            staff=true
         }
      }
   }
}

highscores.filename = "scores.txt"

function highscores:loadFromFile()
   local highscores_lua = love.filesystem.read(self.filename)
   if highscores_lua then
      if #highscores_lua > 0 then
         print(highscores_lua)
         loadstring(highscores_lua)()
         print("Read highscores!")
      end
   end
end

function serialize(o)
   local output = ""
   if type(o) == "number" then
      output = output .. o
   elseif type(o) == "string" then
      output = output .. string.format("%q", o)
   elseif type(o) == "table" then
      output = output .. "{\n"
      for k,v in pairs(o) do
         if type(k) == "number" then
            output = output .. "  [" ..  k .. "] = "
         elseif type(k) == "string" then
            output = output .. "  [" ..  string.format("%q", k) .. "] = "
         end
         output = output .. serialize(v)
         output = output .. ",\n"
      end
      output = output .. "}\n"
   else
      error("cannot serialize a " .. type(o))
   end
   return output
 end

function highscores:saveToFile()
   love.filesystem.write(self.filename, "highscores.courses = " .. serialize(highscores.courses))
end

function highscores:addScore(course_name, race_time, lap_times)
   if not self.courses[course_name] then
      self.courses[course_name] = {}
      self.courses[course_name].race_times = {}
      self.courses[course_name].lap_times = {}
   end

   local course = self.courses[course_name]

   local race_time_saved = false
   for i = 1, #course.race_times do
      if race_time < course.race_times[i].time then
         table.insert(course.race_times, i, {time=race_time})
         while #course.race_times > 3 do
            table.remove(course.race_times, 4)
         end
         race_time_saved = true
         break --stop considering race times! we've had our fun
      end
      if race_time == course.race_times[i].time then
         -- we've tied a score! this does nothing, on purpose, to avoid dupes
         race_time_saved = true
         break
      end
   end
   if race_time_saved == false and #course.race_times < 3 then
      table.insert(course.race_times, {time=race_time})
   end

   --grab the lowest lap time from the provided list of scores
   self.lowest_lap_time = lap_times[1]
   for i = 2, #lap_times do
      if lap_times[i] < self.lowest_lap_time then
         self.lowest_lap_time = lap_times[i]
      end
   end

   local lowest_lap_time = self.lowest_lap_time

   --now, similar to race times, try to insert this into the record list
   local lap_time_saved = false
   for i = 1, #course.lap_times do
      if lowest_lap_time < course.lap_times[i].time then
         table.insert(course.lap_times, i, {time=lowest_lap_time})
         while #course.lap_times > 3 do
            table.remove(course.lap_times, 4)
         end
         lap_time_saved = true
         break --stop considering lap times!
      end
      if lowest_lap_time == course.lap_times[i].time then
         -- we've tied a score! this does nothing, on purpose, to avoid dupes
         lap_time_saved = true
         break
      end
   end
   if lap_time_saved == false and #course.lap_times < 3 then
      table.insert(course.lap_times, {time=lowest_lap_time})
   end

   --whew! now just save the scores to file
   highscores:saveToFile()
end

function highscores:bestRaceTimes(course_name)
   if self.courses[course_name] then
      return self.courses[course_name].race_times
   end
   return nil
end

function highscores:bestLapTimes(course_name)
   if self.courses[course_name] then
      return self.courses[course_name].lap_times
   end
   return nil
end

return highscores
