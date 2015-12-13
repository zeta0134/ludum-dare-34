local leaf_types = {}

leaf_types["Oak"] = {}
leaf_types["Clover"] = {
   normal_speed=10,
   boost_speed=10,
   max_drag=1,
   normal_turn_rate=0,
   slide_turn_rate=0.012
}

leaf_types["Aloe"] = {
   normal_speed=0,
   boost_speed=8.5,
   max_drag=60 * 10,
}

return leaf_types
