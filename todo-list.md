In the level loader:
--------------------
- [x] Base name of the stage, from which it finds all art assets for stitching
- [ ] Actual level stitching, respecting the maximum texture size of 1024
      (but no limit on number of loaded textures?)
- [x] Level attributes (plant types? growth rate? starting positions?)
- [ ] Out of Bounds texture (No no no! Wrong way!)
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
- [ ] Wrong way notifier, for helping people realize they're going backwards
- [ ] A help screen
- [ ] Redo the Plains. Or, adjust the starting position.

Seed Placement and Growth:
--------------------------
- [x] Pull out growth rate and make it adjustable (per level? per plant type?)
- [x] Cause different growth levels (per plant?) to cause different drag percentages

Riders:
-------
- [ ] Different sprites for turning, sliding, and boosting

Feature Creep:
--------------
- [x] Minimap
- [ ] Completing a lap causes all of your plants to bloom at once
- [ ] Split-screen multiplayer
- [ ] AI Riders
- [ ] Particles! (Love has these built in)
- [ ] Speed Lines when boosting! So it feels faster
- [ ] Ghosts. (STAFF Ghosts?)