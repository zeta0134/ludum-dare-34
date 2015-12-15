local camera = require("camera")
local highscores = require("highscores")
local key = require("key")
local Object = require("object")
local stage = require("stage")
local Vector = require("vector")

local Racer = {}
setmetatable(Racer, {__index=Object})

function vector_from_angle(angle)
   --note: angle here is in R * pi format
   local x = math.cos(angle * math.pi)
   local y = math.sin(angle * math.pi)
   return Vector.new(x, y)
end

function Racer:load(options)
   Object.load(self)

   self:set_sprite("oak-player", true)

   self.velocity = self.velocity * 0

   self.rotational_damping = 0.2

   self.seed_spread = 15
   self.seed_delay = 2
   self.seed_timer = 0

   self.drag = 0
   self.max_drag = 80
   self.boost_timer = 0

   self.previous_state = nil

   self.normal_speed = 5.0
   self.boost_speed = 3.0
   self.offroad_drag = 0.40 -- percent, applied to current speed.
   self.plant_drag = 0.50 -- percent, applied to current speed.

   self.slide_vector = 0.25
   self.normal_turn_rate = 0.006
   self.slide_turn_rate = 0.012

   self.spray_direction = 1.0
   self.spray_offset = 5.0

   self.lap = 1
   self.checkpoint = 1

   self.race_timer = 0
   self.lap_timer = 0
   self.lap_times = {}

   self.zipper_timer = 0
   self.on_fire_timer = 0

   self.last_known_good = {}
   self.last_known_good.position = Vector.new()
   self.last_known_good.position.x = self.position.x
   self.last_known_good.position.y = self.position.y
   self.last_known_good.rotation = self.rotation

   self.warp_timer = 0

   self.wrong_way = false

   self.weight = 0.80

   self.momentum = Vector.new()

   self.machine_acceleration = 0.2

   self.machine_friction = 0.1
   self.friction = 0.1

   options = options or {}
   for k,v in pairs(options) do
      self[k] = v
   end

   -- For being set on fire
   self.particles = {}
   self.particle_disc = love.graphics.newImage("art/particle-disc.png")
   self.particles.fire = love.graphics.newParticleSystem(self.particle_disc, 1024)
   self.particles.fire:setParticleLifetime(0.5,0.7)
   self.particles.fire:setEmissionRate(60)
   self.particles.fire:setLinearAcceleration(-30, -30, 30, 30)
   self.particles.fire:setAreaSpread("normal", 7, 7)
   self.particles.fire:setColors(255, 224, 32, 255, 224, 16, 0, 255)
   self.particles.fire:setSizes(0.5, 0.5, 0.5, 0)
   self.particles.fire:stop()

   -- For sliding (dust cloud from the ground)
   self.particles.dust_cloud = love.graphics.newParticleSystem(self.particle_disc, 1024)
   self.particles.dust_cloud:setParticleLifetime(0.15,0.20)
   self.particles.dust_cloud:setEmissionRate(120)
   self.particles.dust_cloud:setSpread(0.25 * math.pi)
   self.particles.dust_cloud:setSizes(0.5, 0.8, 0)
   self.particles.dust_cloud:stop()

   -- For boosting and generally being FAST
   self.particle_speedlines = love.graphics.newImage("art/particle-speed-lines.png")
   self.particles.boost_lines = love.graphics.newParticleSystem(self.particle_speedlines, 1024)
   self.particles.boost_lines:setParticleLifetime(0.15,0.20)
   self.particles.boost_lines:setEmissionRate(120)
   self.particles.boost_lines:setSizes(1.0, 1.0)
   self.particles.boost_lines:setColors(192, 192, 192, 128, 128, 128, 128, 128)
   self.particles.boost_lines:setAreaSpread("normal", 300, 300)
   self.particles.boost_lines:stop()

   self.particles.boost_exhaust = love.graphics.newParticleSystem(self.particle_disc, 1024)
   self.particles.boost_exhaust:setParticleLifetime(0.20,0.25)
   self.particles.boost_exhaust:setEmissionRate(120)
   self.particles.boost_exhaust:setSpread(0.50 * math.pi)
   self.particles.boost_exhaust:setSizes(0.4, 0.5, 0.6, 0.0)
   self.particles.boost_exhaust:setSpeed(10, 20)
   self.particles.boost_exhaust:stop()
end

function Racer:start_boost_effect(r1, g1, b1, r2, g2, b2)
   local current_speed = self.velocity:length() * 60
   self.particles.boost_lines:setSpeed(current_speed * -1.6, current_speed * -1.8)
   local particle_rotation = (self.rotation) * math.pi
   self.particles.boost_lines:setDirection(particle_rotation, particle_rotation)
   self.particles.boost_lines:setRotation(particle_rotation, particle_rotation)
   self.particles.boost_lines:start()

   -- invert direction for the exhaust
   self.particles.boost_exhaust:setDirection(particle_rotation)
   self.particles.boost_exhaust:setSpeed(current_speed * 0.5, current_speed * 0.6)
   self.particles.boost_exhaust:setColors(r1, g1, b1, 255, r2, g2, b2, 255)
   self.particles.boost_exhaust:start()

   camera.zoom = 0.9
   camera.drag = 0.025
end

function Racer:stop_boost_effect()
   self.particles.boost_lines:stop()
   self.particles.boost_exhaust:stop()
   camera.zoom = 1.0
   camera.drag = 0.04
end

function Racer:update()
   Object.update(self)

   self.friction = self.machine_friction

   for k,_ in pairs(self.particles) do
      self.particles[k]:setPosition(self.position.x, self.position.y)
      self.particles[k]:update(1.0/60.0)
   end

   camera.position = racer.position + vector_from_angle(racer.rotation) * 250.0
   camera.rotation = racer.rotation + 0.5

   if not stage.race_active then
      self.acceleration = Vector.new()
      self.friction = 0.15
      self:stop_boost_effect()
      return --STAHP
   end

   local speed = self.normal_speed
   if self.boost_timer > 0 then
      -- give about a 25% falloff toward the end of the boost
      boost_speed = math.min(self.boost_speed, (self.boost_speed * self.boost_timer * 4 / self.max_drag))
      speed = speed + boost_speed
      self.seed_spread = 5

      self:start_boost_effect(224, 224, 255, 64, 64, 128)
   else
      self.seed_spread = 15
   end
   local flower_here, growth_state, flower_type = stage:flower_at(self.position.x, self.position.y)
   if flower_here then
      if growth_state > 0 then
         speed = speed * (1.0 - (self.plant_drag * (growth_state / 3.0)))
      end
   end

   if self.zipper_timer > 0 then
      local zip_factor = math.min(1, (1 * self.zipper_timer * 4 / 60))
      -- WHEEEEEE
      speed = speed + zip_factor
      self.zipper_timer = self.zipper_timer - 1
      self:start_boost_effect(255, 255, 128, 192, 128, 16)
   end

   if self.boost_timer == 0 and self.zipper_timer == 0 then
      self:stop_boost_effect()
   end

   if self.on_fire_timer > 0 then
      speed = speed * 0.5
      self.on_fire_timer = self.on_fire_timer - 1
      self.particles.fire:start()
   else
      self.particles.fire:stop()
   end

   -- deal with checkpoints and lap counters
   local pixel_properties = stage:properties_at(self.position.x, self.position.y)
   if pixel_properties.checkpoint then
      if pixel_properties.checkpoint > self.checkpoint and pixel_properties.checkpoint <= self.checkpoint + 2 then
         self.checkpoint = pixel_properties.checkpoint
      end
   end
   if pixel_properties.finish_line and self.checkpoint >= stage.num_checkpoints then
      -- lap complete!
      self.lap_times[self.lap] = self.lap_timer
      self.lap_timer = 0
      if self.lap == stage.properties.laps then
         -- time trial complete!!
         stage.race_active = false
         highscores:addScore(key.title_state, self.race_timer, self.lap_times)
         return
      else
         self.lap = self.lap + 1
         self.checkpoint = 1
      end
   end

   if pixel_properties.offroad then
      speed = speed * self.offroad_drag
   end

   if pixel_properties.zipper then
      self.zipper_timer = 60
   end

   if pixel_properties.lava and (key.state == "slide-left" or key.state == "slide-right") then
      self.on_fire_timer = 120 -- 2 seconds worth of PAIN!
      self.boost_timer = 0
      self.drag = 0
   end

   if pixel_properties.out_of_bounds and self.warp_timer == 0 then
      self.warp_timer = 60
   end

   if (not pixel_properties.out_of_bounds) and (not pixel_properties.offroad) then
      self.last_known_good.position.x = self.position.x
      self.last_known_good.position.y = self.position.y
      self.last_known_good.rotation = self.rotation
   end

   if pixel_properties.checkpoint and self.race_active then
      if pixel_properties.checkpoint < self.checkpoint or pixel_properties.checkpoint > self.checkpoint + 2 then
         self.wrong_way = true
      else
         self.wrong_way = false
      end
   else
      self.wrong_way = false
   end

   -- handle out of bounds warping
   if self.warp_timer > 0 then
      if self.warp_timer == 30 then
         -- Heave! Ho!
         self.position.x = self.last_known_good.position.x
         self.position.y = self.last_known_good.position.y
         self.rotation = self.last_known_good.rotation

         -- move the player backwards a little bit
         --self.position = self.position + vector_from_angle(self.rotation + 1.0) * 100
      end
      if self.warp_timer == 29 then
         camera.delayed_position = camera.position
      end
      self.warp_timer = self.warp_timer - 1
      self.velocity = Vector.new()
   end

   local thrust = vector_from_angle(self.rotation)
   local slide_vector = self.slide_vector
   if pixel_properties.water then
      slide_vector = slide_vector * 1.5
   end
   if key.state == "slide-left" then
      thrust = self.momentum * self.weight + thrust * (1.0 - self.weight)
      thrust = thrust:normalize()
      self.spray_direction = 1.0 - 0.5
      self.spray_offset = 30.0
      self.drag = self.drag + 1
   elseif key.state == "slide-right" then
      thrust = self.momentum * self.weight + thrust * (1.0 - self.weight)
      thrust = thrust:normalize()
      self.spray_direction = -1.0 + 0.5
      self.spray_offset = 30.0
      self.drag = self.drag + 1
   else
      if self.drag > 0 then
         self.boost_timer = self.drag
      end
      if self.drag > 0 then
         self.drag = self.drag - 1
      end
      self.spray_direction = 1.0
      self.spray_offset = 5.0
   end
   if self.drag > self.max_drag then
      self.drag = self.max_drag
   end

   local top_speed = speed

   -- Account for drag
   if key.state == "slide-left" or key.state == "slide-right" then
      top_speed = math.max(speed - self.drag * (self.normal_speed / self.max_drag), 0)
   end

   --self.velocity = thrust * speed
   if self.velocity:length() > top_speed then
      local new_speed = top_speed * 0.6 + self.velocity:length() * 0.4
      self.velocity = self.velocity:normalize() * new_speed
   end

   if self.boost_timer > 0 or self.zipper_timer > 0 then
      self.acceleration = thrust * (10 * self.machine_acceleration)
   else
      self.acceleration = thrust * self.machine_acceleration
   end

   self.sprite:set_frame(0, 0)
   if self.boost_timer > 0 then
      self.sprite:set_frame(0, 1)
   end
   if key.state == "left" then
      self.rotational_velocity = self.normal_turn_rate * -1
      self.sprite:set_frame(1, 1)
   end
   if key.state == "right" then
      self.rotational_velocity = self.normal_turn_rate
      self.sprite:set_frame(1, 0)
   end
   if key.state == "slide-left" then
      self.rotational_velocity = self.slide_turn_rate * -1
      self.sprite:set_frame(2, 1)
   end
   if key.state == "slide-right" then
      self.rotational_velocity = self.slide_turn_rate
      self.sprite:set_frame(2, 0)
   end

   if self.drag == self.max_drag then
      --self.rotational_velocity = 0
      self.seed_timer = self.seed_delay
   end

   if key.state == "slide-right" or key.state == "slide-left" then
      -- for drag colors later
      local sr = 0
      local sg = 0
      local sb = 0
      if self.position.x > 0 and self.position.y > 0 and self.position.x < stage.image_data:getWidth() and self.position.y < stage.image_data:getHeight() then
         sr, sg, sb = stage.image_data:getPixel(math.floor(self.position.x), math.floor(self.position.y))
      end
      self.particles.dust_cloud:setColors(
         sr * 0.9 , sg * 0.9 , sb * 0.9 , 255,
         sr * 0.8 , sg * 0.8 , sb * 0.8 , 255)
      self.particles.dust_cloud:setDirection(self.rotation * math.pi + self.spray_direction * 0.6 * math.pi)
      local particle_speed = self.velocity:length() * 60 * 1.5
      self.particles.dust_cloud:setSpeed(particle_speed, particle_speed)
      self.particles.dust_cloud:start()
   else
      self.particles.dust_cloud:stop()
   end

   if not (key.state == "slide-left" or key.state == "slide-right") then
      self.momentum.x = self.velocity.x
      self.momentum.y = self.velocity.y
   end

   self.seed_timer = self.seed_timer - 1
   if self.seed_timer <= 0 then
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_throw = vector_from_angle(self.rotation + self.spray_direction)
      seed_x = seed_x + self.spray_offset * seed_throw.x
      seed_y = seed_y + self.spray_offset * seed_throw.y
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 1, math.random(1,2))
      self.seed_timer = self.seed_delay
   end

   self.boost_timer = math.max(self.boost_timer - 1, 0)

   self.race_timer = self.race_timer + 1
   self.lap_timer = self.lap_timer + 1
end

function Racer:draw()
   love.graphics.setColor(255, 255, 255)
   if self.on_fire_timer > 0 then
      local variance = math.abs((self.on_fire_timer % 60) - 30)
      love.graphics.setColor(128 + variance * 3, 64 + variance * 2, 32)
   end
   -- under-character effects
   love.graphics.draw(self.particles.dust_cloud, 0, 0)
   love.graphics.draw(self.particles.boost_exhaust, 0, 0)
   if self.color then
      love.graphics.setColor(unpack(self.color))
   else
      love.graphics.setColor(255, 255, 255)
   end
   Object.draw(self)
   love.graphics.setColor(255, 255, 255)
   -- on-character effects
   love.graphics.draw(self.particles.fire, 0, 0)
   love.graphics.draw(self.particles.boost_lines, 0, 0)
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
