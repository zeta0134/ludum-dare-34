Vector = require("vector")
local levels = {}

levels["plains"] = {
   image_name="slightly-better-track",
   starting_position=Vector.new(351, 888),
   starting_rotation=-0.5,
   checkpoints=18,
   laps=3,
   clear_color={r=0,g=82,b=9},
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
   growth_period=256
}

return levels
