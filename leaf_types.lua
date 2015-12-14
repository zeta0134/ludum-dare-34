local leaf_types = {}

leaf_types["Oak"] = {}
leaf_types["Clover"] = {
   normal_speed=8,
   boost_speed=8,
   max_drag=1,
   normal_turn_rate=0,
   slide_turn_rate=0.020,
   color={128, 255, 255},
   machine_acceleration=1
}

leaf_types["Aloe"] = {
   normal_speed=0,
   boost_speed=7.0,
   max_drag=60 * 10,
   color={255,255,128}
}

return leaf_types
