local camera = require("camera")
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
   self.seed_rate = 1

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
   self.slide_turn_rate = 0.009

   self.spray_direction = 1.0
   self.spray_offset = 5.0

   self.lap = 1
   self.checkpoint = 1

   self.race_timer = 0
   self.lap_timer = 0
   self.lap_times = {}

   self.zipper_timer = 0
   self.on_fire_timer = 240

   self.last_known_good = {}
   self.last_known_good.position = Vector.new()
   self.last_known_good.position.x = self.position.x
   self.last_known_good.position.y = self.position.y
   self.last_known_good.rotation = self.rotation

   self.warp_timer = 0

   self.wrong_way = false

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

end

function Racer:update()
   Object.update(self)

   for k,_ in pairs(self.particles) do
      self.particles[k]:setPosition(self.position.x, self.position.y)
      self.particles[k]:update(1.0/60.0)
   end

   camera.position = racer.position + vector_from_angle(racer.rotation) * 250.0
   camera.rotation = racer.rotation + 0.5

   if not stage.race_active then
      self.velocity = self.velocity * 0.95
      return --STAHP
   end

   local speed = self.normal_speed
   if self.boost_timer > 0 then
      -- give about a 25% falloff toward the end of the boost
      boost_speed = math.min(self.boost_speed, (self.boost_speed * self.boost_timer * 4 / self.max_drag))
      speed = speed + boost_speed
      self.seed_spread = 5
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
      local zip_factor = math.min(0.5, (0.5 * self.zipper_timer * 4 / 60))
      -- WHEEEEEE
      speed = speed * (1.0 + zip_factor)
      self.zipper_timer = self.zipper_timer - 1
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

   if pixel_properties.checkpoint then
      if pixel_properties.checkpoint < self.checkpoint or pixel_properties.checkpoint > self.checkpoint + 2 then
         self.wrong_way = true
      else
         self.wrong_way = false
      end
   end

   -- handle out of bounds warping
   if self.warp_timer > 0 then
      if self.warp_timer == 30 then
         -- Heave! Ho!
         self.position.x = self.last_known_good.position.x
         self.position.y = self.last_known_good.position.y
         self.rotation = self.last_known_good.rotation
      end
      self.warp_timer = self.warp_timer - 1
      speed = 0
   end

   local thrust = vector_from_angle(self.rotation)
   local slide_vector = self.slide_vector
   if pixel_properties.water then
      slide_vector = slide_vector * 1.5
   end
   if key.state == "slide-left" then
      thrust = vector_from_angle(self.rotation + slide_vector)
      self.spray_direction = 1.0 - 0.5
      self.spray_offset = 50.0
      self.drag = self.drag + 1
   elseif key.state == "slide-right" then
      thrust = vector_from_angle(self.rotation - slide_vector)
      self.spray_direction = -1.0 + 0.5
      self.spray_offset = 50.0
      self.drag = self.drag + 1
   else
      if self.drag > 0 then
         self.boost_timer = self.drag
      end
      self.drag = 0
      self.spray_direction = 1.0
      self.spray_offset = 5.0
   end
   if self.drag > self.max_drag then
      self.drag = self.max_drag
   end

   -- Account for drag
   speed = math.max(speed - self.drag * (self.normal_speed / self.max_drag), 0)
   self.velocity = thrust * speed
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

   if key.state == "slide-right" or key.state == "slide-left" then
      -- for drag colors later
      local sr, sg, sb = stage.image_data:getPixel(math.floor(self.position.x), math.floor(self.position.y))
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

   for i = 1, self.seed_rate do
      local seed_x = self.position.x + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_y = self.position.y + math.random(self.seed_spread * -1, self.seed_spread)
      local seed_throw = vector_from_angle(self.rotation + self.spray_direction)
      seed_x = seed_x + self.spray_offset * seed_throw.x
      seed_y = seed_y + self.spray_offset * seed_throw.y
      stage:plant_seed(math.floor(seed_x), math.floor(seed_y), 1, math.random(1,2))
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
   Object.draw(self)
   love.graphics.setColor(255, 255, 255)
   -- on-character effects
   love.graphics.draw(self.particles.fire, 0, 0)
end

function Racer.new_racer()
   racer = {}
   setmetatable(racer, {__index=Racer})
   return racer
end

return Racer
