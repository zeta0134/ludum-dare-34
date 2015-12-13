Vector = require("vector")
local levels = {}

levels["plains"] = {
   image_name="slightly-better-track",
   starting_position=Vector.new(351, 888),
   starting_rotation=-0.5,
   checkpoints=18,
   laps=3,
   clear_color={r=42,g=126,b=16},
   growth_period=1400
}

levels["desert"] = {
   image_name="desert",
   starting_position=Vector.new(691, 211),
   starting_rotation=0.0,
   checkpoints=14,
   laps=3,
   clear_color={r=226,g=154,b=32},
   growth_period=1600
}

levels["volcano"] = {
   image_name="slightly-better-track",
   starting_position=Vector.new(351, 888),
   starting_rotation=-0.5,
   checkpoints=18,
   laps=3,
   clear_color={r=42,g=126,b=16},
   growth_period=256
}

return levels
