Known Bugs
----------
- [x] Upon exiting a race while boosted, the boost meter never depletes, and the boost particles never disappear and look quite strange.
- [x] Ending up out of bounds of the map crashes in racer.lua line 325, trying to pick the color of the dust cloud over nonexistant map.
- [x] Pressing both keys from going straight on the same frame locks you going straight; it should do a straight slide.
- [x] Wrong way sign is too eager; should pop up after ~1s of going the wrong way
   - [x] Also prevent this from showing up on race finish
- [x] It is possible to go out of bounds backwards; the oob logic will then place you further out of bounds. It should try what it's doing (putting you behind where you went off), infront of that, and straight where you went off.
- [x] Final time is one frame too long compared to the lap total.

Sounds (Canceled!)
------------------
- [ ] Music: Title Screen and Menus
- [ ] Music: Racing (bonus: themes for each stage)
- [ ] SFX: Charging Up (loops near the top; can we frequency slide with code?)
- [ ] SFX: Boost
- [ ] SFX: Miss! (Out of Bounds / Warped backwards)
- [ ] SFX: On fire!
- [ ] SFX: Sliding. Bonus: per material (dirt, grass, sand, water, rocks)
- [ ] SFX: Lap Clear
- [ ] SFX: Race Clear (music here too?)
- [x] SFX: 3... 2... 1... RACE!

In the level loader:
--------------------
- [x] Base name of the stage, from which it finds all art assets for stitching
- [ ] Actual level stitching, respecting the maximum texture size of 1024
      (but no limit on number of loaded textures?) (CANCELED)
- [x] Level attributes (plant types? growth rate? starting positions?)
- [ ] Out of Bounds texture (No no no! Wrong way!) (COLOR, no texture)
- [x] Going out of bounds (like, OFF the map) should teleport the player to the last
      known good position before they left the map (ie, back on the track)
- [ ] Differnet plant sprites per-level

Level Hazards:
--------------
- [x] Invisi-radius that knocks you back towards the track from whence you came
- [x] Lava: Seeds do not grow here. Attempting to drag results in slowdowns and pain
   - [x] Sliding over lava should empty the boost charge
- [x] Zippers: Tapping (including a drag) over a zipper gives you a boost.
- [x] Water: Increases drag slide (more angled toward the side, same speed), no
      seeds can be planted here. Not even water lilies. (see: feature creep.)

Nice to have:
-------------
- [ ] Jump: Similar to a zipper, but causes the rider to rise into the sky! No seeds
      are planted while jumping, and no level hazards are considered at all until
      the player lands, including plants and things that would slow you down.
- [x] Frame limit. See [love.timer.sleep](https://love2d.org/wiki/love.timer.sleep) for examples.
- [x] Wrong way notifier (image), for helping people realize they're going backwards
- [x] A help screen
- [x] Redo the Plains. Or, adjust the starting position.
- [x] Add out of bounds regions (and hazards?) to the desert.
- [x] Text for the title screen selections.
- [x] Bitmap font for times/laps/hud.

Seed Placement and Growth:
--------------------------
- [x] Pull out growth rate and make it adjustable (per level? per plant type?)
- [x] Cause different growth levels (per plant?) to cause different drag percentages

Riders:
-------
- [x] Different sprites for turning, sliding, and boosting
- [x] HUD
- [x] Acceleration! You shouldn't instantly go top speed, nor should you instantly drop speed going over rough terrain!

Feature Creep:
--------------
- [x] Minimap
   - [x] minimap from svg
- [ ] Completing a lap causes all of your plants to bloom at once
- [ ] Split-screen multiplayer
- [ ] AI Riders
- [x] Particles! (Love has these built in)
- [x] Speed Lines when boosting! So it feels faster
- [ ] Ghosts. (STAFF Ghosts?)
