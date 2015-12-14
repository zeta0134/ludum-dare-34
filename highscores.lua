local highscores = {}

highscores.courses = {}

function highscores:loadFromFile(filename)
   --TODO: Implement this!
end

function highscores:saveToFile(filename)
   --TODO: This too!
end

function highscores:addScore(course_name, race_time, lap_times)
   if not self.courses[course_name] then
      self.courses[course_name] = {}
      self.courses[course_name].race_time = 0
      self.courses[course_name].lap_time = 0
   end

   if race_time > self.courses[course_name].race_time then
      self.courses[course_name].race_time = race_time
   end

   for i = 1, #lap_times do
      if lap_times[i] > self.courses[course_name].lap_time then
         self.courses[course_name].lap_time = lap_times[i]
      end
   end
end

function highscores:bestRaceTime(course_name)
   if self.courses[course_name] then
      return self.courses[course_name].race_time
   end
   return 0
end

function highscores:bestLapTime(course_name)
   if self.courses[course_name] then
      return self.courses[course_name].lap_time
   end
   return 0
end

return highscores
