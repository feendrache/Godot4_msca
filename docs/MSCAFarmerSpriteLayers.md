# The Layer Container / MSCAFarmerSpriteLayers

In this class the basic layer handling is managed.

## Signals
the following signals are provided:
- animation_state_finished(state_name, state_duration)
- animation_state_started(state_name)
- animation_set_hitbox(counter, track, timer_value, direction)
- make_sound(state_name, sound_name)
All these Signals are triggered by functions called out of the animations

### animation_state_finished
This signal is fired when an animation state (like jumping) is finished and provides the name of the finished state and the duration the state has (animation length)

### animation_state_started
This signal is fired at the start of an animation state

### animation_set_hitbox
This signal is fired inside the attack animations to provide you with a way on setting the hitboxes of your weapon

### make_sound
This signal is set in some animations at specific frames to enable you to connect sounds to anims like walking, chopping or mining

## Functions

### set_corresponding_layers_to_animframe
When you deactivate the animation tree of the player you can set all layers of the famer base sheets with this function

### change_child_position
Sometimes it is needed that you change the layer position inside the SpriteLayers Container to have the animation rendered correctly (this function is used by the animations)

### emit_animation_state_finished, emit_animation_state_started, set_hitbox, emit_sound
These functions are called by the animations to emit the signals

### get_full_spritesheet_name_and_path
Gives you the name of the spritesheet with the path that it has inside the base sheets of the sprite system

### get_full_spritesheet_name
returns a string that gives you the name of the spritesheet

### set_shader
You can use this to set the shader the msca comes with to a specific layer
#### Parameters:
- layer: name of the layer
- original_ramp: the base ramp of the layer (Example: colors created out of: _supporting files/palettes/base ramps/3.color base ramp (00a).png) You can use the [MSCAPaletteSwaps](MSCAPaletteSwaps.md) class to extract the palette values out of the image
- new_ramp: the ramp the shader should show (colors created out of the ramps provided by Seliel)

You can provide the ramps either als color values or as HTML color values, the function makes sure that the ramps are color values by using the PaletteSwaps class.
It then creates the shader material and sets the layer with it.
