# ludum-dare-34: Tailwind
Ludum dare is a competition that challenges participants to create a game from scratch in 48/72 hours. This is our entry for the Jam, a 72-hour team based challenge.

Our entry is Tailwind, a top down racing game in which you play as a seed spirit riding a leaf through various areas to replant the barren areas. Your goal is to go as quickly as possible so you can bring life to the next area.

The controls are simple - just move left and right. If you try to go the opposite direction while turning, you'll slide your leaf along the ground, pulling nutrients from the soil. This charges your leaf, which will fly on the wind with tremendous speed when you release at least one button.

Since you're trying to hurry, you just spread seeds behind you wherever you go. In retrospect, this wasn't the best idea - now you're running into the plants you've already planted the last time you went through here, and running into them slows you down, so try to avoid them. They grow bigger over time, and the bigger they are, the more caught up in them you become.

## Playing the game

To play from source, clone this repository and install [LOVE](love2d.org) 0.9.2 for your system. On Windows, you can drag the folder onto `love.exe` to run it, or you can change into the cloned directory in a terminal and run `love .`

You can also check the releases for the latest release, we try to build for all available systems.

There are a number of control mappings to the two buttons:
- Left and right arrow keys
- Left and right control
- Left and right shift
- A and D
- H and L
- B and F

## Credits

- zeta0134 - engine programming, sound editing
- cromo - menu programming, art, sound effects
- rgarza533 - music, sound effects
- robertoszek - testing
- gboblyn - testing
