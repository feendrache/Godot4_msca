## Basic Movement

This class provides the base means of moving the character node with the arrow keys

With the "move_player" function it checks the input actions ui_right, ui_left, ui_up, ui_down given by godot and calculates the input vector.
This vector is used to set the velocity of the player (the parent node) and activate movement with move_and_slide()
