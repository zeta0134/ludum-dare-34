Vector = require("vector")
local levels = {}

levels["plains"] = {
   image_name="plains",
   starting_position=Vector.new(453, 225),
   starting_rotation=0.2,
   checkpoints=7,
   laps=5,
   clear_color={r=58,g=99,b=15},
   growth_period=1400
}

levels["desert"] = {
   image_name="desert",
   starting_position=Vector.new(691, 211),
   starting_rotation=0.0,
   checkpoints=14,
   laps=3,
   clear_color={r=195,g=132,b=25},
   growth_period=1600
}

levels["volcano"] = {
   image_name="volcano",
   starting_position=Vector.new(1153, 120),
   starting_rotation=0.85,
   checkpoints=11,
   laps=3,
   clear_color={r=26,g=22,b=26},
   growth_period=1200
}

return levels
