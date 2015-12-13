In the level loader:
--------------------
- [x] Base name of the stage, from which it finds all art assets for stitching
- [ ] Actual level stitching, respecting the maximum texture size of 1024
      (but no limit on number of loaded textures?)
- [x] Level attributes (plant types? growth rate? starting positions?)
- [ ] Out of Bounds texture (No no no! Wrong way!)
- [ ] Going out of bounds (like, OFF the map) should teleport the player to the last
      known good position before they left the map (ie, back on the track)

Level Hazards:
--------------
- [ ] Invisi-radius that knocks you back towards the track from whence you came
- [ ] Lava: Seeds do not grow here. Attempting to drag results in slowdowns and pain
- [ ] Zippers: Tapping (including a drag) over a zipper gives you a boost.
- [ ] Water: Increases drag slide (more angled toward the side, same speed), no
      seeds can be planted here. Not even water lilies. (see: feature creep.)

Nice to have:
-------------
- [ ] Jump: Similar to a zipper, but causes the rider to rise into the sky! No seeds
      are planted while jumping, and no level hazards are considered at all until
      the player lands, including plants and things that would slow you down.

Seed Placement and Growth:
--------------------------
- [ ] Pull out growth rate and make it adjustable (per level? per plant type?)
- [ ] Cause different growth levels (per plant?) to cause different drag percentages

Riders:
-------
- [ ] Different sprites for turning, sliding, and boosting

Feature Creep:
--------------
- [ ] Minimap
- [ ] Completing a lap causes all of your plants to bloom at once
- [ ] Split-screen multiplayer
- [ ] AI Riders
- [ ] Particles! (Love has these built in)
- [ ] Speed Lines when boosting! So it feels faster
- [ ] Ghosts. (STAFF Ghosts?)
